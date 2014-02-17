#!/bin/bash
MASTER=''
IPLOC="/root/autosync/tmp/lastip.txt"
OLDIP=$(cat $IPLOC)
NEWIP=$(ip route|grep eth1|grep src|awk '{print $9}')

# compare IPs. If different then update list and send to master.

if [ "$OLDIP" != "$NEWIP" ]
then
  echo "Adding new IP..."
  echo $NEWIP > /root/autosync/tmp/lastip.txt
  echo $NEWIP >> /root/autosync/tests/slaves.txt
  ssh-copy-id -i /root/.ssh/id_rsa.pub root@$MASTER
  scp /root/autosync/tests/slaves.txt root@$MASTER:/root/autosync/tests/slaves.txt
  scp -r root@$MASTER:/root/.ssh/id_rsa.pub /root/.ssh/authorized_keys2    
else 
  echo "We're good!"
fi 



