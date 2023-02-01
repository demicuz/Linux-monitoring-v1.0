#!/usr/bin/env bash

set -e

if ! source stats.sh; then
    echo "stats.sh not found" >&2; exit 1
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
