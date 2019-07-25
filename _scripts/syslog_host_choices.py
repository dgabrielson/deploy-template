#!/usr/bin/env python
from __future__ import unicode_literals, print_function

import json
import os
import sys

def read_provision(provision_filename):
    with open(provision_filename) as f:
        return [l.split('\t') for l in f.readlines()]


def main(provision_filename, django_conf_filename):
    names = [p[0] for p in read_provision(provision_filename)]
    if os.path.exists(django_conf_filename):
        data = json.load(open(django_conf_filename))
    elif os.path.exists(django_conf_filename + '.pre'):
        data = json.load(open(django_conf_filename + '.pre'))
    else:
        print("Django Configuration file *not* found!", file=sys.stderr)
        sys.exit(1)
    data["RSYSLOG_HOST_CHOICES"] = sorted(names)
    return json.dumps(data, indent=4)
    
    
if __name__ == '__main__':
    import sys
    contents = main(sys.argv[1], sys.argv[2])
    with open(sys.argv[2], 'w') as f:
        f.write(contents)
