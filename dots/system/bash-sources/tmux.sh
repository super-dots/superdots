#!/usr/bin/env bash


function _tmux_work_completion {
    tmux ls | awk '{print $1}' | sed 's/://g' | grep -v '.*-[0-9]*$'
}


SUPERDOTS_INTERMEDIATE_PATH="${SUPERDOTS}/tmux_dots_load.conf"


# create the intermediate loading file from all of the recorded
# superdots
function _init_tmux_confs {
    rm -f "$SUPERDOTS_INTERMEDIATE_PATH"
    # it needs to always exist
    touch "$SUPERDOTS_INTERMEDIATE_PATH"

    superdots-debug "Initializing superdots combined tmux.conf at $SUPERDOTS_INTERMEDIATE_PATH"

    function _source_tmux_file {
        if [ ! -e "$1" ] ; then return ; fi
        superdots-debug "    Sourcing tmux_init.conf at $1"
        echo "source $1" >> "$SUPERDOTS_INTERMEDIATE_PATH"
    }

    # load the system tmux_init.conf, if it exists
    _source_tmux_file "${SUPERDOTS}/dots/system/tmux_init.conf"

    # load everything besides system and local, if they exist
    for tmux_init in "${SUPERDOTS}"/dots/*/tmux_init.conf ; do
        if [[ $tmux_init =~ "*" ]] ; then continue ; fi
        if [[ $tmux_init =~ "system/tmux_init.conf" ]] || [[ $tmux_init =~ "local/tmux_init.conf" ]] ; then continue ; fi
        _source_tmux_file "$tmux_init"
    done

    # load the local tmux_init.conf last, if it exists
    _source_tmux_file "${SUPERDOTS}/dots/local/tmux_init.conf"
}


add_completion work _tmux_work_completion
function work {
    local session_name="${1:-$(basename $(pwd))}"

    _init_tmux_confs

    # exact match ONLY, now that we have tab-completion!
    local matched_name=$(tmux ls | awk '{print $1}' | sed 's/://g' | grep '^'"$session_name"'$')

    if [ -z "$matched_name" ] ; then
        if [ -z "$TMUX" ] ; then
            tmux new -s "$session_name" -c "$(pwd)"
        else
            tmux detach -E 'tmux new -s "'$session_name'" -c "'$(pwd)'"'
        fi
        return
    fi

    local unattached_session=$(tmux ls | grep -v "attached" | awk '{print $1}' | sed 's/://g' | grep "^${session_name}[-0-9]*"'$' |  head -n 1)
    if [ -z "$TMUX" ] ; then
        if [ -z "$unattached_session" ] ; then
            tmux new-session -t "$session_name" -c "$(pwd)"
        else
            tmux attach -t "$unattached_session"
        fi
    else
        if [ -z "$unattached_session" ] ; then
            tmux detach -E 'tmux new-session -t "'$session_name'" -c "'$(pwd)'"'
        else
            tmux switch -t "$unattached_session"
        fi
    fi
}
