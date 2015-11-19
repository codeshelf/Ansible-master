#!/bin/bash

HOST=$1

ssh root@$HOST hostname

scp sudoers root@$HOST:/etc/sudoers

ssh root@$HOST adduser ansible

ssh root@$HOST "mkdir /home/ansible/.ssh && chown ansible:ansible /home/ansible/.ssh && chmod 700 /home/ansible/.ssh"

scp /home/ansible/.ssh/id_rsa.pub root@$HOST:/home/ansible/.ssh/authorized_keys

ssh root@$HOST "chown ansible:ansible /home/ansible/.ssh/authorized_keys && chmod 600 /home/ansible/.ssh/authorized_keys"

