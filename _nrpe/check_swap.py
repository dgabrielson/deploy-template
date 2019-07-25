#!/usr/bin/env python3
"""
nrpecheck
Provides the NrpeCheck base class for defining NRPE checks in python.
------------------------------------
import sys
from nrpecheck import NrpeCheck
class HelloCheck(NrpeCheck):
    '''
    A simple example.
    '''
    def check(self):
        self.status = self.OK   # or self.WARNING or self.CRITICAL
        # output and perfdata can be single or multi-line.
        self.output = "Hello World"
        self.perfdata = sys.version

if __name__ == '__main__':
    HelloCheck().run()
"""
# Copyright 2018 Dave Gabrielson <dave.gabrielson@gmail.com>.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys

class NrpeCheck(object):
    """
    Base class for running NRPE checks.
    Reference: https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/pluginapi.html
    """
    OK = 0
    WARNING = 1
    CRITICAL = 2
    UNKNOWN = 3

    MAX_MESSAGE_LENGTH = 4096


    def __init__(self, *args, **kwargs):
        self.status = None
        self.output = None
        self.perfdata = None


    def format_message(self):
        """
        Construct the appropriate output message based on strings
        ``self.output`` and ``self.perfdata``.
        """
        if self.output is None:
            self.output = ''
        if self.perfdata is None:
            self.perfdata = ''

        output_lines = self.output.split('\n')
        perfdata_lines = self.perfdata.split('\n')

        message = output_lines[0]
        if perfdata_lines[0]:
            message += u'|' + perfdata_lines[0]
        if output_lines[1:] or perfdata_lines[1:]:
            message += u'\n'
        if output_lines[1:]:
            message += u'\n'.join(output_lines[1:])
        if perfdata_lines[1:]:
            message += u'|' + u'\n'.join(perfdata_lines[1:])
        return message


    def check(self):
        """
        Do the check.
        Set ``self.status`` to one of ``NrpeCheck.OK``, ``NrpeCheck.WARNING``,
        or ``NrpeCheck.CRITICAL``.
        Set ``self.output`` and ``self.perfdata`` as relevant single or
        multi-line strings as needed.
        """
        raise RuntimeError("Subclasses must define the check() method.")


    def run(self):
        """
        Run the check and return appropriately.
        """
        self.check()
        if self.status not in [NrpeCheck.OK, NrpeCheck.WARNING, NrpeCheck.CRITICAL]:
            self.status = NrpeCheck.UNKNOWN
        sys.stdout.write(self.format_message()[:self.MAX_MESSAGE_LENGTH])
        sys.exit(self.status)


### Actual check begins here
import argparse
import subprocess

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


def _safe_int(s):
    try:
        return int(s)
    except ValueError:
        return s


class SwapUsageCheck(NrpeCheck):
    '''
    A swap usage check for linux
    '''

    def _get_stats(self):
        cmd = ['/sbin/swapon', '--bytes', '--show', '-e', '--raw', ]
        output = _run(cmd, report_errors=False)
        if output is None:
            return None
        lines = output.split('\n')
        headers = lines[0].strip().split()
        data = [[_safe_int(e) for e in l.strip().split()] for l in lines[1:]]
        stats = [dict(zip(headers, row)) for row in data]
        return stats

    def _get_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('-w', '--warn', type=float, default=10.0,
                            help='Set the warning usage level')
        parser.add_argument('-c', '--crit', type=float, default=50.0,
                            help='Set the critical usage level')
        args = parser.parse_args()
        # assign all args variables to self
        for key, value in vars(args).items():
            setattr(self, key, value)


    def check(self):
        self._get_args()

        stats = self._get_stats()
        if not stats:
            self.status = self.CRITICAL
            self.output = 'No swap information available'
            return

        # gather totals
        total_size = 0
        total_used = 0
        for d in stats:
            total_size += d['SIZE']
            total_used += d['USED']
        load = 100. * total_used / total_size
        used_kbytes = total_used / 1024

        self.status = self.OK
        if load >= self.warn:
            self.status = self.WARNING
        if load >= self.crit:
            self.status = self.CRITICAL
        # message and perfdata can be single or multi-line.
        self.output = "Swap usage: %.1f%% (%d kB) in use" % (load, used_kbytes)


if __name__ == '__main__':
    SwapUsageCheck().run()
