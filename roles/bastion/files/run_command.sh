#!/bin/bash

# set up environment for ansible
source /home/ansible/setup_env.sh

# set up variables
LOGGER=/usr/bin/logger

# turn this varriable into an array: SSH_ORIGINAL_COMMAND
INPUTARRAY=($SSH_ORIGINAL_COMMAND)
# parse out first and second elements
COMMAND=${INPUTARRAY[0]}
HOST=${INPUTARRAY[1]}
ARGUMENT=${INPUTARRAY[2]}

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
		$HOST == "undying"  ||
		$HOST == "procyon"  ||
		$HOST =~ ^sc[0-9]{5} ) ]]
	then
		echo "Invalid host"
		exit
	fi
fi

# if we have an argument, check it
if [[ $ARGUMENT ]]
then
	if [[ ! ($ARGUMENT =~ ^v[0-9][0-9]\.[0-9]+) ]]
	then
		echo "Invalid argument"
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
	$COMMAND == "codeshelf-versions"  ||
	$COMMAND == "promote-stage"  ||
	$COMMAND == "promote-undying"  ||
	$COMMAND == "upgrade-codeshelf"  ||
	$COMMAND == "upgrade-codeshelfux"  ||
	$COMMAND == "kick-tunnel"  ||
	$COMMAND == "reboot-host")  ]]
then
	echo "Invalid command"
	exit
fi

