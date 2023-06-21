#!/bin/bash

function help {
    echo "Toggle macOS sleep prevention."
    echo
    echo "Syntax: sleepctl {allow|disallow}"
    echo "Params:"
    echo "  allow     Allow sleep."
    echo "  disallow  Disallow sleep."
    echo
}

function allow {
    sudo pmset -c sleep 0
    sudo pmset -c disablesleep 0
    echo Sleep allowed
}

function disallow {
    sudo pmset -c sleep 0
    sudo pmset -c disablesleep 1
    echo Sleep disallowed
}

if [[ $1 == "allow" ]]; then
    allow
elif [[ $1 == "disallow" ]]; then
    disallow
else
    help
fi
