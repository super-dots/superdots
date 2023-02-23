#!/usr/bin/env bash


function sd::bin_exists {
    if [[ $# -ne 1 ]] ; then
        echo "Usage: $0 BIN_NAME"
        echo
        echo "Successful exit code means it exists"
    fi

    type -a "$1" 2>&1 | grep -v "is a function" | grep "$1 is /" >/dev/null 2>&1
}


function _do_lazy_install_hook {
    if [[ $# -lt 2 ]] ; then 
        echo "Usage: $0 EXE_NAME HOOK_FN_NAME ARGS_TO_FWD"
        return 1
    fi

    local exe_name="$1"
    local hook_fn_name="$2"

    shift
    shift

    # this will ignore any functions with the same name
    if sd::bin_exists "$exe_name" 2>/dev/null ; then
        sd::log::debug "$exe_name already exists, calling it and exiting early"
        unset -f "$exe_name"
        sd::func::escaped_args escaped_args "$exe_name" "$@"
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

    if sd::bin_exists "$exe_name" ; then
        sd::log::success "$exe_name should be available now!"
        sd::log::debug "$exe_name exists now, unsetting the lazy hook function and reloading"
        unset -f "$exe_name"

        sd::func::escaped_args escaped_args $exe_name "$@"
        sd::log::debug "$exe_name exists now, calling binary with: $escaped_args"
        "$exe_name" "$@"
        return $?
    fi
}

function sd::lazy_install_hook {
    if [[ $# -ne 2 ]] ; then 
        echo "Usage: $0 EXE_NAME HOOK_FN_NAME"
        echo
        echo "HOOK_FN will be passed all arguments that were intended for EXE_NAME"
        return 1
    fi

    local exe_name="$1"
    local hook_exe_name="$2"

    shift
    shift

    if sd::bin_exists "$exe_name" ; then
        return 0
    fi

    local tmp_fn="${exe_name}_${hook_exe_name}_jump"

    read -r -d "" func_def <<EOF
    function ${exe_name} {
        _do_lazy_install_hook "${exe_name}" "${hook_exe_name}" "\$@"
        return $?
    }
EOF

    eval "$func_def"
}
