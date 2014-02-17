# set number and gg are your friends, 
# as well shift+v (highlight), yy (copy), and p (paste)

# tmp files used to make slave and master self-aware

if [ ! -d /root/autosync/tmp ];
then
    mkdir /root/autosync/tmp
    touch /root/autosync/tmp/token.txt
    touch /root/autosync/tmp/auth.txt
    touch /root/autosync/tmp/lastip.txt
    touch /root/autosync/tmp/images.txt
    touch /root/autosync/tmp/imgstatus.txt
    touch /root/autosync/tmp/lastip.txt
    touch /root/autosync/tmp/servers.txt
    touch /root/autosync/tests/slaves.txt
    touch /root/autosync/tmp/slave.tmp
    touch /root/autosync/tmp/masterimg.txt
    touch /root/autosync/tmp/slaveimg.txt
    touch /root/autosync/tmp/autoscale.tmp
    touch /root/autosync/tmp/group.txt
    cat /etc/cron.d/0hourly|head -n4 > /etc/cron.d/autoslave 

    # cron will ignore without space at the end
    echo "" >> /etc/cron.d/autoslave
    
fi

if [ ! -d "/root/.ssh" ];
then
   mkdir /root/.ssh
fi

if [ ! -d "/root/.ssh/id_rsa.pub" ];
then 
   touch /root/.ssh/authorized_keys2
   ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
   ssh-keygen -y -f /root/.ssh/id_rsa > /root/.ssh/id_rsa.pub
   cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys2

elif [ ! -e "/root/.ssh/authorized_key2" ]
then
   touch /root/.ssh/authorized_keys2
   cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys2
fi

DIR=/root/autosync

