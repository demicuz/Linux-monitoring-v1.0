#!/usr/bin/env bash

set -e

if ! source colors.conf; then
    echo "colors.conf not found" >&2; exit 1
elif [[ $# != 0 ]]; then
    echo "error: Expected 0 arguments, got $#" >&2; exit 1
fi

c1_bg=${column1_background:-6}
c1_font=${column1_font_color:-1}
c2_bg=${column2_background:-6}
c2_font=${column2_font_color:-2}

declare -a color_names=(
    "_"
    "white"
    "red"
    "green"
    "blue"
    "purple"
    "black"
)

function abort_if_invalid_code {
    if [[ ! $1 =~ ^[1-6]$ ]]; then
        echo "error: Expected a number from 1 to 6, got '$1'" >&2; exit 1
    fi
}

abort_if_invalid_code $c1_bg
abort_if_invalid_code $c1_font
abort_if_invalid_code $c2_bg
abort_if_invalid_code $c2_font

if [[ $c1_bg == $c1_font || $c2_bg == $c2_font ]]; then
    echo "error: Background and font colors are the same" >&2
    echo "Edit colors.conf and rerun the script" >&2
    exit 1
fi

./print_colorful_stats.sh $c1_bg $c1_font $c2_bg $c2_font

echo "
Column 1 background = ${column1_background:-"default"} (${color_names[c1_bg]})
Column 1 font color = ${column1_font_color:-"default"} (${color_names[c1_font]})
Column 2 background = ${column2_background:-"default"} (${color_names[c2_bg]})
Column 2 font color = ${column2_font_color:-"default"} (${color_names[c2_font]})"
