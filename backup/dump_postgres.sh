#!/bin/bash
ssh ansible@${1} 'sudo su - postgres -c "pg_dump --create --verbose '${2}'"| gzip -f -' 2>/dev/null > ${3}

