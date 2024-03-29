#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
THIS_PROG="$0"


uname_output="$(uname -s)"
case "${uname_output}" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    CYGWIN*)    PLATFORM=Cygwin;;
    MINGW*)     PLATFORM=MinGw;;
    *)          PLATFORM="UNKNOWN:${uname_output}"
esac

if [ "$PLATFORM" == "Mac" ] ; then
    _E=$'\033'
else
    _E="\e"
fi

_COLOR_DIM="$_E[2m"
_COLOR_BOLD="$_E[1m"
_COLOR_RED="$_E[91m"
_COLOR_YELLOW="$_E[93m"
_COLOR_GREEN="$_E[92m"
_COLOR_RESET="$_E[0m"


function _hide {
    "$@" >/dev/null 2>&1
}

function _muted_indent {
    echo -en $_COLOR_DIM
    cat | sed 's/^/    /'g
    echo -en $_COLOR_RESET
}

function superdots-realpath {
    if command -v realpath >/dev/null 2>&1 ; then
        realpath "$@"
    else
        # for OSX and other platforms that may be missing realpath
        # https://stackoverflow.com/a/18443300/606473
        local start_pwd=$PWD
        cd "$(dirname "$1")"
        local link=$(readlink "$(basename "$1")")
        while [ "$link" ]; do
            cd "$(dirname "$link")"
            local link=$(readlink "$(basename "$1")")
        done
        local real_path="$PWD/$(basename "$1")"
        cd "$start_pwd"
        echo "$real_path"
    fi
}


export SUPERDOTS=$(superdots-realpath "${SUPERDOTS:-$DIR}")
export SD_LOG_LEVEL=${SD_LOG_LEVEL:-info}
SUPERDOTS_LOG='/tmp/superdots.log'
SUPERDOTS_DEPS=(git)


DOTS_LIST=()


function superdots-log-level-num {
    local outvar="$1"
    local level_name="$2"
    local level_num=1

    case "$level_name" in
        debug)
            level_num=0
            ;;
        info)
            level_num=1
            ;;
        warn)
            level_num=2
            ;;
        error)
            level_num=3
            ;;
    esac

    eval "$outvar"'='"$level_num"
}


function superdots-echo {
    local level=$1
    shift

    superdots-log-level-num msg_level "$level"
    superdots-log-level-num log_level "$SD_LOG_LEVEL"
    if [ $msg_level -lt $log_level ] ; then
        return 0
    fi

    >&2 echo "..SUPERDOTS.. ${level} $@"
}

function superdots-debug {
    if [[ $(type -t sd::log::debug) == function ]]; then
        sd::log::debug "$@"
    else
        echo -en $_COLOR_DIM
        superdots-echo "debug" "$@"
        echo -en $_COLOR_RESET
    fi
}

function superdots-info {
    if [ "$SD_LOG_LEVEL" != "info" ] ; then
        return 0
    fi

    if [[ $(type -t sd::log::debug) == function ]]; then
        sd::log::info "$@"
    else
        echo -en $_COLOR_BOLD
        superdots-echo "info" "$@"
        echo -en $_COLOR_RESET
    fi
}

function superdots-warn {
    if [[ $(type -t sd::log::debug) == function ]]; then
        sd::log::warn "$@"
    else
        echo -en $_COLOR_YELLOW
        superdots-echo "warn" "$@"
        echo -en $_COLOR_RESET
    fi
}

function superdots-err {
    if [[ $(type -t sd::log::debug) == function ]]; then
        sd::log::error "$@"
    else
        echo -en $_COLOR_RED
        superdots-echo "error" "$@"
        echo -en $_COLOR_RESET
    fi
}
# OVERRIDEABLE VIA ALIAS
function superdots-indent {
    sed "s/^/    /g"
}

