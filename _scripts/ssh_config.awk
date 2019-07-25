#!/usr/bin/awk -f
BEGIN { print "#### begin cluster deploy ssh config ####" }
      { print "Host", $1 }
      { print "    HostName", $1 ".example.com" }
      { print "    User clusteradmin" }
      { print "" }
END   { print "#### end cluster deploy ssh config ####" }

