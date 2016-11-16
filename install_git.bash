#!/bin/bash
#
#  install_git.bash:  install the git+github-based software updating system
#
#    J. Hull -- 9/18/18 v.1.0 firefox patching not implemented
#
#    usage:  log on as dem, run ./install_git.bash in a terminal window
#
#       This script is run once when the git updating system is first 
#    installed on one of he DVC laptops.
#


exec_comm() {
   comm=$1
   echo $comm
   eval $comm
}

mkdircd() {
   dir=$1
   if [ -e $dir ]; then
     echo "$dir is already there"
   else
     exec_comm "mkdir $dir" 
   fi
   cd $dir
   echo "current dir=" `pwd`
}

mkdircd "/home/dem/gitproject"
mkdircd "/home/dem/gitproject/client-code"

# exec_comm "sudo apt-get update"
# exec_comm "sudo apt-get install openssh-server"
# exec_comm "sudo ufw allow 22"

# exec_comm "sudo apt-get install git-all"
exec_comm "sudo apt-get install git"
exec_comm "git config --global core.editor \"vi\""
exec_comm "git init"
exec_comm "git pull https://github.com/demvolctr/client-code master"

exec_comm "sudo chown -R dem /home/dem/gitproject"
exec_comm "sudo chgrp -R dem /home/dem/gitproject"

exec_comm "sudo cp -p rc.local /etc"
exec_comm "sudo chown root /etc/rc.local"
exec_comm "sudo chgrp root /etc/rc.local"

##############################################
# 
# echo "Starting firefox install"
# pids=`ps -C firefox -o pid=`
# exec_comm "sudo kill -9 $pids"
# 
# if [ -e "/home/dem-caller/.mozilla" ]; then
#    exec_comm "sudo --user=\"dem-caller\" mv /home/dem-caller/.mozilla /home/dem-caller/.mozilla.old"
#    exec_comm "sudo --user=\"dem-caller\" cp -rp .mozilla /home/dem-caller"
# fi
# 
# echo -n "Enter machine number: "
# read machine
# export machine
# 
# cat /home/dem-caller/.mozilla/firefox/*default/prefs.js | sed -e "/\"browser.startup.homepage\"/d" >/tmp/firefox_tmp
# echo -n "user_pref(\"browser.startup.homepage\", \"https://demvolctr.org/phone-bank-master/?machine=${machine}" >>/tmp/firefox_tmp
# echo -n $firefox >>/tmp/firefox_tmp
# echo "\");/" >>/tmp/firefox_tmp
# chown dem-caller /tmp/firefox_tmp
# chgrp dem-caller /tmp/firefox_tmp
# chmod 664 /tmp/firefox_tmp
# 
# mv /tmp/firefox_tmp /home/dem-caller/.mozilla/firefox/*default/prefs.js
