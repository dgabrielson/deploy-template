#!/usr/bin/env python
from __future__ import unicode_literals, print_function

import sys

def usage():
    if len(sys.argv) not in [3, 4]:
        print('Usage: {} <etc-hosts> <cnames.conf> [domain]')
        sys.exit(1)
    result = sys.argv[1:3]
    result.append(sys.argv[3] if len(sys.argv) == 4 else None)
    return result


def read_cnames(cnames_f, domain):
    results = {}
    with open(cnames_f) as f:
        for line in f:
            if line.strip() and not line.strip().startswith('#'):
                parts = line.strip().split(None)
                aliases = []
                for p in parts[1:]:
                    if '.' not in p and domain is not None:
                        aliases.append(p + '.' + domain)
                    aliases.append(p)
                results[parts[0]] = aliases
    return results


def do_cnames_augment(hosts_f, cnames_f, domain):
    aliases = read_cnames(cnames_f, domain)
    results = []
    with open(hosts_f) as f:
        for line in f:
            l = line.rstrip()
            parts = line.strip().split()
            if parts[0][0] != '#' and len(parts) > 1:
                primary_name = parts[1]
                if '.' in primary_name:
                    primary_name = primary_name.split('.', 1)[0]
                if primary_name in aliases:
                    l += '\t' + '\t'.join(aliases[primary_name])
            results.append(l)
    return '\n'.join(results)


def main():
    hosts_f, cnames_f, domain = usage()
    print(do_cnames_augment(hosts_f, cnames_f, domain))


if __name__ == '__main__':
    main()
