#!/usr/local/bin/python
#
# codeshelf daily backups
#

import datetime, time
import logging, logging.handlers
import os
import shutil
import subprocess
import paramiko

# configuration ------------------------------

folderLog = '/var/log/backup'
folderWork = '/tmp'
folderArchive = '/home/ansible/backup/data'

now = datetime.datetime.fromtimestamp(time.time())
mainLogName = folderLog + '/backup.log'
runLogName = folderLog + now.strftime('/run-%Y-%m-%d-%H%M%S.log')
lastRunLogName = folderLog + '/lastrun.log'
successLogName = folderLog + '/success.log'
emailLogName = folderLog + '/sendEmail.log'

reportEmailRecipient = 'ivan.cooper@codeshelf.com'

logLevel = logging.DEBUG # only used for console log

remoteHost = 'bu.codeshelf.com'
remotePort = 22
remoteUsername = 'backup'
remoteFolder = '/home/backup'
# paramiko will use keys in ~/.ssh by default

# logging setup -----------------------------
paramiko_log = logging.getLogger('paramiko')
paramiko_log.setLevel(logging.WARNING)
paramiko_log.propagate = True

fileFormatter = logging.Formatter('%(asctime)s [%(levelname)s] %(message)s')
consoleFormatter = logging.Formatter('%(asctime)s - %(message)s')
logger = logging.getLogger('')
logger.setLevel(logLevel)

main_fh = logging.handlers.RotatingFileHandler(mainLogName, maxBytes = 1000000, backupCount = 9)
main_fh.setLevel(logging.INFO)
main_fh.setFormatter(fileFormatter)
logger.addHandler(main_fh)

run_fh = logging.FileHandler(runLogName)
run_fh.setLevel(logging.INFO)
run_fh.setFormatter(fileFormatter)
logger.addHandler(run_fh)

ch = logging.StreamHandler()
ch.setLevel(logLevel)
ch.setFormatter(consoleFormatter)
logger.addHandler(ch)

successLog = logging.getLogger('success')
successLog.setLevel(logging.INFO)
successLog.propagate = False
success_fh = logging.FileHandler(successLogName, delay = True)
success_fh.setLevel(logging.INFO)
success_fh.setFormatter(fileFormatter)
successLog.addHandler(success_fh)

# statuses ---------------------------------
STATUS_FAILED = 'failed'
STATUS_RETRY = 'retry'
STATUS_SUCCESS = 'success'

# ------------------------------------------

def log(status,message,service,time_gather,time_upload,size):
    if status == STATUS_FAILED:
        level = logging.ERROR
    elif status == STATUS_RETRY:
        level = logging.WARNING
    else: 
        level = logging.INFO
    message = "{}: {} - {} ({:f},{:f},{:d})".format(status,service,message,time_gather,time_upload,size/1024)
    logger.log(level, message)   
    if status == STATUS_SUCCESS:
        successLog.info(message)

def getFileSize(pathname):
    try:
        size = os.path.getsize(pathname)
    except OSError:
        size = -1
    return size

def backup(extension,backup_function,destinations):
    backupName=backup_function.__name__
    logger.debug("start backup: "+backupName)
    gotFile = False
    elapsed = -1
    triesRemaining = 3
    while triesRemaining > 0:
        triesRemaining -= 1
        if triesRemaining == 0:
            fail_status = STATUS_FAILED
        else:
            fail_status = STATUS_RETRY
        filename = backupName + "-" + datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d-%H%M%S') + "." + extension
        pathname = folderWork+'/'+filename
        try:
            os.remove(pathname)
        except OSError:
            pass # ignore probably just file not found
        
        # do actual data collection 
        starttime = time.clock()
        backup_function(pathname)
        elapsed = time.clock() - starttime

        # check result file
        try:
            fsize = os.path.getsize(pathname)
        except OSError:
            fsize = -1
        
        if fsize == -1:
            log(fail_status,'no_file',backupName,elapsed,0,0)   
            continue 
        elif fsize == 0:
            log(fail_status,'empty_file',backupName,elapsed,0,0)
            continue
                
        # if we made it this far we have a non-empty file to store
        gotFile = True
        logger.debug("got file: {} ({:d} bytes in {:f} secs)".format(pathname,fsize,elapsed))
        break
    
    if gotFile != True:
        return;
        
    for dest in destinations:
        if 'tries' in dest:
            triesRemaining = dest['tries']
        else:
            triesRemaining = 1
        logger.debug("sending to {} ({:d} tries)".format(dest['fn'].__name__,triesRemaining))
        while triesRemaining > 0:
            triesRemaining -= 1
            
            # do upload:
            uploadStart = time.clock()
            result = dest['fn'](pathname)
            uploadElapsed = time.clock() - uploadStart
            
            if result==STATUS_SUCCESS:
                log(STATUS_SUCCESS,'sent_to_'+dest['fn'].__name__,backupName,elapsed,uploadElapsed,fsize)
                triesRemaining=0
            else:
                if triesRemaining>0:
                    failStatus=STATUS_RETRY
                else:
                    failStatus=STATUS_FAILED
                log(failStatus,result,backupName,elapsed,uploadElapsed,fsize)
    logger.debug("done with: "+backupName)
        
