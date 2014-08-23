#!/bin/bash
# usage:
# send_report.sh [recipient@server.com] [subject-line] [message-text-file] [logfile]
sendEmail -f notifications@codeshelf.com -t ${1} -u ${2} -s smtp.gmail.com:587 -xu notifications@codeshelf.com -xp nbypcrgyxvuijmzz -q -l ${4} -o tls=yes -o message-file=${3}
