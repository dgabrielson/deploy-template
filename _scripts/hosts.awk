#!/usr/bin/awk -f
BEGIN { print "#### begin generated hosts ####" }
      { print $3 "\t" $1 ".example.com\t" $1}
END   { print "#### end generated hosts ####" }