def backup_postgres(filename,host,database):
    partial = False
    try:
        subprocess.check_call(['./dump_postgres.sh',host, database, filename])   
    except subprocess.CalledProcessError as cpe:
        logger.debug("CalledProcessError {:d} {}".format(cpe.returncode,cpe.cmd))
        partial = True
    except OSError:
        logger.debug("Failed to call dump_postgres")
    if partial:
        try:
            os.remove(filename)
        except OSError:
            pass    

def backup_appdb(filename):
    backup_postgres(filename,'dbmaster','database')

def backup_teamcity_db(filename):
    backup_postgres(filename,'teamcity','teamcity_db')
    
def backup_teamcity_incremental(filename):
    partial = False
    try:
        subprocess.check_call(['./remote_tar.sh','teamcity','--exclude=.BuildServer/system/cache --listed-incremental=/home/ansible/system.tar.snapshot','/opt/jetbrains/TeamCity/.BuildServer',filename])
    except subprocess.CalledProcessError as cpe:
        logger.debug("CalledProcessError {:d} {}".format(cpa.returncode,cpa.cmd))
        partial = True
    except OSError:
        logger.debug("Failed to call remote_tar")
    if partial:
        try:
            os.remove(filename)
        except OSError:
            pass

def dest_local(pathname):
    fileSize = getFileSize(pathname)
    if fileSize < 0:
        return 'could_not_stat_original'
    if fileSize == 0: 
        return 'no_send_empty_file'
    try:
        shutil.copy(pathname, folderArchive)
    except OSError:
        return 'copy_failed'
    newPathname = folderArchive + '/' + os.path.basename(pathname)
    try:
        copySize = os.path.getsize(newPathname)
    except OSError:
        return 'could_not_stat_copy'
    if fileSize != copySize:
        return 'expected_'+fileSize+'_bytes_got_'+copySize
    return STATUS_SUCCESS

def dest_sftp_drop(pathname):
    client = paramiko.SSHClient()
    try:
        client.load_system_host_keys()
    except IOError:
        return 'failed_load_host_keys'
    try:
        client.connect(hostname = remoteHost, port = remotePort, username = remoteUsername)
    except BadHostKeyException:
        return 'bad_host_key'
    except AuthenticationException:
        return 'authentication_failed'
    except SSHException:
        return 'general_ssh_failure'
    except socket.error:
        return 'socket_error'
    sftp = client.open_sftp()
    tempName = remoteFolder+'/upload.tmp'
    finalName = remoteFolder+'/'+os.path.basename(pathname)
    try:
        putResult = sftp.put(pathname,tempName,confirm = True)
    except Exception as e:
        return 'sftp_upload_exception: '+e.message
    try:
        sftp.rename(tempName,finalName)
    except IOError:
        return 'sftp_rename_error'
    sftp.close()
    client.close()
    if putResult.st_size > 0:
        return STATUS_SUCCESS
    return STATUS_FAILED

def email_report():
    try:
        subprocess.check_call(['./send_report.sh',reportEmailRecipient,'Backup report',runLogName,emailLogName])
    except subprocess.CalledProcessError as cpe:
        logger.debug("CalledProcessError {:d} {}".format(cpa.returncode,cpa.cmd))
    except OSError:
        logger.debug("Failed to call sendEmail")


logger.debug("starting backups...")
defaultDestinations = ({'fn':dest_local},{'fn':dest_sftp_drop,'tries':3})
backup("sql.gz",backup_appdb,defaultDestinations)
backup("sql.gz",backup_teamcity_db,defaultDestinations)
backup("tar.gz",backup_teamcity_incremental,defaultDestinations)
logger.debug("sending email")
email_report()
try:
    shutil.copy(runLogName, lastRunLogName)
except OSError:
    logger.error("couldn't create "+lastRunLogName)
logger.debug("all done.")


    