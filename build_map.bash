#!/bin/bash
#
#  build_servers.bash:  find Dell servers on the LAN and append them
#   to the config file for clusterssh (cssh).
#
#       Jon Hull - 10/5/16
#

sudo fping -a -g 192.168.103.0/24 |& awk '(NF == 1)' > /tmp/servers.$$
sed -i '/192.168.103.1$/d' /tmp/servers.$$

#sudo nmap -p22 -iL /tmp/$$.fping |\
   #perl fold.pl | grep "(Dell)" | grep "Host is up" |\
   #awk '{ print $5; }' > /tmp/servers.$$

let nservers=`/usr/bin/wc /tmp/servers.$$ | awk '{ print $1; }'`

echo "Found $nservers Dell servers"

sed -i.bak '/servers/d'  /home/dem/.clusterssh/config
sed -i.bak '/clusters/d' /home/dem/.clusterssh/config
awk 'BEGIN { printf "clusters=servers\nservers="; }\
           { printf "%s ",$1; }\
     END   { printf "\n"; }' < /tmp/servers.$$ >> /home/dem/.clusterssh/config

rm /tmp/servers.$$
