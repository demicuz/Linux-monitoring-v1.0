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
# Kinda breaks if directory names contain `\n`.
function print_top_5_dirs {
    find $1 -mindepth 1 -maxdepth 1 -type d -print0 \
    | xargs -r0 du -sh \
    | sort -rh \
    | head -n 5 \
    | awk '
        {
            i++;
            printf("%d - %s, %s\n"), i, $2, $1
        }' \
    | column -t -o ' '
}

# Print as many x's as there are files, because a filename can contain basically
# any character. Yes, `find | wc -l` will count multiple times the files in `\n`
# in their name. I won't ever name my files like that, but it's possible to do
# that.
dir_count=$(find $target_dir -mindepth 1 -type d -printf x | wc -c)
file_count=$(find $target_dir -mindepth 1 -type f -printf x | wc -c)

echo "Total directories (including all nested ones): $dir_count"
if [[ $dir_count != "0" ]]; then
    echo "TOP 5 directories of maximum size arranged in descending order:"
    print_top_5_dirs $target_dir
fi

echo "Total number of files: $file_count"

if [[ $file_count != "0" ]]; then
    conf_count=$(find $target_dir -mindepth 1 -type f -iname "*.conf" -printf x | wc -c)
    # TODO `-exec grep -Iq .` is VERY slow. But `file` is even slower.
    text_count=$(find $target_dir -mindepth 1 -type f -exec grep -Iq . {} \; -printf x | wc -c)
    exec_count=$(find $target_dir -mindepth 1 -type f -executable -printf x | wc -c)
    log_count=$(find $target_dir -mindepth 1 -type f -iname "*.log" -printf x | wc -c)
    archive_count=$(7z t $target_dir 2> /dev/null | grep "^OK archives: " | cut -d' ' -f3)
    link_count=$(find $target_dir -mindepth 1 -type l -printf x | wc -c)

    echo "\
Number of:
Configuration files (with the .conf extension): $conf_count
Text files: $text_count
Executable files: $exec_count
Log files (with the extension .log): $log_count
Archive files: $archive_count
Symbolic links: $link_count"
fi
