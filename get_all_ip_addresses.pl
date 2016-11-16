#!/usr/bin/perl
#
#  get_all_ip_addresses.pl:  
#
#    Print ip addresses for all the dell hosts on the 103 subnet on STDOUT.
#
#	usage: ./get_all_ip_addresses.pl > ip_addresses
#
#        Jon Hull -- 11/3/16
#

   $Max_host_number = 72;  # highest host number we expect to see.

   $Exclude_this = FALSE;
   $Prefix = "";
   if ($#ARGV == 0) {
      if ($ARGV[0] eq "-exclude-this")  { $Exclude_this = 1; }
      #if ($ARGV[0] eq "-d")  { $Prefix = "dem\@"; }
      #if ($ARGV[0] eq "-dc") { $Prefix = "demcaller\@"; }
   }

   #  get ip address of this laptop
   use Sys::HostAddr;
   $sysaddr  = Sys::HostAddr->new();
   $first_ip = $sysaddr->first_ip();
   $main_ip  = $sysaddr->main_ip();

   $Hosts_found  = 0;

   %host_names = get_host_names();

   #
   #  Print out the list of host names
   #

   for ($i=1; $i<=$Max_host_number; ++$i) {
       if ( exists($host_names{$i}) ) {
           print "$Prefix$host_names{$i}\n";
       }
   }

sub get_host_names {

   print STDERR "Running fping to get list of hosts on 103 subnet\n";
   my(@ip_list)      = `fping -a -q -g 192.168.103.0/24`;
   print STDERR "Finished running fping on 103 subnet\n";

   my(@host_names)   = ();
   my(@ip_addresses) = ();
   my($ip_address);

   #  
   #  Get laptop numbers for each ip address and eliminate any non-Dell
   #    host from the shutdown command.
   #
   foreach $ip_address ( @ip_list ) {
      print STDERR "++";
      chomp($ip_address);
      if ( !($ip_address =~ /192\.168\.\d\d\d\.\d+/) ) {
         print STDERR "Illegal ip address on stdin: $_\n";
         exit(1);
      }
      if ($ip_address eq "192.168.103.1") { 
          next; 
      }
      if ($Exclude_this && 
            ($ip_address eq $first_ip || $ip_address eq $main_ip) ) { 
          # eliminate this host
          next;
      }
      my($comm)      = "ssh $ip_address echo_host 2>&1";
      print STDERR "comm=$comm\n";
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
   print STDERR "\n";

   print STDERR "Found $Hosts_found laptops to rewrite:\n   ";
   print STDERR join(" ", sort { $a <=> $b } @host_names), "\n";

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
      print STDERR "Warning: $num_missing laptops not on 103 subnet:\n   ";
      print STDERR join(" ",@missing_hosts), "\n";
   }

   return( %host_names );
}
