#!/usr/bin/env bash

set -e

# With -maxdepth 1 we avoid this kind of stuff:
# 1 - wat/, 300K
# 2 - wat/.git, 280K
# ...
# Kinda breaks if directory names contain `\n`.
function print_top_5_dirs {
    find $1 -mindepth 1 -maxdepth 1 -type d -exec du -sh {} \; \
    | sort -rh \
    | head -n 5 \
    | awk '
        {
            i++;
            printf("%d - %s, %s\n"), i, $2, $1
        }' \
    | column -t -o ' '
}

# TODO very slow
# Breaks on `\n` in names too. Look into `find -print0` `sort -z` and `head -z`,
# grep `--null`, etc.
function print_top_10_files {
    files=$(find $1 -type f -exec du -h {} \; \
    | sort -rh \
    | head -n 10)

    # "39M    ../Car wheel cap.obj" ->
    # "39M"
    sizes=$(echo "$files" | grep -o '^\S*')

    # "39M    ../Car wheel cap.obj" ->
    # "../Car wheel cap.obj"
    filenames=$(echo "$files" | sed -E 's/^\S*\s*//g')

    types=$(echo "$filenames" \
            | xargs --delimiter='\n' file -b \
            | awk -F ',' ' { print $1 } ')

    # Don't ask.
    # https://stackoverflow.com/a/25050612
    paste -d ", " \
    <(echo "$filenames") /dev/null \
    <(echo "$sizes") /dev/null \
    <(echo "$types") | awk '
        {
            i++;
            printf("%d - "), i;
            print
        }'
}

function print_top_10_executables {
    files=$(find $1 -type f -executable -exec du -h {} \; \
    | sort -rh \
    | head -n 10)

    # "42M    ../myprog.exe" ->
    # "42M"
    sizes=$(echo "$files" | grep -o '^\S*')

    # "42M    ../myprog.exe" ->
    # "../myprog.exe"
    filenames=$(echo "$files" | sed -E 's/^\S*\s*//g')

    hashes=$(echo "$filenames" \
             | xargs --delimiter='\n' md5sum \
             | grep -o '^\S*')

    # Don't ask.
    # https://stackoverflow.com/a/25050612
    paste -d ", " \
    <(echo "$filenames") /dev/null \
    <(echo "$sizes") /dev/null \
    <(echo "$hashes") | awk '
        {
            i++;
            printf("%d - "), i;
            print
        }'
}
