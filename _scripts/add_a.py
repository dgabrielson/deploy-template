#!/usr/bin/env python
from __future__ import unicode_literals, print_function

import sys

def usage():
    if len(sys.argv) not in [3, 4]:
        print('Usage: {} <etc-hosts> <a.conf> [domain]')
        sys.exit(1)
    result = sys.argv[1:3]
    result.append(sys.argv[3] if len(sys.argv) == 4 else None)
    return result


def read_a_manual(a_manual_f, domain):
    results = {}
    with open(a_manual_f) as f:
        for line in f:
            if line.strip() and not line.strip().startswith('#'):
                parts = line.strip().split(None)
                remaining = []
                for p in parts[1:]:
                    if '.' not in p and domain is not None:
                        remaining.append(p + '.' + domain)
                    remaining.append(p)
                results[parts[0]] = remaining
    return results


def _ip_addr_key(r):
    return [int(e) for e in r.split('.')]


def do_a_manual_augment(hosts_f, a_manual_f, domain):
    a_maps = read_a_manual(a_manual_f, domain)
    with open(hosts_f) as f:
        for line in f:
            l = line.rstrip()
            parts = line.strip().split()
            if parts[0][0] != '#':
                a_maps[parts[0]] = parts[1:]
    results = []
    for k in sorted(a_maps, key=_ip_addr_key):
        results.append(k + '\t' + '\t'.join(a_maps[k]))
    return '\n'.join(results)


def main():
    hosts_f, cnames_f, domain = usage()
    print(do_a_manual_augment(hosts_f, cnames_f, domain))


if __name__ == '__main__':
    main()
