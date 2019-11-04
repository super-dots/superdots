#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
THIS_PROG="$0"


function _fn_file_completion {
    for fname in "${SUPERDOTS}"/dots/local/bash-sources/*.sh ; do
        if [[ $fname =~ '*' ]] ; then
            continue
        fi
        basename "${fname}" | sed 's/\.sh//'
    done
}

function _fn_fn_completion {
    grep -he "^function " "${SUPERDOTS}/dots/"*/bash-sources/*.sh \
        | sed 's/function\s*\(.*\)\s\s*.*/\1/g' \
        | grep -v "^_" \
        | sort \
        | uniq
}

add_completion fn_new _fn_file_completion
function fn_new {
    if [ $# -ne 1 ] ; then
        echo "USAGE: fn_new FN_FILE_NAME"
        return 1
    fi

    local fn="$1"
    local fnpath="${SUPERDOTS}/dots/local/bash-sources/${fn}.sh"

    $EDITOR $fnpath
    
    if [ -e "$fnpath" ] ; then
        source "$fnpath"
        echo "new function ready to go!"
    else
        echo "did not source unsaved function file"
    fi
}

add_completion fn_edit _fn_file_completion
function fn_edit {
    if [ $# -ne 1 ] ; then
        echo "USAGE: edit_fn FN_FILE_NAME"
        return 1
    fi

    local fn="$1"
    local fnpath="${SUPERDOTS}/dots/local/bash-sources/${fn}.sh"

    if [ ! -e "${fnpath}" ] ; then
        fn_new $fn
        return $?
    fi

    $EDITOR $fnpath

    if [ -f "${fnpath}" ] ; then
        source "${fnpath}"
        echo "new changes are ready for use"
    fi
}

add_completion fn _fn_fn_completion
function fn {
    if [ $# -lt 1 ] ; then
        echo "USAGE: fn FN_NAME"
        return 1
    fi

    local fn="$1"
    shift
    $fn "$@"
}
