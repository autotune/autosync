#!/bin/bash
token ()
{

curl -s -d \
"{
\"auth\":
{
\"RAX-KSKEY:apiKeyCredentials\":
{
\"username\":\"$USERNAME\",
\"apiKey\": \"$APIKEY\"}
}
}" \
-H 'Content-Type: application/json' \
'https://identity.api.rackspacecloud.com/v2.0/tokens' | python -m json.tool > $DIR/tmp/auth.txt

# grab auth token
grep "id" $DIR/tmp/auth.txt|awk '{print $2}'|head -n1|tr ',"' ' '|awk '{print $1}'  > $DIR/tmp/token.txt
}

