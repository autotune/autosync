#$DIR=/root/autosync
#!/bin/bash

# create image from master server
imgMaster()
{

CRNTSRV=$(cat $DIR/tmp/servers.txt|grep $CURRENTIP -A 50|grep id|head -n2|tail -n1|awk '{print $2}'|tr '",' ' '|awk '{print $1}')

# escape all the things.
curl -s https://$DATACENTER.servers.api.rackspacecloud.com/v2/$ACCOUNT/servers/$CRNTSRV/action \
         -X POST \
         -H "X-Auth-Token: $TOKEN" \
         -H "Content-Type: application/json" \
         -d "{\"createImage\": {\"name\": \""$GROUP""Master"\", \"metadata\":
    {\"ImageType\": \"Gold\", \"ImageVersion\": \"2.0\"}}}"|tee $DIR/tmp/imgstatus.txt
}