# endless fun
for fun in $DIR/api/*; do
  source $fun
done

# touche httpd  
if [ -e $DIR/conf/api.conf ];
then
   for conf in $DIR/conf/api.conf; do
   source $conf
done
fi

if [ ! -e $DIR/conf/api.conf ]; 
then
   touch $DIR/conf/api.conf 

# todo: turn this into an actual menu
   echo "Username: "
   read USERNAME

   echo "Account: "
   read ACCOUNT

   echo "APIKey: "
   read APIKEY

   echo "Prefered group name: "
   read GROUP

   echo "Load Balancer ID: "
   read LBID

   echo "Datacenter: "
   read DATACENTER
   
   echo "USERNAME=$USERNAME" >> $DIR/conf/api.conf
   echo "ACCOUNT=$ACCOUNT" >> $DIR/conf/api.conf
   echo "APIKEY=$APIKEY" >> $DIR/conf/api.conf
   echo "GROUP=$GROUP" >> $DIR/conf/api.conf
   echo "LBID=$LBID" >> $DIR/conf/api.conf
   echo "DATACENTER=$DATACENTER" >> $DIR/conf/api.conf
fi

AUTOSYNC='/root/autosync'
# cat variables won't actually run correctly outside the functions. Included for readability
# TOKEN=$(cat /root/autosync/tmp/token.txt)
CURRENTIP=$(ifconfig eth1|grep 'inet addr:'|awk '{print $2}'|tr 'addr: ' ' '|awk '{print $1}') 
# CRNTIMG=$(cat /root/autosync/tmp/servers.txt|grep "$CURRENTIP" -E -A 50|grep id|awk '{print $2}'| tr ',"' ' '|awk '{print $1}'|head -n2|tail -n1)
# CRNTSRV=$(cat /root/autosync/tmp/servers.txt|grep $CURRENTIP -A 50|grep id|head -n2|tail -n1|awk '{print $2}'|tr '",' ' '|awk '{print $1}')
IPLOC="/root/autosync/tmp/lastip.txt"
MASTERIP=$(cat "/root/autosync/tmp/lastip.txt")
GROUPMASTER="$GROUP""Master"
GROUPSLAVE="$GROUP""Slave"
# MASTERIMG=$(cat /root/autosync/tmp/images.txt|grep -E -B 70 -A 50 "$GROUP""Master"|grep "name"|awk '{print $2}'|tr '", '     ' '|awk '{print $1}'|head -n2|tail -n1)
# SLAVEIMG=$(cat /root/autosync/tmp/images.txt|grep -E -B 70 -A 50 "$GROUP""Slave"|grep "name"|awk '{print $2}'|tr '", '     ' '|awk '{print $1}'|head -n2|tail -n1)
# AUTOSLAVEID=$(cat /root/autosync/tmp/images.txt|grep -E -B 70 -A 50 "$GROUP""Slave"|grep "id"|head -n1|awk '{print $2}'|tr '",' ' '|awk '{print $1}')

echo "$GROUP" > /root/autosync/tmp/group.txt

######## BEGIN SCRIPT ########
echo "Updating user token..."
token
echo "Updating server list..."
update
echo "Updating image list..."
images


echo $CURRENTIP > /root/autosync/tmp/lastip.txt

# only add the master image once in this script.

if [ "$GROUPMASTER" != "$MASTERIMG" ]; 
   then
      echo "$GROUPMASTER does not exist!"
      echo "Adding master..."
      imgMaster
      images
   
   while true;
   do 
   images
   STATUS=$(cat /root/autosync/tmp/images.txt|grep -E -B 70 -A 50 "$GROUPMASTER"|grep "status"|awk '{print $2}'|tr '", ' ' '|awk '{print $1}'|head -n1)

   if [ "$STATUS" == "overLimit" ]
   then
   echo "Overlimit Error!"
      break

   elif [ "$STATUS" == "SAVING" ]
   then
      echo "[$(date)]" "Master image is saving..." 
       images
       sleep 5

   elif [ "$STATUS" == "ACTIVE" ]
   then
      echo "Image is active, we good!"
      break;
      
   else
      echo "$STATUS"
      exit
   fi
done 
 
elif [ "$GROUPMASTER" == "$MASTERIMG" ]
   then
   echo "Script uses '\$GROUPMaster' as name. Make sure it's unique."
   echo "$GROUPMaster"
else
   echo "Something went wrong."
   exit 
fi

images

# if slave exists than we are slave. If master exists, then master. 

# create seperate slave image

if [ "$GROUPSLAVE" == "$SLAVEIMG" ];
then
    echo "Slave image exists"
    echo "Image naame is $SLAVEIMG"
    rm -fr /root/autosync/tmp/autoscale.tmp
    rm -fr /etc/cron.d/slave
    rm -fr /etc/cron.d/master
    images
    exit
sleep 5

elif [ "$GROUPSLAVE" != "$SLAVEIMG" ]
then
    sleep 10  
    echo "$GROUPSLAVE doesn't exist"
    echo "Adding slave..."
    echo "install-crontab"
    /bin/cp -f /etc/cron.d/0hourly /etc/cron.d/autoslave
    echo "*/1 * * * * root /root/autosync/autoslave.sh" >> /etc/cron.d/autoslave
    echo "" >> /etc/cron.d/autoslave
    rm -fr /etc/cron.d/master
    echo $MASTERIP > /root/autosync/tmp/lastip.txt
    echo "Done!"
    imgSlave
while true;
   do
   images
   STATUS=$(cat /root/autosync/tmp/images.txt|grep -E -B 70 -A 50 "$GROUP"Slave""|grep "status"|awk '{print $2}'|tr '", ' ' '|awk '{print $1}'|head -n1)

   if [ "$STATUS" == "overLimit" ]
   then
      echo "Overlimit Error!"
      break

   elif [ "$STATUS" == "SAVING" ]
   then
      echo "[$(date)]" "Slave image is saving..." 
       images
       sleep 5
   elif [ "$STATUS" == "ACTIVE" ]
   then
      echo "Image is active, we good!"
      break;

   else
      echo "$STATUS"
      continue # continue the while loop or we get 2 autoScale groups
   fi
done
else
    echo "Something went wrong."
    exit
fi

if [ ! -e "/root/autosync/tmp/master.tmp" ];
then
   echo "Installing master cron..."
   /bin/cp -f /etc/cron.d/0hourly /etc/cron.d/master
   echo "*/1 * * * * root /root/autosync/automaster.sh" >> /etc/cron.d/master
   echo "" >> /etc/cron.d/master
   rm -fr /etc/cron.d/autoslave
   touch /root/autosync/tmp/autoscale.tmp
fi

# if [ -e "/root/autosync/tmp/autoscale.tmp" ];
#    then
echo "Creating Auto Scale Group from image "$GROUP""Slave""
#rm -fr /root/autosync/tmp/autoscale.tmp
autoScale
# fi

echo "Done!" 
varunset


