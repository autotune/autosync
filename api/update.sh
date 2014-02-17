#!/bin/bash
update()
{
TOKEN=$(cat /root/autosync/tmp/token.txt)
# grab server details
curl -s https://$DATACENTER.servers.api.rackspacecloud.com/v2/$ACCOUNT/servers/detail \
-H "X-Auth-Token: $TOKEN" \
-H "Content-Type: application/json" | python -m json.tool > $DIR/tmp/servers.txt


# show all text between "name" and "ip". Search for group name. Filter for addr. Print ip column. Trim down fluff. Filter internal ips.
cat $DIR/tmp/servers.txt|grep -E -B 51 "$GROUP-"|grep addr|awk '{print $2}'|tr ',"{}' ' '|awk 'NR%3==1'|awk '{print $1}'|sort -nr > $DIR/tmp/slaves.txt
}


