#!/usr/bin/awk -f
BEGIN { print "#### begin generated dhcpd reservations ####" }
      { print "host", $1, "{" }
      { print "    hardware ethernet", $2 ";" }
      { print "    fixed-address" , $3 ";" }
      { print "}" }
END   { print "#### end generated  dhcpd reservations ####" }

