#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
THIS_PROG="$0"


export SUPERDOTS="$DIR"
export SUPERDOTS_DEBUG=${SUPERDOTS_DEBUG:-false}

SUPERDOTS_LOG='/tmp/superdots.log'
SUPERDOTS_DEPS=(git)

DOTS=()


function superdots-echo {
    level=$1
    shift

    if [ "$level" = "DEBUG" ] && [ $SUPERDOTS_DEBUG = false ] ; then
        return 0
    fi

    echo "..SUPERDOTS.. ${level} $@"
}

function superdots-debug {
    superdots-echo "DEBUG" "$@"
}

function superdots-info {
    superdots-echo " INFO" "$@"
}

function superdots-warn {
    superdots-echo " WARN" "$@"
}

function superdots-err {
    superdots-echo "  ERR" "$@"
}

function superdots-ensure-deps {
    # superdots requires the following to be able to function correctly:

    ensured=true

    while [ $# -gt 0 ] ; do
        dep=$1
        shift
        if ! command -v "$dep" 2>&1 >/dev/null ; then
            superdots-err "Missing dependency '${dep}'"
            ensured=false
        fi
    done

    if [ $ensured = false ] ; then
        return 1
    else
        return 0
    fi
}

function superdots-source-dot {
    superdots-debug "Sourcing $1"

    dot_folder=$(superdots-localname "$1")
    source_order=(
        "${dot_folder}/bash-source-pre"
        "${dot_folder}/bash-sources"
    )

    export -f superdots-debug
    (
        shopt -s nullglob
        for order in "${source_order[@]}" ; do
            superdots-debug "Sourcing files in $order"
            for file in "$order"/*.sh ; do
                superdots-debug "Sourcing  $file"
                . "$file"
            done
        done
    )
}

function superdots-localname {
    github_ns_name="$1" # github.com/ns/name
    sed 's^/^-^g' <<<"$github_ns_name"
}

function superdots-fetch-dot {
    superdots-info "Fetching $1"
    local_path=$(superdots-localname "$1")

    target_dir="${SUPERDOTS}/dots/${local_path}"
    git clone \
        "https://github.com/$1" \
        "$target_dir" \
            >"$SUPERDOTS_LOG" 2>&1
}

function superdots-update-dot {
    local_path=$(superdots-localname "$1")

    target_dir="${SUPERDOTS}/dots/${local_path}"
    if [ ! -e "$target_dir" ] ; then
        superdots-warn "Declared superdot $1 does has not been installed"
        return 1
    fi

    superdots-info "Updating $local_path"
    (
        cd $target_dir
        git pull origin $(git rev-parse --abbrev-ref HEAD) >"$SUPERDOTS_LOG" 2>&1 
    )
    superdots-info "    Done"
}

# superdot super-dots/default-dots
function superdot {
    superdots-debug "Adding $1 as superdot"
    DOTS+=("$1")
}

function superdots-install {
    superdots-ensure-deps "${SUPERDOTS_DEPS[@]}"
    if [ $? -ne 0 ] ; then
        superdots-err "Missing dependencies, bailing installation"
        return 1
    fi

    superdots-debug "Installing"

    for dot in "${DOTS[@]}" ; do
        superdots-fetch-dot "$dot"
        superdots-source-dot "$dot"
    done
}

function superdots-update {
    superdots-ensure-deps "${SUPERDOTS_DEPS[@]}"
    if [ $? -ne 0 ] ; then
        superdots-err "Missing dependencies, bailing installation"
        return 1
    fi

    superdots-debug "Updating"

    for dot in "${DOTS[@]}" ; do
        superdots-update-dot "$dot"
        superdots-source-dot "$dot"
    done
}

function superdots-init {
    local_dots=(system local)
    for dot in "${local_dots[@]}" "${DOTS[@]}" ; do
        superdots-source-dot "$dot"
    done
}

superdots-init
