# $DIR=/root/autosync

#!/bin/bash
images() {

TOKEN=$(cat /root/autosync/tmp/token.txt)
# grab server details
curl -s https://$DATACENTER.servers.api.rackspacecloud.com/v2/$ACCOUNT/images/detail -H "X-Auth-Token: $TOKEN"|python -m json.tool > $DIR/tmp/images.txt

# show all text between "name" and "ip". Search for group name. Filter for addr. Print ip column. Trim down fluff. Filter internal ips.
cat $DIR/tmp/servers.txt|grep -E -B 51 "$GROUP""-" |grep addr|awk '{print $2}'|tr ',"{}' ' '|awk 'NR%3==1'|awk '{print $1}'|sort -nr > $DIR/tests/slaves.txt

MASTERIMG=$(cat $DIR/tmp/images.txt|grep -E -B 70 -A 50 "$GROUPMASTER"|grep "name"|awk '{print $2}'|tr '", '     ' '|awk '{print $1}'|head -n2|tail -n1)
SLAVEIMG=$(cat $DIR/tmp/images.txt|grep -E -B 70 -A 50 "$GROUPSLAVE"|grep "name"|awk '{print $2}'|tr '", '     ' '|awk '{print $1}'|head -n2|tail -n1)
AUTOSLAVEID=$(cat $DIR/tmp/images.txt|grep -E -B 70 -A 50 "$GROUPSLAVE"|grep "id"|head -n1|awk '{print $2}'|tr     '",' ' '|awk '{print $1}')
}

