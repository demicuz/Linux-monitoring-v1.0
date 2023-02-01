#!/usr/bin/env bash

set -e

if ! source stats.sh; then
    echo "stats.sh not found" >&2; exit 1
elif [[ $# != 4 ]]; then
    echo "error: Expected 4 arguments, got $#" >&2; exit 1
fi

# https://linuxconfig.org/how-to-use-arrays-in-bash-script

declare -a font_colors=(
    "\033[0m"  # clear color
    "\033[37m" # white
    "\033[31m" # red
    "\033[32m" # green
    "\033[34m" # blue
    "\033[35m" # purple
    "\033[30m" # black
)

declare -a bg_colors=(
    "\033[0m"  # clear color
    "\033[47m" # white
    "\033[41m" # red
    "\033[42m" # green
    "\033[44m" # blue
    "\033[45m" # purple
    "\033[40m" # black
)

function abort_if_invalid_code {
    if [[ ! $1 =~ ^[1-6]$ ]]; then
        echo "error: Expected a number from 1 to 6, got '$1'" >&2; exit 1
    fi
}

abort_if_invalid_code $1
abort_if_invalid_code $2
abort_if_invalid_code $3
abort_if_invalid_code $4

if [[ $1 == $2 || $3 == $4 ]]; then
    echo "error: Background and font colors are the same" >&2
    echo "Rerun with 6 2 6 3, for example" >&2
    exit 1
fi

# $1 - backgroun of value names (HOSTNAME..)
# $2 - font color of value names (HOSTNAME..)
# $3 - background of values
# $4 - font color of values
echo "$stats" | awk            \
    -v c0="${font_colors[0]}"  \
    -v c1="${bg_colors[$1]}"   \
    -v c2="${font_colors[$2]}" \
    -v c3="${bg_colors[$3]}"   \
    -v c4="${font_colors[$4]}" \
    '{
    printf(\
        "%s%s%s%s = %s%s%s%s\n",
        c1, c2,
        $1, c0,
        c3, c4,
        $3, c0);
}' | column -t
