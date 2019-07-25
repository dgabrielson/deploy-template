#!/bin/bash
service="$1"
state=$(systemctl show -p ActiveState ${service} | cut -f 2 -d =)
#  active, reloading, inactive, failed, activating, deactivating, active
# from http://www.freedesktop.org/wiki/Software/systemd/dbus/

if [ -n "${state}" ]; then
    message="${service} is ${state}"
else
    message="${service} is in an unknown state"
fi

case ${state} in
"active")
echo "OK - ${message}"
exit 0
;;
"reloading")
echo "WARNING - ${message}"
exit 1
;;
"deactivating")
echo "WARNING - ${message}"
exit 1
;;
"inactive")
echo "CRITICAL - ${message}"
exit 2
;;
"failed")
echo "CRITICAL - ${message}"
exit 2
;;
*)
echo "UNKNOWN - ${message}"
exit 3
;;
esac
