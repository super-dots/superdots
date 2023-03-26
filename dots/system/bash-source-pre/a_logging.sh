#!/usr/bin/env bash

SD_LOG_PREFIX="[>>>]"
SD_LOG_LEVEL="${SD_LOG_LEVEL:-info}"
_SD_LOG_COLOR=""
_SD_LOG_EXTRA_PREFIX=""

SD_COLOR_DIM="$_E[2m"
SD_COLOR_BOLD="$_E[1m"
SD_COLOR_RED="$_E[91m"
SD_COLOR_YELLOW="$_E[93m"
SD_COLOR_GREEN="$_E[92m"
SD_COLOR_BLUE="$_E[94m"
SD_COLOR_RESET="$_E[0m"


function sd::log::set_level {
    local regex="^(debug|info|warn|error)\$"
    if ! [[ "$1" =~ $regex ]] ; then
        sd::log::error "Level must be one of $regex"
        return 1
    fi

    export SD_LOG_LEVEL="$1"
}

# uses an outvar!
function sd::log::_get_level { # ARGS:LEVEL ARG:OUTVAR
    local level=$1
    local outvar=$2

    case "$level" in
        debug)
            level_num=0
            ;;
        info|note|success)
            level_num=1
            ;;
        warn)
            level_num=2
            ;;
        error)
            level_num=3
            ;;
    esac

    eval $outvar"=$level_num"
}

function sd::log::_switch {
    local msg_level="$1"
    local msg_route="$2"
    shift
    shift

    sd::log::_get_level $SD_LOG_LEVEL log_level_num
    sd::log::_get_level $msg_level msg_level_num

    if [ $msg_level_num -lt $log_level_num ] ; then
        return 0
    fi

    local prev_color="$_SD_LOG_COLOR"
    local prev_extra_prefix="$_SD_LOG_EXTRA_PREFIX"

    case "$msg_level" in
        debug)
            export _SD_LOG_COLOR="${SD_COLOR_DIM}"
            export _SD_LOG_EXTRA_PREFIX=":[$SHLVL]:"
            ;;
        info)
            export _SD_LOG_COLOR=""
            ;;
        note)
            export _SD_LOG_COLOR="${SD_COLOR_BLUE}"
            ;;
        success)
            export _SD_LOG_COLOR="${SD_COLOR_GREEN}"
            ;;
        warn)
            export _SD_LOG_COLOR="${SD_COLOR_YELLOW}"
            ;;
        error)
            export _SD_LOG_COLOR="${SD_COLOR_RED}${SD_COLOR_BOLD}"
            ;;
    esac

    export _SD_LOG_COLOR="${SD_COLOR_RESET}${_SD_LOG_COLOR}"

    case "$msg_route" in
        msg)
            sd::func::aliased sd::log::_msg "$@"
            ;;
        inline)
            sd::func::aliased sd::log::_inline "$@"
            ;;
        command)
            sd::func::aliased sd::log::_command "$@"
            ;;
        indent)
            sd::func::aliased sd::log::_indent "$@"
            ;;
        box_indent)
            sd::func::aliased sd::log::_box_indent "$@"
            ;;
        *)
            sd::func::aliased sd::log::error "Invalid logging route: $msg_route"
            return 1
            ;;
    esac

    export _SD_LOG_COLOR="$prev_color"
    export _SD_LOG_EXTRA_PREFIX="$prev_extra_prefix"
    echo -en "${SD_COLOR_RESET}"
}

# OVERRIDEABLE VIA ALIAS
function sd::log::_msg {
    echo -e "${_SD_LOG_COLOR}${_SD_LOG_EXTRA_PREFIX}${SD_LOG_PREFIX} $@"
}

# OVERRIDEABLE VIA ALIAS
function sd::log::_inline {
    echo -en "${_SD_LOG_COLOR}${_SD_LOG_EXTRA_PREFIX}${SD_LOG_PREFIX} $@"
}

# OVERRIDEABLE VIA ALIAS
function sd::log::_command {
    sd::func::escaped_args --out arg_var -- "$@"

    sd::log::_msg "Running command:"
    sd::log::_msg "${SD_COLOR_BOLD}  $arg_var"
    "$@" 2>&1 | sd::log::_box_indent
}

# OVERRIDEABLE VIA ALIAS
function sd::log::_indent {
    echo -en "${_SD_LOG_COLOR}${_SD_LOG_EXTRA_PREFIX}"
    sed "s/^/    /g"
}

# OVERRIDEABLE VIA ALIAS
function sd::log::_box_indent {
    sd::log::_msg '  ╭──────'
    local color=$(echo -e "$_SD_LOG_COLOR")
    local dim_color=$(echo -e "$SD_COLOR_DIM")
    sed "s/^/${color}${_SD_LOG_EXTRA_PREFIX}${SD_LOG_PREFIX}   │ ${dim_color}/g"
    # sometimes this is needed - doesn't hurt to add it when it's not needed
    echo -ne "\r"
    sd::log::_msg '  ╰──────'
}

function sd::log {
    sd::log::_switch msg info "$@"
}


function sd::log::_define_routes {
    local prefix="$1"
    local level="$2"

    for route in msg inline command indent box_indent ; do
        read -r -d "" func_src <<EOF
function sd::log${prefix}::${route} {
    sd::log::_switch ${level} ${route} "\$@"
}
EOF
        eval "$func_src"
    done

    # create a default log function that doesn't need the route
    read -r -d "" func_src <<EOF
function sd::log${prefix} {
    sd::log::_switch ${level} msg "\$@"
}
EOF
    eval "$func_src"
}


for level in debug info note success warn error ; do
    sd::log::_define_routes "::$level" "$level"
done

# all of the routes get a default "info" prefix
# e.g.
#   sd::log::box_indent == sd::log::info::box_indent
sd::log::_define_routes "" info
