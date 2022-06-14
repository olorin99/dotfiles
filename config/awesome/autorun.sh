#!/bin/sh

run() {
    if ! pgrep -f "$1" ;
    then
        "$@"&
    fi
}

#SESSION_START = $(last $USER | grep "still logged in" | awk "{print $7}")
#NOW = $(date +"%H:%M")
#if [[ $(date +"%s" -d $SESSION_START) -ge $(date +"%s" -d $NOW) ]] then
#    mpc pause
#fi

run "picom"
run "mpDris2"
