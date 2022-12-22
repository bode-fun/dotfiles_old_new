#! /bin/sh

cdls() {
    if [ $# -eq 0 ]; then
        cd 
    else
        cd "$1"
        la
    fi
}
