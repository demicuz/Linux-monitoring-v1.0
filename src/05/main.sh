#!/usr/bin/env bash

set -e

start=`date +%s.%N`

target_dir=$1

if [[ $# != 1 ]]; then
    echo "error: Expected 1 argument, got $#" >&2; exit 1
elif [[ ${target_dir: -1} != "/" ]]; then
    echo "error: The argument doesn't end with '/'" >&2; exit 1
elif [[ ! -a $1 ]]; then
    echo "error: The directory doesn't exist" >&2; exit 1
fi

source ./utils.sh

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

end=`date +%s.%N`

echo -n "Script execution time (in seconds): "
echo "$end - $start" | bc | xargs printf "%.2f\n"
