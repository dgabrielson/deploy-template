#!/usr/bin/env python
from __future__ import unicode_literals, print_function

import os

from cluster_conf_fmt import CLUSTER_CONF_FMT

FIELDS = {
    'phys-': ['name', 'mac-address', 'ip-address', 'eth-name', 'services', ],
    'unmgd-': ['name', 'mac-address', 'ip-address', 'services', ],
    'virt-': ['name', 'mac-address', 'ip-address', 'phys-host', 'memory', 'disk', 
              'cpu-count', 'services', ], 
    ':output:': CLUSTER_CONF_FMT,
}


def format(data):
    output_fmt = FIELDS[':output:']
    
    def _ip_addr_key(r):
        return [int(e) for e in r.get('ip-address', '0.0.0.0').split('.')]
        
    def _row_format(r):
        values = [r.get(f, 'X') for f in output_fmt]
        return '\t'.join(values)
        
    formatted_rows = [_row_format(row) for row in sorted(data, key=_ip_addr_key)]
    return '\n'.join(formatted_rows)


def read_tab_file(f):
    if not os.path.isfile(f):
        return []
    fields = None
    for key in FIELDS:
        if f.startswith(key):
            fields = FIELDS[key]
    if fields is None:
        assert RuntimeError('Unknown tab file format')
    
    result = []
    with open(f) as fp:
        for line in fp:
            line = line.strip()
            if line.startswith('#'):
                continue
            result.append(dict(zip(fields, line.split())))
    return result



def main(args):
    data = []
    for f in args:
        data.extend(read_tab_file(f))
    return data


if __name__ == '__main__':
    import sys
    print(format(main(sys.argv[1:])))
