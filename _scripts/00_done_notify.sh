#!/bin/bash
set -e

SOUND="/System/Library/Sounds/Glass.aiff"
MSG="$1"
if [[ -z ${MSG} ]]; then
    echo "You must supply a notifcation message!"
    exit 1
fi

if which -s terminal-notifier; then
    title="$(basename $(pwd))"
    terminal-notifier -message "$1" -sound "${SOUND}" -title "${title}"
else
    date
    echo "$1"
    if which -s afplay; then
        afplay "${SOUND}"
    fi
fi
