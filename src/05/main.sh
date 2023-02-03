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
# Breaks on `\n` in names too.
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

    types=$(echo "$filenames" | xargs --delimiter='\n' file -b)

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
             | awk ' {print $1} ')

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

# Print as many _'s as there are files, because a filename can contain basically
# any character. Yes, `find | wc -l` will count multiple times the files in `\n`
# in their name. I won't ever name my files like that, but it's possible to do
# that.
dir_count=$(find $target_dir -mindepth 1 -type d -printf _ | wc -c)
file_count=$(find $target_dir -mindepth 1 -type f -printf _ | wc -c)

echo "Total directories (including all nested ones): $dir_count"
if [[ $dir_count != "0" ]]; then
    echo "TOP 5 directories of maximum size arranged in descending order:"
    print_top_5_dirs $target_dir
fi

echo "Total number of files: $file_count"

if [[ $file_count != "0" ]]; then
    echo "Number of:"

    echo -n "Configuration files (with the .conf extension): "
    echo $(find $target_dir -mindepth 1 -type f -iname "*.conf" -printf _ | wc -c)

    # TODO `-exec grep -Iq .` is VERY slow. But `file` is even slower.
    echo -n "Text files: "
    echo $(find $target_dir -mindepth 1 -type f -exec grep -Iq . {} \; -printf _ | wc -c)
    # A much faster approach, but detects only `.txt` files:
    # echo $(find $target_dir -mindepth 1 -type f -iname "*.txt" -printf _ | wc -c)

    echo -n "Executable files: "
    echo $(find $target_dir -mindepth 1 -type f -executable -printf _ | wc -c)

    echo -n "Log files (with the extension .log): "
    echo $(find $target_dir -mindepth 1 -type f -iname "*.log" -printf _ | wc -c)

    echo -n "Archive files: "
    echo $(7z t $target_dir 2> /dev/null | grep "^OK archives: " | cut -d' ' -f3)

    echo -n "Symbolic links: "
    echo $(find $target_dir -mindepth 1 -type l -printf _ | wc -c)

    echo "TOP 10 largest files arranged in descending order (path, size and type):"
    print_top_10_files $target_dir

    echo "TOP 10 largest executable files arranged in descending order (path, size and MD5 hash of file):"
    print_top_10_executables $target_dir
fi
