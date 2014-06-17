#!/bin/bash
#
# checks whether deploy user is requesting engine/web upgrade and does it if so

if [ -f /home/deploy/deploy.engine ] 
  then
	stop codeshelf
	cd /opt/codeshelf/engine
	rm -rf lib
	mv /home/deploy/server.codeshelf.jar .
	tar -xzf /home/deploy/lib.tgz
	chown -R codeshelf:codeshelf *
	start codeshelf

	mv /home/deploy/build.txt /opt/codeshelf
	rm /home/deploy/lib.tgz
	rm /home/deploy/server.codeshelf.jar
	rm /home/deploy/deploy.engine
fi

if [ -f /home/deploy/deploy.webapp ] 
  then
	cd /opt/codeshelf/web/app
	rm -rf *
	tar -xzf /home/deploy/web_app.tgz
	cp /etc/codeshelf/websocket.addr.json .
	chown -R codeshelf:codeshelf *

	mv /home/deploy/buildweb.txt /opt/codeshelf
	rm /home/deploy/web_app.tgz
	rm /home/deploy/deploy.webapp
fi

