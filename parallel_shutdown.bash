#!/bin/bash
#
#	   parallel_shutdown.bash: refresh the displays, close
#	firefox, and shutdown all the laptops on the 103 subnet.
#		usage: ./parallel_shutdown.bash
#       note: do not use sudo.  You will be prompted to hit 
#	carriage return between steps.
#		Jon Hull -- 11/4/16
#

./get_all_ip_addresses.pl -exclude-this  > /tmp/ips
sed 's/^/dem@/'       /tmp/ips           > /tmp/dem_ips
sed 's/^/demcaller@/' /tmp/ips           > /tmp/demcaller_ips

echo "Refreshing all the displays"
parallel-ssh -i -l demcaller -h /tmp/demcaller_ips "refresh_display.bash"

sleep 2
echo "Closing all the firefoxes"
parallel-ssh -i -l demcaller -h /tmp/demcaller_ips "close_firefox.bash"

echo -n "Enter YES when you are ready to shutdown ALL laptops: "
read response
if [ $response == "YES" ]; then
   echo "Shutting down"
   parallel-ssh -i -l dem -h /tmp/dem_ips 'echo sv4h1llary | sudo -S shutdown -h now'
else
   echo "You didnt enter YES so Im gonna do nothing"
fi
