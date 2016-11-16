#!/bin/bash
echo sv4h1llary | sudo -S -u demcaller /bin/bash -c 'export Xauthority="/var/run/lightdm/root:0"; export DISPLAY=":0"; firefox -no-remote'
