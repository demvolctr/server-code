#!/bin/bash
#
#	change_passwords.bash -- change the votebuilder passwords
#   on all the Dell laptops on the 103 subnet.
#
#      usage:  ./change_passwords 'old password'  'new password'
#
#      note:  passwords MUST be surrounded by single quotes.
#
#                   Jon Hull -- 11/5/16
#

if [ $# -ne 2 ]; then
   echo "You gotta gimme the from and to passwords on the command line"
   exit
else
   from=$1
   to=$2
   echo from=$from to=$to
fi

./get_all_ip_addresses.pl        > /tmp/ips
sed 's/^/dem@/'       /tmp/ips > /tmp/dem_ips
sed 's/^/demcaller@/' /tmp/ips > /tmp/demcaller_ips

echo "Refreshing displays"
parallel-ssh -i -l demcaller -h /tmp/demcaller_ips "refresh_display.bash"
sleep 2

echo "Killing all the firefoxes"
parallel-ssh -i -l demcaller -h /tmp/demcaller_ips "kill_firefox.pl"

echo -n "Enter YES when you are ready to rewrite the passwords on ALL laptops: "
read response
if [ $response == "YES" ]; then
   echo "Changing passwords from=" $from " to=" $to
   parallel-ssh -i -l demcaller -h /tmp/demcaller_ips "rewrite_prefs.pl '$from' '$to'"
else
   echo "You didnt enter YES so Im gonna do nothing"
fi

echo "Pausing for 30 seconds before restarting firefox"
sleep 30
parallel-ssh -i -l demcaller -h /tmp/demcaller_ips "start_firefox.bash"