# log input
echo "ControlPanel: Got input cmd: $COMMAND host: $HOST" | $LOGGER

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
			ansible-playbook sitecon.yml --limit $HOST
		else
			ansible-playbook fep.yml --limit $HOST
		fi
	;;
	'codeshelf-versions')
		echo "Available Versions"
		echo -n "	Codeshelf: "
		ls /home/ansible/release/Codeshelf | grep ^v | tr '\n' ' '
		echo " "
		echo " "
		echo -n "	CodeshelfUX: "
		ls /home/ansible/release/CodeshelfUX | grep ^v | tr '\n' ' '
		echo " "
		for host in aldebaran betelgeuse capella deneb procyon
		do
			echo " "
			echo "${host}"
			echo -n "	Codeshelf: "
			readlink /home/ansible/release/Codeshelf/${host} | tr '\n' ' '
			echo " " 
			echo -n "	CodeshelfUX: "
			readlink /home/ansible/release/CodeshelfUX/${host} | tr '\n' ' '
		done
		echo " "
		echo " "
		echo "Stage version:"
		echo -n "		Codeshelf: "
		cat /home/ansible/release/Codeshelf/stage/build.txt | egrep '(version.major|version.revision)' | tr '\n' ' '
		echo ""
		echo -n "		CodeshelfUX: "
		cat /home/ansible/release/CodeshelfUX/stage/buildweb.txt | egrep '(major|revision)' | tr '\n' ' '
		echo " "
		echo "Long term version:"
		echo -n "		Codeshelf: "
		cat /home/ansible/release/Codeshelf/undying/build.txt | egrep '(version.major|version.revision)' | tr '\n' ' '
		echo ""
		echo -n "		CodeshelfUX: "
		cat /home/ansible/release/CodeshelfUX/undying/buildweb.txt | egrep '(major|revision)' | tr '\n' ' '
		echo " "
	;;
	'promote-stage')
		CODESHELF_MAJOR=`grep version.major /home/ansible/release/Codeshelf/stage/build.txt | cut -d\= -f 2`
		CODESHELF_REV=`grep version.revision /home/ansible/release/Codeshelf/stage/build.txt | cut -d\= -f 2`
		CODESHELF_UX_MAJOR=`cat /home/ansible/release/CodeshelfUX/stage/buildweb.txt | tr '{' '\n' | tr ',' '\n' | grep major | cut -d\: -f 2 | tr -d '"' | tr -d ' '`
		CODESHELF_UX_REV=`cat /home/ansible/release/CodeshelfUX/stage/buildweb.txt | tr '{' '\n' | tr ',' '\n' | grep revision | cut -d\: -f 2 | tr -d '"' | tr -d ' '`

		if [[ $CODESHELF_MAJOR -lt 20 || $CODESHELF_MAJOR -gt 50 ]]
		then
			echo "Parse error!"
			exit
		fi
		if [[ $CODESHELF_REV -lt 1 || $CODESHELF_REV -gt 200 ]]
		then
			echo "Parse error!"
			exit
		fi
		if [[ $CODESHELF_UX_MAJOR -lt 20 || $CODESHELF_UX_MAJOR -gt 50 ]]
		then
			echo "Parse error!"
			exit
		fi
		if [[ $CODESHELF_REV -lt 1 || $CODESHELF_REV -gt 200 ]]
		then
			echo "Parse error!"
			exit
		fi

		echo "Promoting stage.."
		echo " "
		echo "Entering /home/ansible/release/Codeshelf"
		cd /home/ansible/release/Codeshelf
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Copying Codeshelf to v${CODESHELF_MAJOR}.${CODESHELF_REV}"
		cp -ra stage "v${CODESHELF_MAJOR}.${CODESHELF_REV}"
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Entering /home/ansible/release/CodeshelfUX"
		cd /home/ansible/release/CodeshelfUX
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Copying CodeshelfUX to v${CODESHELF_UX_MAJOR}.${CODESHELF_UX_REV}"
		cp -ra stage "v${CODESHELF_UX_MAJOR}.${CODESHELF_UX_REV}"
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Successful!"
	;;
	'promote-undying')
		CODESHELF_MAJOR=`grep version.major /home/ansible/release/Codeshelf/undying/build.txt | cut -d\= -f 2`
		CODESHELF_REV=`grep version.revision /home/ansible/release/Codeshelf/undying/build.txt | cut -d\= -f 2`
		CODESHELF_UX_MAJOR=`cat /home/ansible/release/CodeshelfUX/undying/buildweb.txt | tr '{' '\n' | tr ',' '\n' | grep major | cut -d\: -f 2 | tr -d '"' | tr -d ' '`
		CODESHELF_UX_REV=`cat /home/ansible/release/CodeshelfUX/undying/buildweb.txt | tr '{' '\n' | tr ',' '\n' | grep revision | cut -d\: -f 2 | tr -d '"' | tr -d ' '`

		if [[ $CODESHELF_MAJOR -lt 20 || $CODESHELF_MAJOR -gt 50 ]]
		then
			echo "Parse error!"
			exit
		fi
		if [[ $CODESHELF_REV -lt 1 || $CODESHELF_REV -gt 200 ]]
		then
			echo "Parse error!"
			exit
		fi
		if [[ $CODESHELF_UX_MAJOR -lt 20 || $CODESHELF_UX_MAJOR -gt 50 ]]
		then
			echo "Parse error!"
			exit
		fi
		if [[ $CODESHELF_REV -lt 1 || $CODESHELF_REV -gt 200 ]]
		then
			echo "Parse error!"
			exit
		fi

		echo "Promoting undying.."
		echo " "
		echo "Entering /home/ansible/release/Codeshelf"
		cd /home/ansible/release/Codeshelf
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Copying Codeshelf to v${CODESHELF_MAJOR}.${CODESHELF_REV}"
		cp -ra undying "v${CODESHELF_MAJOR}.${CODESHELF_REV}"
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Entering /home/ansible/release/CodeshelfUX"
		cd /home/ansible/release/CodeshelfUX
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Copying CodeshelfUX to v${CODESHELF_UX_MAJOR}.${CODESHELF_UX_REV}"
		cp -ra undying "v${CODESHELF_UX_MAJOR}.${CODESHELF_UX_REV}"
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Successful!"
	;;
	'upgrade-codeshelf')
		echo "Upgrading $HOST to Codeshelf $ARGUMENT .."
		echo " "
		echo "Entering /home/ansible/release/Codeshelf .."
		echo " "
		cd /home/ansible/release/Codeshelf
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Removing /home/ansible/release/Codeshelf/${HOST} .."
		echo " "
		rm /home/ansible/release/Codeshelf/${HOST}
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Creating /home/ansible/release/Codeshelf/${HOST} -> $ARGUMENT .."
		echo " "
		ln -s ${ARGUMENT} ${HOST}
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Success!"
		exit
	;;
	'upgrade-codeshelfux')
		echo "Upgrading $HOST to CodeshelfUX $ARGUMENT .."
		echo " "
		echo "Entering /home/ansible/release/CodeshelfUX .."
		echo " "
		cd /home/ansible/release/CodeshelfUX
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Removing /home/ansible/release/CodeshelfUX/${HOST} .."
		echo " "
		rm /home/ansible/release/CodeshelfUX/${HOST}
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Creating /home/ansible/release/CodeshelfUX/${HOST} -> $ARGUMENT .."
		echo " "
		ln -s ${ARGUMENT} ${HOST}
		if [[ $? -ne 0 ]]
		then
			echo "Failure!"
			exit
		fi
		echo "Success!"
		exit
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
	'kick-tunnel')
		if [[ $HOST =~ ^sc[0-9]{5} ]]
		then
			SITECON=`echo $HOST | cut -d\c -f 2`
			if [[ ! ( "$SITECON" -ge "10000" && "$SITECON" -le "20000" ) ]]
			then
				echo "Invalid site controller number"
				exit
			fi

			ssh home1 "sudo pkill -U u${SITECON}"
		else
			echo "not implemented for app servers"
		fi
	;;
	*)
		echo "Unknown command"
	;;
esac

exit

