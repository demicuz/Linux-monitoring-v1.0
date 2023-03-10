#!/usr/bin/env bash

set -e

if [[ $# != 0 ]] ; then
    echo "error: Arguments are not supported" >&2; exit 1
fi

source stats.sh

echo "$stats"
filename="$(date +"%d_%m_%y_%H_%M_%S").status"
read -rp "Write the output to a log file $filename? [y/N]:" if_log
if [[ $if_log =~ [yY] ]]; then
    echo $stats > $filename
fi
