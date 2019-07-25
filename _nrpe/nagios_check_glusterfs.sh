#!/bin/bash

# This Nagios script was written against version 3.3 & 3.4 of Gluster.  Older
# versions will most likely not work at all with this monitoring script.
#
# Gluster currently requires elevated permissions to do anything.  In order to
# accommodate this, you need to allow your Nagios user some additional
# permissions via sudo.  The line you want to add will look something like the
# following in /etc/sudoers (or something equivalent):
#
# Defaults:nagios !requiretty
# nagios ALL=(root) NOPASSWD:/usr/sbin/gluster volume status [[\:graph\:]]* detail,/usr/sbin/gluster volume heal [[\:graph\:]]* info
#
# That should give us all the access we need to check the status of any
# currently defined peers and volumes.

# Inspired by a script of Mark Nipper
#
# 2013, Mark Ruys, mark.ruys@peercode.nl

PATH=/sbin:/bin:/usr/sbin:/usr/bin

PROGNAME=$(basename -- $0)
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0.0"

#. $PROGPATH/utils.sh
#! /bin/sh

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

if test -x /usr/bin/printf; then
ECHO=/usr/bin/printf
else
ECHO=echo
fi

print_revision() {
echo "$1 v$2 (nagios-plugins 1.4.13)"
$ECHO "The nagios plugins come with ABSOLUTELY NO WARRANTY. You may redistribute\ncopies of the plugins under the terms of the GNU General Public License.\nFor more information about these matters, see the file named COPYING.\n" | sed -e 's/\n/ /g'
}

support() {
$ECHO "Send email to nagios-users@lists.sourceforge.net if you have questions\nregarding use of this software. To submit patches or suggest improvements,\nsend email to nagiosplug-devel@lists.sourceforge.net.\nPlease include version information with all correspondence (when possible,\nuse output from the --version option of the plugin itself).\n" | sed -e 's/\n/ /g'
}

# parse command line
usage () {
  echo ""
  echo "USAGE: "
  echo "  $PROGNAME -v VOLUME -n BRICKS [-w GB -c GB]"
  echo "     -n BRICKS: number of bricks"
  echo "     -w and -c values in GB"
  exit $STATE_UNKNOWN
}

while getopts "v:n:w:c:" opt; do
  case $opt in
    v) VOLUME=${OPTARG} ;;
    n) BRICKS=${OPTARG} ;;
    w) WARN=${OPTARG} ;;
    c) CRIT=${OPTARG} ;;
    *) usage ;;
  esac
done

if [ -z "${VOLUME}" -o -z "${BRICKS}" ]; then
  usage
fi

Exit () {
	$ECHO "$1: ${2:0}"
	status=STATE_$1
	exit ${!status}
}

# check for commands
for cmd in basename bc awk sudo pidof gluster; do
	if ! type -p "$cmd" >/dev/null; then
		Exit UNKNOWN "$cmd not found"
	fi
done

# check for glusterd (management daemon)
if ! pidof glusterd &>/dev/null; then
	Exit CRITICAL "glusterd management daemon not running"
fi

# check for glusterfsd (brick daemon)
if ! pidof glusterfsd &>/dev/null; then
	Exit CRITICAL "glusterfsd brick daemon not running"
fi

# get volume heal status
heal=0
for entries in $(sudo gluster volume heal ${VOLUME} info | awk '/^Number of entries: /{print $4}'); do
	if [ "$entries" -gt 0 ]; then
		let $((heal+=entries))
	fi
done
if [ "$heal" -gt 0 ]; then
	errors=("${errors[@]}" "$heal unsynched entries")
fi

# get volume status
bricksfound=0
freegb=9999999
shopt -s nullglob
while read -r line; do
	field=($(echo $line))
	case ${field[0]} in
	Brick) 
		brick=${field[@]:2}
		;;
	Disk)
		key=${field[@]:0:3}
		if [ "${key}" = "Disk Space Free" ]; then
			freeunit=${field[@]:4}
			free=${freeunit:0:-2}
			unit=${freeunit#$free}
			if [ "$unit" != "GB" ]; then
				Exit UNKNOWN "unknown disk space size $freeunit"
			fi
			free=$(echo "${free} / 1" | bc -q)
			if [ $free -lt $freegb ]; then
				freegb=$free
			fi
		fi
		;;
	Online)
		online=${field[@]:2}
		if [ "${online}" = "Y" ]; then
			let $((bricksfound++))
		else
			errors=("${errors[@]}" "$brick offline")
		fi
		;;
	esac
done < <(sudo gluster volume status ${VOLUME} detail)

if [ $bricksfound -eq 0 ]; then
	Exit CRITICAL "no bricks found"
elif [ $bricksfound -lt $BRICKS ]; then
	errors=("${errors[@]}" "found $bricksfound bricks, expected $BRICKS ")
fi

if [ -n "$CRIT" -a -n "$WARN" ]; then
	if [ $CRIT -ge $WARN ]; then
		Exit UNKNOWN "critical threshold below warning"
	elif [ $freegb -lt $CRIT ]; then
		Exit CRITICAL "free space ${freegb}GB"
	elif [ $freegb -lt $WARN ]; then
		errors=("${errors[@]}" "free space ${freegb}GB")
	fi
fi

# exit with warning if errors
if [ -n "$errors" ]; then
	sep='; '
	msg=$(printf "${sep}%s" "${errors[@]}")
	msg=${msg:${#sep}}

	Exit WARNING "${msg}"
fi

# exit with no errors
Exit OK "${bricksfound} bricks; free space ${freegb}GB"

