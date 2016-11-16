#!/bin/bash

from=$1
to=$2

echo from=$from to=$to

./get_all_ip_addresses.pl        > /tmp/ips
sed 's/^/dem@/'       /tmp/ips > /tmp/dem_ips
sed 's/^/demcaller@/' /tmp/ips > /tmp/demcaller_ips

com1="parallel-ssh -i -l demcaller -h /tmp/demcaller_ips \"refresh_display.bash\""
echo $com1
$com1
sleep 2
com2="parallel-ssh -i -l demcaller -h /tmp/demcaller_ips \"kill_firefox.pl\""
echo $com2
$com2
#sleep 30
#echo $from $to
#com3="parallel-ssh -i -l demcaller -h /tmp/demcaller_ips \"rewrite_prefs.pl '$from' '$to'\""
#echo $com1
#sleep 30
#com4="parallel-ssh -i -l demcaller -h /tmp/demcaller_ips \"start_firefox.bash '$from' '$to'\""
#echo $com3

exit
