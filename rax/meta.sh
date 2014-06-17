#!/bin/sh

RSUSERNAME=`grep ^username ~/.rackspace_cloud_credentials|sed -e 's/^username = //'`
RSAPIKEY=`grep ^api_key ~/.rackspace_cloud_credentials|sed -e 's/^api_key = //'`
echo '{"username":"'$RSUSERNAME'"}'
echo '{"apiKey":"'$RSAPIKEY'"}'
curl -s https://identity.api.rackspacecloud.com/v2.0/tokens \
     -X 'POST' \
       -d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$RSUSERNAME'" , "apiKey":"'$RSAPIKEY'"}}}' \
       -H "Content-Type: application/json" | python -m json.tool

