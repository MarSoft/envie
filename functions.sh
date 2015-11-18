#!/bin/bash
#
# VirtualEnv shell helpers: easier create, remove, list/find and activate.
# Written by Radomir Stevanovic, Feb 2015.

function fail() {
    echo "$1"
    exit 1
}

# Creates a new environment in <path/to/env>.
# Usage: mkenv [<path/to/env>]
function mkenv() {
    local path="${1:-env}"
    if [ -d "$path" ]; then
        fail "Directory '$path' already exists."
    fi
    echo "Creating python environment in: '$path'."
    mkdir -p "$path"
    cd "$path"
    virtualenv --no-site-packages .
    . bin/activate
    cd - >/dev/null
}

function rmenv() {
    local envpath
    envpath="$VIRTUAL_ENV"
    deactivate
    rm -rf "$envpath"
}

function _deactivate() {
    [ "$VIRTUAL_ENV" ] && deactivate
}

function _activate() {
    _deactivate
    source "$1/bin/activate"
}

# Lists all environments below the <start_dir>.
# Usage: lsenv [<start_dir> [<avoid_subdir>]]
function lsenv() {
    local dir="${1:-.}" avoid="${2:-}"
    find "$dir" -path "$avoid" -prune -o -path '*/bin/python' \
        -exec dirname '{}' \; 2>/dev/null | xargs -d'\n' -n1 -r dirname
}

# Finds the closest env by first looking down and then dir-by-dir up the tree.
function lsupenv() {
    local list len=0 dir='.' prevdir=''
    while [ "$len" = 0 ] && [ "$(readlink -e "$prevdir")" != / ]; do
        list="$(lsenv "$dir" "$prevdir")"
        [ "$list" ] && len=$(wc -l <<< "$list") || len=0
        prevdir="$dir"
        dir="$dir/.."
    done
    echo "$list"
}

function cdenv() {
    local OLDIFS envlist env len=0

    envlist=$(lsupenv)
    [ "$envlist" ] && len=$(wc -l <<< "$envlist")
    if [ "$len" = 1 ]; then
        _activate "$envlist"
    elif [ "$len" = 0 ]; then
        echo "No environments found."
    else
        OLDIFS="$IFS"
        IFS=$'\n'
        select env in $envlist; do
            if [ "$env" ]; then
                _activate "$env"
                break
            fi
        done
        IFS="$OLDIFS"
    fi
}

alias wkenv=cdenv
