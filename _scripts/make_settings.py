#!/usr/bin/env python
from __future__ import unicode_literals, print_function

import os
import pprint
import subprocess


def format(diff):
    result = ""
    for key, value in diff:
        if key != 'BASH_EXECUTION_STRING':
            value = value.strip("'")
            result += "{} = {}\n".format(key, value)
    return result


def main(f):
    """
    source shell script ``f``, print anything that's different in the 
    environment. 
    
    This only works if ``f`` exports...
    """
    def shell_variable_dict(source=None):
        cmd = "set -o posix ; set"
        if source:
            cmd = 'source "{}"; '.format(f) + cmd
            
        command = ['bash', '-c', cmd]
        proc = subprocess.Popen(command, stdout = subprocess.PIPE)
        result = {}
        for line in proc.stdout:
            (key, _, value) = [e.strip() for e in line.partition("=")]
            result[key] = value

        proc.communicate()
        return result

    before = shell_variable_dict()
    after = shell_variable_dict(f)
    diff = set(before.items()) ^ set(after.items())
    return diff


if __name__ == '__main__':
    import sys
    for arg in sys.argv[1:]:
        print(format(main(arg)))
