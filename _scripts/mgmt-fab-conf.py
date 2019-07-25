#!/usr/bin/env python

import json
import os
import sys
import subprocess

################################################################

def AESencrypt(password, plaintext, base64=True):
    """
    AESencrypt(password, plaintext, base64=True) -> ciphertext

    Encrypt ``plaintext`` with ``password``.
    """
    import hashlib
    import os

    try:
        from Crypto.Cipher import AES
    except ImportError:
        print 'The function AESencrypt() requires pycrypto.'
        sys.exit(1)

    SALT_LENGTH = 32
    DERIVATION_ROUNDS=1337
    BLOCK_SIZE = 16
    KEY_SIZE = 32
    MODE = AES.MODE_CBC

    if password is None:
        password = ''
    salt = os.urandom(SALT_LENGTH)
    iv = os.urandom(BLOCK_SIZE)

    paddingLength = 16 - (len(plaintext) % 16)
    paddedPlaintext = plaintext+chr(paddingLength)*paddingLength
    derivedKey = password
    for i in range(0,DERIVATION_ROUNDS):
        derivedKey = hashlib.sha256(derivedKey+salt).digest()
    derivedKey = derivedKey[:KEY_SIZE]
    cipherSpec = AES.new(derivedKey, MODE, iv)
    ciphertext = cipherSpec.encrypt(paddedPlaintext)
    ciphertext = ciphertext + iv + salt
    if base64:
        import base64
        return base64.b64encode(ciphertext)
    else:
        return ciphertext.encode("hex")


################################################################

def _run(cmd, report_errors=True):
    try:
        if not report_errors:
            stderr = open('/dev/null', 'w')
        else:
            stderr = None
        output = subprocess.check_output(cmd, stderr=stderr).strip()
        if isinstance(output, bytes):
            output = output.decode('utf-8')
        return output
    except subprocess.CalledProcessError as e:
        if report_errors:
            sys.stderr.write('{}\n'.format(e))
        return None
    except OSError as e:
        if report_errors:
            sys.stderr.write('OSError: {}\n'.format(e))
        return None

##############################################################

def get_output_file(args):
    if args.output_file:
        f = open(args.output_file, 'w')
    else:
        f = sys.stdout
    return f

##############################################################

def get_input_file(args):
    if args.input_file:
        f = open(args.input_file)
    else:
        f = sys.stdin
    return f

##############################################################

def write_output(args, s):
    with get_output_file(args) as f:
        f.write(s)
        if f is sys.stdout:
            f.write('\n')

##############################################################

def _fix_default_domain(default_domain):
    if default_domain is None:
        default_domain = '.example.com'
    if not default_domain.startswith('.'):
        default_domain = '.' + default_domain
    return default_domain

##############################################################

def _construct_host_string(username, hostname, default_domain, port=None):
    if default_domain:
        hostname += default_domain
    if username:
        host_string = username + '@' + hostname
    else:
        host_string = hostname
    if port is not None:
        host_string += ':{}'.format(port)
    return host_string

##############################################################

def _get_sshd_port(host):
    return None
    # fn = '../' + host + '/settings.sh'
    # if not os.path.exists(fn):
    #     return None
    # cmd = ['grep',  '^SSHD_PORT=', fn]
    # output = _run(cmd, report_errors=False)
    # value = None
    # if output is not None:
    #     value = output.strip().split('=', 1)[1]
    #     if value and value[0] in ["'", '"']:
    #         value = value[1:-1]
    # return value

##############################################################

def make_fabric_conf(f, username, default_domain, hosts=None, roles=None):
    """
    Generate fabric conf from input file ``f``.
    """
    results = {}

    if hosts is None:
        hosts = {}
    if roles is None:
        roles = {}

    def item_action(item):
        """
        Each ``item`` is a cluster.conf tuple.
            ``item[0]``: hostname
            ``item[1]``: mac address
            ``item[2]``: ip address

        """
        hostname, mac_address, ip_address  = item[:3]
        sshd_port = _get_sshd_port(hostname)
        name = hostname
        host_string = _construct_host_string(username, hostname, default_domain, port=sshd_port)
        flag_slugs = ['all', ]
        for f in flag_slugs:
            if f not in roles:
                roles[f] = []
            roles[f].append(host_string)

        hosts[host_string] = {'username': username,
                              'name': name,
                              'roles': flag_slugs,
                              'mac_address': mac_address,
                              'hostname': hostname,
                              'default_host_string': host_string,
                              }
        # END item_action

    for line in f.readlines():
        item_action(line.split('\t'))

    results['hosts'] = hosts
    results['roles'] = roles

    return results

