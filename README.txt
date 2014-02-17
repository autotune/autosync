The installer will:

install master cron job,
create a master image,
install slave cron job,
create golden slave with slave cron job
create Auto Scale group with slave. 


If on the slave: 
run a script that checks each minute if the ip address has changed. 
If the ip address has changed, 
grab the public key from the master so the slave can SSH into the master, 
add the master to authorized_keys, 
then send its new IP address up to the master. 

If on the master:

check every minute for autoscale/tests/slaves.txt
if there is a change, 
replace server section in lsyncd with fresh slate
replace with new set of IPs (gotta love sed!)
restart lsync.

License: GPL-V2 (http://choosealicense.com/licenses/gpl-v2/)
Author: Brian Adams

