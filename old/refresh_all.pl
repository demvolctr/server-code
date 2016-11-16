#!/usr/bin/perl
#
#  refresh_all.pl:  
#
#    Use ssh to refresh the display on every machine.
#
#    This is designed to be run from dvc-dell-57 when logged on 
#    as dem.  
#
#            SUDO IS NOT USED WHEN CALLING THIS SCRIPT.
#
#    This is v. 2.0 that closes Firefox gracefully before shutdown.
#
#	usage: ./refresh_all.pl 
#
#        Jon Hull -- 11/2/16
#

   $Max_host_number = 70;  # highest host number we expect to see.

   #  get ip address of this laptop
   use Sys::HostAddr;
   $sysaddr  = Sys::HostAddr->new();
   $first_ip = $sysaddr->first_ip();
   $main_ip  = $sysaddr->main_ip();

   $Hosts_found  = 0;

   $refresh_comm       = "refresh_display.bash";

   %host_names = get_host_names();

   #
   #  Execute the following ($ssh_comm) after confirmation from keyboard
   #

   print "Type YES (all caps!!!) to confirm rewrite passwords on these PCs\n";
   $response = <STDIN>;
   chomp $response;
   if ($response eq "YES") {
      for ($i=1; $i<=$Max_host_number; ++$i) {
          if ( exists($host_names{$i}) ) {
              print "Refreshing display on laptop $i ip=$host_names{$i}\n";
              call_ssh( $host_names{$i}, "demcaller", $refresh_comm );
          }
       }
   } else {
       print "You didnt type YES in all caps so nothing was done!\n";
   }

sub call_ssh {
   my($ip_address, $user, $command) = @_;
   $ssh_comm = "ssh $user\@$ip_address $command";
   print "ssh command=$ssh_comm\n";
   $ssh_res  = `$ssh_comm`;
   print "res=", $ssh_res,"\n";
}


sub get_host_names {

   print "Running fping to get list of hosts on 103 subnet\n";
   my(@ip_list)      = `fping -a -q -g 192.168.103.0/24`;
   print "Finished running fping on 103 subnet\n";

   my(@host_names)   = ();
   my(@ip_addresses) = ();
   my($ip_address);

   #  
   #  Get laptop numbers for each ip address and eliminate any non-Dell
   #    host from the shutdown command.
   #
   foreach $ip_address ( @ip_list ) {
      # print $ip_address;
      print "++";
      chomp($ip_address);
      if ( !($ip_address =~ /192\.168\.\d\d\d\.\d+/) ) {
         print STDERR "Illegal ip address on stdin: $_\n";
         exit(1);
      }
      if ($ip_address eq "192.168.103.1" || $ip_address eq $first_ip ||
          $ip_address eq $main_ip) { # eliminate the router and this host
         next;
      }
      my($comm)      = "ssh $ip_address echo_host 2>&1";
      my($host_name) = `$comm`;
      if ($?) {  # problem with ssh call
         print STDERR "this command failed: $comm\n";
         print STDERR "  This could be a non-Dell host on the 103 subnet.\n";
         next;
      }
      chomp( $host_name );
      push( @ip_addresses, $ip_address);
      push( @host_names, $host_name);
      ++$Hosts_found;
   }
   print "\n";

   print "Found $Hosts_found laptops to rewrite:\n   ";
   print join(" ", sort { $a <=> $b } @host_names), "\n";

   #
   #  Find list of laptops (hosts) that fping did not see
   #
   for ($i=0; $i <= $#host_names; ++$i) {
      $host_names{ $host_names[$i] } = $ip_addresses[$i];
   }
   my(@missing_hosts) = ();
   my($num_missing)   = 0;

   for ($i=1; $i<=$Max_host_number; ++$i) {
      if (! exists($host_names{$i})) {
         push( @missing_hosts, $i );
         ++$num_missing;
      }
   }
   if ($num_missing > 0) {
      print "Warning: $num_missing laptops not found on the 103 subnet:\n   ";
      print join(" ",@missing_hosts), "\n";
   }

   return( %host_names );
}