function superdots-ensure-deps {
    # superdots requires the following to be able to function correctly:

    local ensured=true

    while [ $# -gt 0 ] ; do
        local dep=$1
        shift
        if ! command -v "$dep" 2>&1 >/dev/null ; then
            superdots-err "Missing dependency '${dep}'"
            local ensured=false
        fi
    done

    if [ $ensured = false ] ; then
        return 1
    else
        return 0
    fi
}

function superdots-source-all {
    superdots-debug sourcing all dots
    set -a
    for dot in system "${DOTS_LIST[@]}" local ; do
        superdots-source-dot "$dot"
    done
    set +a
}

function superdots-source-dot {
    superdots-debug "Sourcing $1"

    local dot_folder=$(superdots-localname "$1")
    if [ ! -e "$SUPERDOTS/dots/$dot_folder" ] ; then
        superdots-warn "Superdots $1 has not been installed"
        return
    fi

    local source_order=(
        "${dot_folder}/bash-source-pre"
        "${dot_folder}/bash-sources"
    )

    local is_debug
    local start=0
    local end=0
    if [ "$SD_LOG_LEVEL" = "debug" ] ; then is_debug=true ; fi

    export -f superdots-debug
    for order in "${source_order[@]}" ; do
        superdots-debug "  sourcing $order"
        for file in "$SUPERDOTS/dots/$order"/*.sh ; do
            if [[ $file =~ "*" ]] ; then continue ; fi

            [ $is_debug ] && superdots-debug start=$(($(date +%s%N) / 1000000))

            . "$file"

            local took=""
            if [ $is_debug ] ; then
                end=$(($(date +%s%N) / 1000000))
                took=$(printf %8s "($(($end - $start))ms)")
            fi

            [ $is_debug ] && superdots-debug "    ${took}${file}"

        done
    done

    superdots-debug "..done"
}

function superdots-localname {
    local project_name=$(sed 's^.*:/*^^' <<<"$1")
    local project_name=$(sed 's^\.git$^^' <<<"$project_name")
    local project_name=$(sed 's^[/\.][/\.]*^-^g' <<<"$project_name")
    echo $project_name
}

function superdots-clone-url {
    local regex='^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$'
    if [[ "$1" =~ $regex ]] ; then 
        echo "https://github.com/$1"
    else
        echo $1
    fi
}

function superdots-clone-dot {
    superdots-info "Fetching $1"
    local local_path=$(superdots-localname "$1")
    local clone_url=$(superdots-clone-url "$1")

    superdots-debug "Cloning $clone_url to $local_path"
    local clone_log="${SUPERDOTS_LOG}.${local_path}"

    local target_dir="${SUPERDOTS}/dots/${local_path}"
    if [ -d "$target_dir" ] ; then
        superdots-info "Already installed"
        return 0
    fi

    git clone \
        "$clone_url" \
        "$target_dir" \
            >"$clone_log" 2>&1

    if [ $? -ne 0 ] ; then
        superdots-warn "Could not clone $clone_url:"
        superdots-warn "---------------------------"
        cat "$clone_log" | _muted_indent
        superdots-warn "---------------------------"
        superdots-warn "See $clone_log for full output"
        return 1
    fi

    superdots-info "Installed"
}

function superdots-update-dot {
    local local_path=$(superdots-localname "$1")
    local force="$2"

    local target_dir="${SUPERDOTS}/dots/${local_path}"
    if [ ! -d "$target_dir" ] ; then
        superdots-warn "Declared superdot $1 does has not been installed"
        return 1
    fi

    local clone_log="${SUPERDOTS_LOG}.${local_path}"

    superdots-info "Updating $local_path"
    (
        cd "$target_dir"
        if [ "$force" == true ] ; then
            superdots-warn "forcefully resetting any local changes"
            git reset --hard HEAD >"$clone_log" 2>&1
        fi
        git pull origin $(git rev-parse --abbrev-ref HEAD) >"$clone_log" 2>&1 
    )
    if [ $? -ne 0 ] ; then
        superdots-warn "Could not update $1:"
        superdots-warn "-------------------"
        cat "$clone_log" | _muted_indent
        superdots-warn "-------------------"
        superdots-warn "See $clone_log for full output"
        return 1
    fi
    superdots-info "    Done"
}

# superdot super-dots/default-dots
function superdots {
    superdots-debug "Recording $1 as superdot"
    DOTS_LIST+=("$1")

    local dots=""
    for dot_name in "${DOTS_LIST[@]}" ; do
        if [ ! -z "$dots" ] ; then dots="$dots|" ; fi
        dots="$dots$(superdots-localname "$dot_name")"
    done
    export DOTS="$dots"
}

function superdots-install {
    if ! superdots-ensure-deps "${SUPERDOTS_DEPS[@]}" ; then
        superdots-err "Missing dependencies, bailing installation"
        return 1
    fi

    superdots-debug "Ensuring ${#DOTS_LIST[@]} superdots are installed"

    for dot in "${DOTS_LIST[@]}" ; do
        if ! superdots-clone-dot "$dot" ; then
            superdots-err "Could not clone superdot plugin $dot"
            continue
        fi
        superdots-source-dot "$dot"
    done
}

function superdots-update {
    if ! superdots-ensure-deps "${SUPERDOTS_DEPS[@]}" ; then
        superdots-err "Missing dependencies, bailing installation"
        return 1
    fi

    superdots-debug "Updating"

    for dot in "${DOTS_LIST[@]}" ; do
        superdots-update-dot "$dot"
        superdots-source-dot "$dot"
    done
}

function superdots-status-dot {
    superdots-debug "Statusing $1"

    local dot_folder=$(superdots-localname "$1")
    if [ ! -e "$SUPERDOTS/dots/$dot_folder" ] ; then
        superdots-warn "Superdots $1 has not been installed"
        return
    fi

    if [ ! -e "$SUPERDOTS/dots/$dot_folder/.git" ] ; then
        superdots-warn "$1 does not have a .git folder"
        return
    fi

    superdots-info "$1 status:"

    (
        cd "$SUPERDOTS/dots/$dot_folder/"
        git status
    ) 2>&1 | sed -e 's/^/    /g'
}

function superdots-status {
    # Basically run git status on all cloned dot directories
    local first=true
    for dot in "${DOTS_LIST[@]}" ; do
        if [ $first != "true" ] ; then
            echo ""
        fi
        local first=false
        superdots-status-dot "$dot"
    done
}

function superdots-init {
    superdots-source-all
}