##############################################################

def cli_fabric_conf(args):
    """
    Command line to generate fabric conf from cluster.conf file.
    """
    p = None
    args.default_domain = _fix_default_domain(args.default_domain)

    def _parse_host_arg(arg):
        host = None
        username = args.username
        password = None
        if '@' not in arg:
            host = arg
        else:
            first, host = arg.split('@', 1)
            if ':' not in first:
                username = first
            else:
                username, password = first.split(':', 1)
        return username, password, host

    def _parse_role_arg(arg):
        role_name, host_list_s = arg.split(':', 1)
        host_list_p = [_parse_host_arg(h) for h in host_list_s.split()]
        host_list = [_construct_host_string(u, h, args.default_domain, port=_get_sshd_port(h))
                     for u, p, h in host_list_p]
        return role_name, host_list


    host_overrides = [_parse_host_arg(h) for h in args.host]
    additional_roles = dict([_parse_role_arg(r) for r in args.role])

    if args.password:
        import getpass
        while True:
            p0 = getpass.getpass(prompt='Default password for all connections: ')
            p1 = getpass.getpass(prompt='                             confirm: ')
            if p0 == p1:
                p = p0
                break
            print 'Password do not match, try again.'
            print
        p = AESencrypt(args.key, p)

    f = get_input_file(args)
    data = make_fabric_conf(f, args.username, args.default_domain, roles=additional_roles)
    if args.password:
        data['password-check'] = AESencrypt(args.key, 'password-check')
        data['default-password'] = p

    host_string_map = {h.split('@', 1)[-1] if '@' in h else h:h for h in data["hosts"]}
    for u,p,h in host_overrides:
        if h not in host_string_map:
            hkey = h
            if u:
                hkey = u + '@' + h
            host_string_map[h] = hkey
        key = host_string_map[h]
        if key not in data["hosts"]:
            hostname = h + args.default_domain
            data["hosts"][key] = {"name": h,
                                  'default_host_string': key,
                                  'hostname': hostname,
                                  }
        if u:
            data["hosts"][key]['username'] = u
            if '@' in data["hosts"][key]['default_host_string']:
                host = data["hosts"][key]['default_host_string'].split('@', 1)[-1]
            else:
                host = data["hosts"][key]['default_host_string']
            data["hosts"][key]['default_host_string'] = u + '@' + host
        if p:
            data["hosts"][key]["password"] = AESencrypt(args.key, p)

    write_output(args, json.dumps(data, indent=4))

##############################################################

def main():
    """
    Called when running as a script.
    """
    # Fix piping and redirection:
    # https://wiki.python.org/moin/PrintFails#print.2C_write_and_Unicode_in_pre-3.0_Python
    if sys.stdout.encoding is None:
        import codecs
        import locale
        # Wrap sys.stdout into a StreamWriter to allow writing unicode.
        sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)

    from argparse import ArgumentParser
    parser = ArgumentParser(description="Generate mgmt-fab config file")

    parser.add_argument('-d', '--domain', dest='default_domain',
                   help='Default domain for DDNS hosts')
    parser.add_argument('-o', '--output', dest='output_file',
                   help='Specify an output file')
    parser.add_argument('-u', '--username',
                   help='Provide a default username for all connections')
    parser.add_argument('-p', '--password', action='store_true',
                   help='Provide a default password for all connections')
    parser.add_argument('-k', '--key',
                   help='Provide a key for encrypting passwords')
    parser.add_argument('--host', action='append', default=[],
                   help='Provide alternate username/password info for a host.  Use [username[:password]@]name')
    parser.add_argument('--role', action='append', default=[],
                   help='Provide additional role definitions.  Use "rolename:[username@]name name ..."')
    parser.add_argument('input_file', nargs = '?', default=None,
                    help="Specify input pre-proivision file.")


    args = parser.parse_args()
    cli_fabric_conf(args)

##############################################################

if __name__ == '__main__':
    main()

##############################################################
