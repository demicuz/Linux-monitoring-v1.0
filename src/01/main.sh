#!/usr/bin/env bash

set -e

source num_regexp.sh

if [[ $# != 1 ]] ; then
    echo "error: Wrong number of arguments" >&2; exit 1
elif [[ $1 =~ $re ]] ; then
    echo "error: Input is a number" >&2; exit 1
else
    echo $1
fi
