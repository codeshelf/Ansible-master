#!/bin/bash
#
# checks whether deploy user is requesting engine/web upgrade and does it if so

if [ -f /home/deploy/deploy.engine ] 
  then
	/sbin/stop codeshelf > /dev/null
        sleep 3
	cd /opt/codeshelf/engine
	rm -rf lib
	cp /home/deploy/server.codeshelf.jar .
	tar -xzf /home/deploy/lib.tgz
	chown -R codeshelf:codeshelf *
	/sbin/start codeshelf > /dev/null

	cp /home/deploy/build.txt /opt/codeshelf
	rm /home/deploy/deploy.engine
fi

if [ -f /home/deploy/deploy.webapp ] 
  then
	cd /opt/codeshelf/web/app
	rm -rf *
	tar -xzf /home/deploy/web_app.tgz
	cp /etc/codeshelf/websocket.addr.json .
	chown -R codeshelf:codeshelf *

	cp /home/deploy/buildweb.txt /opt/codeshelf
	rm /home/deploy/deploy.webapp
fi

