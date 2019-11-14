#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
THIS_PROG="$0"


function _fn_file_completion {
    plugin_name="${1:-local}"
    for fname in "${SUPERDOTS}"/dots/"$plugin_name"/bash-sources/*.sh ; do
        if [[ $fname =~ '*' ]] ; then
            continue
        fi

        if [ -z "$1" ] ; then
            basename "${fname}" | sed 's/\.sh//'
        else
            echo "$plugin_name/$(basename "${fname}" | sed 's/\.sh//')"
        fi
    done

    if [ -z "$1" ] ; then
        # now do all of the non-local plugin/file names
        for plugin_path in $(ls "${SUPERDOTS}"/dots) ; do
            if [ "$plugin_path" == "local" ] || [ "$plugin_path" == "system" ] ; then
                continue
            fi
            _fn_file_completion "$plugin_path"
        done
    fi
}

function _fn_fn_completion {
    grep -he "^function " "${SUPERDOTS}/dots/"*/bash-sources/*.sh \
        | sed 's/function\s*\(.*\)\s\s*.*/\1/g' \
        | grep -v "^_" \
        | sort \
        | uniq
}

function _ensure_editor {
    if [ -z "$EDITOR" ] ; then
        superdots-warn "EDITOR is not set"
        superdots-warn "Please set the EDITOR environment variable"
        superdots-warn "E.g."
        superdots-warn "    export EDITOR=vim"
        superdots-warn ""
        return 1
    fi
}

add_completion fn_new _fn_file_completion
function fn_new {
    if [ $# -ne 1 ] ; then
        echo "USAGE: fn_new FN_FILE_NAME"
        return 1
    fi

    if ! _ensure_editor ; then
        return 1
    fi

    local fn="$1"
    local fnpath=$(_get_fn_path "$fn")

    $EDITOR $fnpath
    
    if [ -e "$fnpath" ] ; then
        source "$fnpath"
        echo "new function ready to go!"
    else
        echo "did not source unsaved function file"
    fi
}

function _get_fn_path {
    # remove the leading slash
    local fn="$1"

    if [[ "$fn" =~ / ]] ; then
        local plugin=$(sed 's^/.*^^' <<<"$fn")
        local fn=$(sed 's^.*/^^' <<<"$fn")
        local fnpath="${SUPERDOTS}/dots/$plugin/bash-sources/${fn}.sh"
    else
        local fnpath="${SUPERDOTS}/dots/local/bash-sources/${fn}.sh"
    fi
    echo "$fnpath"
}

add_completion fn_edit _fn_file_completion -o nosort
function fn_edit {
    if [ $# -ne 1 ] ; then
        echo "USAGE: fn_edit FN_FILE_NAME"
        return 1
    fi

    if ! _ensure_editor ; then
        return 1
    fi

    local fn="$1"
    local fnpath=$(_get_fn_path "$fn")

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
