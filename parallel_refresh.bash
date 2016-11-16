#!/bin/bash
#
#	   parallel_refresh.bash: refresh the displays on
#	all the laptops on the 103 subnet.
#		usage: ./parallel_refresh.bash
#       note: do not use sudo.  
#		Jon Hull -- 11/4/16
#

./get_all_ip_addresses.pl -exclude-this  > /tmp/ips
sed 's/^/demcaller@/'       /tmp/ips           > /tmp/demcaller_ips

echo "Refreshing all the displays"
parallel-ssh -i -l demcaller -h /tmp/demcaller_ips "refresh_display.bash"
