#!/bin/bash
if [ -x /usr/sbin/needrestart ]; then
    state=$(/usr/bin/sudo /usr/sbin/needrestart -b | /bin/grep ^NEEDRESTART-KSTA | /usr/bin/cut -f 2 -d :)

    case ${state} in
    " 1")
    echo "OK - no restart required"
    exit 0
    ;;
    " 0")
    echo "WARNING - restart state is undefined"
    exit 1
    ;;
    " 2")
    echo "CRITICAL - Restart required: ABI update pending"
    exit 2
    ;;
    " 3")
    echo "CRITICAL - Restart required: kernel version update pending"
    exit 2
    ;;
    *)
    echo "UNKNOWN - restart state is unknown"
    exit 3
    ;;
    esac
elif [ -x /usr/share/update-notifier/notify-reboot-required ]; then
        if [ -f /var/run/reboot-required ]; then
            echo "CRITICAL - Restart required"
            exit 2
        else
            echo "OK - no restart required"
            exit 0
        fi
else
    echo "UNKNOWN - no known mechanism to detect if a reboot is required was found"
    exit 3
fi