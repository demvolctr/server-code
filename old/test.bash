#!/bin/bash
if [ $# -ne 2 ]; then
   echo "You gotta gimme the from and to passwords on the command line"
   exit
else
   from=$1
   to=$2
   echo from=$from to=$to
fi

echo "Changing passwords from=" $from " to=" $to

echo -n "Enter YES when you are ready to shutdown ALL laptops: "
read response
if [ $response == "YES" ]; then
   echo "Shutting down"
else
   echo $response
   echo "You didnt enter YES so Im gonna do nothing"
fi 

