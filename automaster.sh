#!/bin/bash
SLAVES="$(cat /root/autosync/tests/slaves.txt)"
# prints ip list under servers in lsyncd.lua
SERVERS="$(sed -n '/servers = {/,$p' /etc/lsyncd.lua|grep [0-9]|grep ,|tr -d ',"'|awk '{print $1}'|sort -nr)"
AUTOSYNC='/root/autosync'
DIR=/root/autosync #todo: actually use DIR variable

# endless fun
for fun in /root/autosync/api/*; do
  source $fun
done

for conf in $DIR/conf/api.conf; do
    source $conf
done

echo $USERNAME

token
images
update

# check if servers are building before adding them to lsyncd
while true;
do
STATUS="$(cat /root/autosync/tmp/servers.txt|grep -E -B 70 -A 50 "$GROUP-"|grep "status"|awk '{print $2}'|tr '", ' ' '|awk '{print $1}')"

   if [[ "$STATUS" == *"BUILD"* ]]; then
      echo "Servers are building."
      update
      exit

   elif [[ "$STATUS" == *"ACTIVE"* ]]; then
      echo "Server builds complete!"
       break
   
   elif [[ "$STATUS" == *""* ]]; then
      echo "No servers in group"
      update
      # erase existing lsyncd server ips
      printf "$(sed -r -i.bak '/("[0-9])\.*/d' /etc/lsyncd.lua)"
      exit
   
   else
      echo "Unknown error!"
      update
   fi
done 

# add servers to lsyncd

if [ "$SERVERS" != "$SLAVES" ]
   then 
      echo "Slaves not equal. Adding..."
      # erase existing lsyncd server ips
      printf "$(sed -r -i.bak '/("[0-9])\.*/d' /etc/lsyncd.lua)"
      # convert this to for loop?
      a=1
      b=`wc -l < /root/autosync/tests/slaves.txt`
      while [ $a -le $b ]
         do
         cmd=""
         for j in "$(sed -n "$a"p "/root/autosync/tests/slaves.txt")"; do
           echo "$(sed -i -e "/^servers = {$/a\     \""${j}"\", " /etc/lsyncd.lua)"
	 done
         a=$(( $a + 1))
         # to avoid any issues on default install. For chef, uses lsyncd.lua 
         cp /etc/lsyncd.lua /etc/lsyncd.conf
         service lsyncd restart
      done
   else
      echo "All good!"
fi
