#!/usr/bin/awk -f
BEGIN { print "#### begin generated hosts ####" }
      { print "define host {" }
      { print "     use         cluster-host" }
      { print "     host_name   " $1 ".example.com" }
      { print "     alias       " $1 }
      { print "     address     " $3 }
      { if ($8) print "     hostgroups  " $8 }
      { print "     }" }
END   { print "#### end generated hosts ####" }
