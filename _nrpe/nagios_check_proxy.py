#!/usr/bin/python
# vi:ts=4:noet

#
# Nagios2 HTTP proxy test
#
# usage: check_http_proxy --proxy=proxy:port --auth=user:pass --url=url --timeout=10 --warntime=5 --expect=content
#
# Response codes: 0(OK), 1(WARNING), 2(CRITICAL), 3(UNKNOWN)
# Output: one line on stdout
#
# Copyright (C) 2011 Bradley Dean <bjdean@bjdean.id.au>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import sys
import getopt
import time
import urllib2
import socket

def get_cmdline_cfg():
	try:
		opts, args = getopt.getopt(
			sys.argv[1:],
			"p:a:t:w:e:u:",
			["proxy=", "auth=", "timeout=", "warntime=", "expect=", "url="]
		)
	except getopt.GetoptError, err:
		report_unknown("SCRIPT CALLING ERROR: {0}".format(str(err)))

	### Build cfg dictionary
	cfg = {}
	for o, a in opts:
		if o in ("-p", "--proxy"):
			cfg["proxy"] = a
		elif o in ("-a","--auth"):
			cfg["auth"] = a
		elif o in ("-t","--timeout"):
			cfg["timeout"] = float(a)
		elif o in ("-w","--warntime"):
			cfg["warntime"] = float(a)
		elif o in ("-e","--expect"):
			cfg["expect"] = a
		elif o in ("-u","--url"):
			cfg["url"] = a

	# These are required
	for req_param in ("url", "proxy"):
		if req_param not in cfg:
			report_unknown("Missing parameter: {0}".format(req_param))

	return cfg

def test_proxy(cfg):
	# Set up for request (use cred@proxy form because this bypasses knowing the realm)
	if "auth" in cfg:
		proxy_url = "http://{auth}@{proxy}/".format(**cfg)
	else:
		proxy_url = "http://{proxy}/".format(**cfg)
	proxy_handler = urllib2.ProxyHandler({ 'http' : proxy_url })
	opener = urllib2.build_opener(proxy_handler)
	if "timeout" in cfg:
		response = opener.open(cfg["url"], None, cfg["timeout"])
	else:
		response = opener.open(cfg["url"])
	return response

def report_ok(msg):
	print "PROXY OK - {0}".format(msg)
	sys.exit(0)

def report_warning(msg):
	print "PROXY WARNING - {0}".format(msg)
	sys.exit(1)

def report_critical(msg):
	print "PROXY CRITICAL - {0}".format(msg)
	sys.exit(2)

def report_unknown(msg):
	print "PROXY UNKNOWN - {0}".format(msg)
	sys.exit(3)

if __name__ == '__main__':
	cfg = get_cmdline_cfg()

	start_time = time.time()
	try:
		response = test_proxy(cfg)
	except urllib2.URLError as e:
		if hasattr(e,"reason") and isinstance(e.reason, socket.timeout):
			report_critical("Timed out (over {timeout:.2f}s)".format(**cfg))
		else:
			report_critical("Request failed ({0})".format(e))
	except Exception as e:
		report_unknown("Request failed: ({0})".format(`e`))
	end_time = time.time()
	duration = end_time - start_time

	# Check content
	if "expect" in cfg:
		if response.read().find(cfg["expect"]) == -1:
			report_critical("Failed content check ({expect})".format(**cfg))
			
	# Check warning time
	if "warntime" in cfg:
		if duration >= cfg["warntime"]:
			report_warning("Over warning time ({0:.2f}s >= {warntime:.2f}s)".format(duration, **cfg))

	report_ok("Request return in {0:.2f} seconds".format(duration))
