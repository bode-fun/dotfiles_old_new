#! /usr/bin/env zsh

function cd() {
    if [[ $# -eq 0 ]]; then
        z
    else
        z "$@"
        la
    fi
}
