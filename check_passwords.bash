#!/bin/bash

./get_all_ip_addresses.pl > /tmp/ips_check

parallel-ssh -l demcaller -i -h /tmp/ips_check "autofill_check.pl .mozilla/firefox/*.default/prefs.js | grep votebuilder|grep Password"
