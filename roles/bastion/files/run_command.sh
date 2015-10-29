#!/bin/bash

#SSH_ORIGINAL_COMMAND

COMMAND=`echo $SSH_ORIGINAL_COMMAND | cut -d\  -f 1`
HOST=`echo $SSH_ORIGINAL_COMMAND | cut -d\  -f 2`

# do input checking on hostname..
if [[ ! ($HOST == "aldebaran" ||
       $HOST == "betelgeuse" ||
       $HOST == "capella" ||
       $HOST == "deneb"  ||
       $HOST =~ ^sc[0-9]{5} ) ]]
then
       echo "Invalid host"
       exit
fi

# do input checking on command
if [[ ! ($COMMAND == "status" ||
        $COMMAND == "uptime"  ||
        $COMMAND == "pstree"  ||
        $COMMAND == "start-daemon"  ||
        $COMMAND == "stop-daemon"  ||
        $COMMAND == "restart-daemon"  ||
        $COMMAND == "reset-daemon"  ||
        $COMMAND == "ansible-host"  ||
        $COMMAND == "reboot-host")  ]]
then
        echo "Invalid command"
        exit
fi

# perform the called action
case $COMMAND in
        'status')
		# are we talking to a site controller?
                if [[ $HOST =~ ^sc[0-9]{5} ]]
                then
			# we are talking with a site controller

			# get the site controller number
                        SITECON=`echo $HOST | cut -d\c -f 2`
			# define a valid site controller range, 10000 < x < 20000
			if [ ! ( "$SITECON" -gt "9999" && "$SITECON" -lt "19999" ) ]
			then
				echo "Invalid site controller number"
				exit
			fi

			# compute the site controller monitor port
                        PORT=$((SITECON+20000))

                        echo "curl http://home1:${PORT}/adm/healthchecks"
                else
			# we are talking to an app server
                        echo "curl http://${HOST}:8181/adm/healthchecks"
                fi
        ;;
        'uptime')
 		echo "ssh $HOST uptime"
        ;;
        'pstree')
 		echo "ssh $HOST pstree"
        ;;
        'start-daemon')
                if [[ $HOST =~ ^sc[0-9]{5} ]]
                then
                        echo "ssh $HOST sudo start codeshelf"
                else
                        echo "ssh $HOST sudo service start codeshelf"
                fi
        ;;
        'stop-daemon')
                if [[ $HOST =~ ^sc[0-9]{5} ]]
                then
                        echo "ssh $HOST sudo stop codeshelf"
                else
                        echo "ssh $HOST sudo service stop codeshelf"
                fi
        ;;
        'restart-daemon')
                if [[ $HOST =~ ^sc[0-9]{5} ]]
                then
                        echo "ssh $HOST sudo restart codeshelf"
                else
                        echo "ssh $HOST sudo service restart codeshelf"
                fi
        ;;
        'reset-daemon')
                if [[ $HOST =~ ^sc[0-9]{5} ]]
                then
                        echo "ssh $HOST 'sudo rm -rf /opt/codeshelf/*' ; ap sitecons.yml --limit $HOST"
                else
                        echo "not implemented for app servers"
                fi
        ;;
        'ansible-host')
                if [[ $HOST =~ ^sc[0-9]{5} ]]
                then
                        echo "ap sitecons.yml --limit $HOST"
                else
                        echo "ap fep.yml --limit $HOST"
                fi
        ;;
        'reboot-host')
                if [[ $HOST =~ ^sc[0-9]{5} ]]
                then
                        echo "ssh $HOST sudo reboot"
                else
                        echo "not implemented for app servers"
                fi
        ;;
        *)
                echo "Unknown command, try again"
        ;;
esac

exit

