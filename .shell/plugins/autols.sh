#! /usr/bin/sh

zl() {
    if [ $# -eq 0 ]; then
    z
    else
        z "$1"
        la
    fi
}
