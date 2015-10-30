#!/bin/bash

# set up environment for ansible
source /home/ansible/setup_env.sh

# turn this varriable into an array: SSH_ORIGINAL_COMMAND
INPUTARRAY=($SSH_ORIGINAL_COMMAND)
# parse out first and second elements
COMMAND=${INPUTARRAY[0]}
HOST=${INPUTARRAY[1]}

# if we got a hostname, check it
if [[ $HOST ]]
then
	# do input checking on hostname..
	if [[ ! ($HOST == "aldebaran" ||
		$HOST == "betelgeuse" ||
		$HOST == "capella" ||
		$HOST == "deneb"  ||
		$HOST == "test"  ||
		$HOST == "stage"  ||
		$HOST =~ ^sc[0-9]{5} ) ]]
	then
		echo "Invalid host"
		exit
	fi
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
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			# compute the site controller monitor port
			PORT=$((SITECON+20000))

			curl http://home1:${PORT}/adm/healthchecks 2>/dev/null
		else
			# we are talking to an app server
			curl http://${HOST}:8181/adm/healthchecks 2>/dev/null
		fi
	;;
	'uptime')
		# are we talking to a site controller?
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			# get the site controller number
			SITECON=`echo $HOST | cut -d\c -f 2`
			# define a valid site controller range, 10000 < x < 20000
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			ssh -p $SITECON home1 uptime
		else
			# we are talking to an app server
			ssh $HOST uptime
		fi
	;;
	'pstree')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			SITECON=`echo $HOST | cut -d\c -f 2`
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
			exit
			fi

			ssh -p $SITECON home1 pstree
		else
			ssh $HOST pstree
		fi
	;;
	'start-daemon')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			SITECON=`echo $HOST | cut -d\c -f 2`
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			ssh -p $SITECON home1 sudo service codeshelf start
		else
			ssh $HOST sudo start codeshelf
		fi
	;;
	'stop-daemon')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			SITECON=`echo $HOST | cut -d\c -f 2`
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			ssh -p $SITECON home1 sudo service codeshelf stop
		else
			ssh $HOST sudo stop codeshelf
		fi
	;;
	'restart-daemon')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			SITECON=`echo $HOST | cut -d\c -f 2`
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			ssh -p $SITECON home1 sudo service codeshelf restart
		else
			ssh $HOST sudo restart codeshelf
		fi
	;;
	'reset-daemon')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			SITECON=`echo $HOST | cut -d\c -f 2`
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			ssh -p $SITECON home1 'sudo rm -rf /opt/codeshelf/*'
			ansible-playbook sitecon.yml --limit $HOST
		else
			echo "not implemented for app servers"
		fi
	;;
	'ansible-host')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			ansible-playbook sitecons.yml --limit $HOST
		else
			ansible-playbook fep.yml --limit $HOST
		fi
	;;
	'reboot-host')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			SITECON=`echo $HOST | cut -d\c -f 2`
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			ssh -p $SITECON home1 sudo reboot
		else
			echo "not implemented for app servers"
		fi
	;;
	*)
		echo "Unknown command"
	;;
esac

exit

