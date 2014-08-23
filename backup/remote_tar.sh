#!/bin/bash
# usage:
# remote_tar.sh [server] [tar-options] [folder] [output-file]
ssh ansible@${1} 'tar '${2}' -czf - '${3}' ' 2>/dev/null > ${4}
