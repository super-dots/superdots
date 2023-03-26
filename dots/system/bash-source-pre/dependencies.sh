#!/usr/bin/env bash


function sd::bin_exists {
    if [[ $# -ne 1 ]] ; then
        echo "Usage: $0 BIN_NAME"
        echo
        echo "Successful exit code means it exists"
    fi

    [[ "$(type -a "$1" 2>&1)" =~ "$1 is /" ]]
}


function _do_lazy_install_hook {
    if [[ $# -lt 2 ]] ; then 
        echo "Usage: $0 EXE_NAME HOOK_FN_NAME ARGS_TO_FWD"
        echo
        echo "If the env vars below may be set:"
        echo ""
        echo "  NO_CONFIRM - install without confirming"
        echo "  NO_RUN     - do not run after installing"
        return 1
    fi

    local exe_name="$1"
    shift
    local hook_fn_name="$1"
    shift
    local check_cmd="$1"
    shift
    local needs_sudo="$1"
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

    if [ -z "$NO_CONFIRM" ] && ! sd::func::aliased sd::ux::confirm "Do you want to install ${exe_name}?" ; then
        sd::log "Ok, not installing"
        return 1
    fi

    if [ "$needs_sudo" = true ] ; then
        sd::log::warn "Prompting for sudo before running install command ..."
        sudo true
    fi

    # now we know it doesn't exist yet, so call the hook function. If the exe
    # exists after we call the hook function, then call the exe
    sd::log::note::command "$hook_fn_name" "$exe_name"

    if eval "$check_cmd" >/dev/null 2>&1 ; then
        sd::log::success "$exe_name should be available now!"
        sd::log::debug "$exe_name exists now, unsetting the lazy hook function"

        unset -f "$exe_name"

        if [ -z "$NO_RUN" ] ; then
            sd::func::escaped_args --out escaped_args -- $exe_name "$@"
            sd::log::debug "$exe_name exists now, calling binary with: $escaped_args"

            "$exe_name" "$@"
            return $?
        else
            return 0
        fi
    fi
}

function sd::lazy_install_hook {
    local this_fn="$0"

    # save an escaped version of the "check command" into check_cmd
    local check_cmd
    local usage="USAGE: $this_fn [--custom-check CHECK_CMD_STR] [--needs-sudo] COMMAND_NAME INSTALL_FN"
    local needs_sudo=false

    while [ $# -ne 0 ] ; do
        case "$1" in
            --help|-h)
                sd::log::info "$usage"
                exit 1
                ;;
            --custom-check)
                shift
                check_cmd="$1"
                shift
                ;;
            --needs-sudo)
                shift
                needs_sudo=true
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
    shift
    local hook_exe_name="$1"
    shift

    if [ -z "$check_cmd" ] ; then
        #sd::func::escaped_args --out check_cmd -- sd::bin_exists "$exe_name"
        local check_cmd="sd::bin_exists ${exe_name@Q}"
    fi

    if $check_cmd ; then
        return 0
    fi

    read -r -d "" func_def <<EOF
    function ${exe_name} {
        _do_lazy_install_hook "${exe_name}" "${hook_exe_name}" "${check_cmd}" "${needs_sudo}" "\$@"
    }
EOF

    eval "$func_def"
}
