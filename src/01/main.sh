#!/usr/bin/env bash

set -e

if ! source num_regexp.sh; then
    echo "num_regexp.sh not found" >&2; exit 1
fi

if [[ $# != 1 ]] ; then
    echo "error: Wrong number of arguments" >&2; exit 1
elif [[ $1 =~ $re ]] ; then
    echo "error: Input is a number" >&2; exit 1
else
    echo $1
fi
