#!/usr/bin/env bash

set -e

target_dir=$1

if [[ $# != 1 ]]; then
    echo "error: Expected 1 argument, got $#" >&2; exit 1
elif [[ ${target_dir: -1} != "/" ]]; then
    echo "error: The argument doesn't end with '/'" >&2; exit 1
elif [[ ! -a $1 ]]; then
    echo "error: The directory doesn't exist" >&2; exit 1
fi

# with -maxdepth 1 we avoid this kind of stuff:
# 1 - wat/, 300K
# 2 - wat/.git, 280K
# ...
function print_top_5_dirs {
    du -sh $(find $1 -mindepth 1 -maxdepth 1 -type d) | sort -rh | head -n 5 | awk '
        {
            i++;
            printf("%d - %s, %s\n"), i, $2, $1
        }
    ' | column -t -o ' '
}

dir_count=$(find $target_dir -mindepth 1 -type d | wc -l)
file_count=$(find $target_dir -mindepth 1 -type f | wc -l)

echo "Total directories (including all nested ones): $dir_count"
if [[ $dir_count != "0" ]]; then
    echo "TOP 5 directories of maximum size arranged in descending order:"
    print_top_5_dirs $target_dir
fi

echo "Total number of files: $file_count"
