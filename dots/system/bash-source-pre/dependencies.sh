#!/usr/bin/env bash


function sd::bin_exists {
    if [[ $# -ne 1 ]] ; then
        echo "Usage: $0 BIN_NAME"
        echo
        echo "Successful exit code means it exists"
    fi

    type -a "$1" 2>&1 | grep -v "is a function" | grep "$1 is /" >/dev/null 2>&1
}


function sd::func_exists {
    if [[ $# -ne 1 ]] ; then
        echo "Usage: $0 FUN_NAME"
        echo
        echo "Successful exit code means it exists"
    fi

    [ $(type -t "$1" 2>&1) = "function" ]
}


function _do_lazy_install_hook {
    if [[ $# -lt 2 ]] ; then 
        echo "Usage: $0 EXE_NAME HOOK_FN_NAME ARGS_TO_FWD"
        return 1
    fi

    local exe_name="$1"
    local hook_fn_name="$2"
    local check_cmd="$3"

    shift
    shift
    shift

    # this will ignore any functions with the same name
    if eval "$check_cmd" >/dev/null 2>&1 ; then
        sd::log::debug "$exe_name already exists, calling it and exiting early"
        unset -f "$exe_name"
        sd::func::escaped_args --out escaped_args -- "$exe_name" "$@"
        sd::log::debug "Calling it with $escaped_args"
        "$exe_name" "$@"
        return $?
    fi

    sd::log::warn "${exe_name} wasn't found in path, but an install function has been defined:"
    sd::log::warn ""
    fn_src "$hook_fn_name" | sd::log::box_indent

    if ! sd::func::aliased sd::ux::confirm "Do you want to install ${exe_name}?" ; then
        sd::log "Ok, not installing"
        return 1
    fi

    # now we know it doesn't exist yet, so call the hook function. If the exe
    # exists after we call the hook function, then call the exe
    sd::log::note::command "$hook_fn_name" "$exe_name"

    if eval "$check_cmd" >/dev/null 2>&1 ; then
        sd::log::success "$exe_name should be available now!"
        sd::log::debug "$exe_name exists now, unsetting the lazy hook function and reloading"

        unset -f "$exe_name"

        sd::func::escaped_args --out escaped_args -- $exe_name "$@"
        sd::log::debug "$exe_name exists now, calling binary with: $escaped_args"
        "$exe_name" "$@"
        return $?
    fi
}

function sd::lazy_install_hook {
    local this_fn="$0"

    # save an escaped version of the "check command" into check_cmd
    local check_cmd
    local usage="USAGE: $this_fn [--custom-check CHECK_CMD_STR] COMMAND_NAME INSTALL_FN"

    while [ $# -ne 0 ] ; do
        case "$param" in
            --help|-h)
                sd::log::info "$usage"
                exit 1
                ;;
            --custom-check)
                shift
                check_cmd="$1"
                ;;
            *)
                break;
                ;;
        esac
    done

    if [[ $# -lt 2 ]] ; then
        sd::log::error "Must provide the COMMAND_NAME and INSTALL_FN"
        sd::log::info
        sd::log::info "$usage"
        return 1
    fi

    local exe_name="$1"
    local hook_exe_name="$2"
    shift
    shift

    if [ -z "$check_cmd" ] ; then
        sd::func::escaped_args --out check_cmd -- sd::bin_exists "$exe_name"
    fi

    if eval "$check_cmd" ; then
        return 0
    fi

    read -r -d "" func_def <<EOF
    function ${exe_name} {
        _do_lazy_install_hook "${exe_name}" "${hook_exe_name}" "${check_cmd}" "\$@"
        return $?
    }
EOF

    eval "$func_def"
}
