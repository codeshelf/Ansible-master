#!/bin/bash
#
# create 10000 numbered user accounts with unique SSH keys
#
# ONLY RUN THIS ON THE PHONE-HOME SERVER!
#

AUTH="s/^ssh/command=\"echo shell not allowed\",no-X11-forwarding,no-agent-forwarding,no-pty ssh/"

for i in {10000..19999}
do
        adduser -g users -N --shell /bin/false u$i
        mkdir /home/u$i/.ssh
        chown u$i:users /home/u$i/.ssh
        ssh-keygen -t rsa -b 2048 -N '' -f /home/u$i/.ssh/id_rsa
        cat /home/u$i/.ssh/id_rsa.pub \
                | sed -e "$AUTH" -e 's/root@home/u'$i'@home/' \
                > /home/u$i/.ssh/authorized_keys
	chown u$i:users /home/u$i/.ssh/*
        chmod 700 /home/u$i/.ssh
        chmod 600 /home/u$i/.ssh/*
done

