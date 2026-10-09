#!/bin/bash

NAMESPACE=ijortengab/rcm-cloudflare-api

if [[ "$EUID" -ne 0 ]]; then
    echo This script needs to be run with superuser privileges
    exit 1
fi

if ! command -v rcm > /dev/null;then
    printf '%b' "\033[95;1m"rcm"\033[0m"' command is '"\033[91;1m"'not found'"\033[0m"."\n" >&2
    exit 1
fi

RCM_PREFIX=${RCM_PREFIX:=/usr/local/rcm}
RCM_VERSION=`rcm --version 2>&1`
RCM_LIB="${RCM_PREFIX}/lib/${RCM_VERSION}"

[ -f "${RCM_LIB}/require.sh" ] || { echo File is not found: require.sh. >&2; exit 1; }
source "${RCM_LIB}"/require.sh

# ------------------------------------------------------------------------------

require vendor/ijortengab/rcm/functions/classes/rcm-dir.sh
require vendor/ijortengab/rcm/functions/utility/link-symbolic.sh
require vendor/ijortengab/rcm/functions/utility/link-symbolic-dir.sh

# Functions.
resolve_relative_path() {
    if [ -d "$1" ];then
        cd "$1" || return 1
        pwd
    elif [ -e "$1" ];then
        if [ ! "${1%/*}" = "$1" ]; then
            cd "${1%/*}" || return 1
        fi
        echo "$(pwd)/${1##*/}"
    else
        return 1
    fi
}

title install-all
____

__FILE__=$(resolve_relative_path "$0")
__DIR__=$(dirname "$__FILE__")
code cd "$__DIR__"
cd "$__DIR__"
____

chapter Memeriksa direktori commands.
target="${RCM_LIB}/commands"
code target="$target"
rcm-dir terminateIfNotExists "$target"
source="${PWD}/rcm/install/commands"
code source="$source"
rcm-dir isExists "$source"
if [ -n "$found" ];then
    __ Symlink all items inside commands directory.
    ____
    while IFS= read -r line; do
        link-symbolic-dir "${source}/${line}" "${target}/${line}" - absolute
    done <<< `ls -1 "$source"`
else
    ____
fi

chapter Memeriksa direktori interfaces.
target="${RCM_LIB}/interfaces"
code target="$target"
rcm-dir terminateIfNotExists "$target"
source="rcm/install/interfaces"
code source="$source"
rcm-dir isExists "$source"
if [ -n "$found" ];then
    __ Symlink all items inside interfaces directory.
    ____

    while IFS= read -r line; do
        link-symbolic "${PWD}/${line}" "${target}${line/$source/}" - absolute
    done <<< `find "$source" -type f`
else
    ____
fi

chapter Memeriksa direktori lainnya.
source="${PWD}"
target="${RCM_LIB}/vendor/${NAMESPACE}"
code source=$
code target=$
____

while IFS= read -r line; do
    if [ -z "$line" ];then
        continue
    fi
    if [[ "$line" == rcm ]];then
        continue
    fi
    [[ -d "${source}/${line}" ]] || continue
    link-symbolic-dir "${source}/${line}" "${target}/${line}" - absolute
done <<< `ls -1 "$source"`
