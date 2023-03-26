#!/usr/bin/env bash


THIS_PROG="$0"


# _SD_LAZY_CREATED_FN_HOOKS=()
# _SD_JITTED_FUNCS=()

function sd::func::jit {
    local fn_or_exes="$1"
    local init_fn="$2"
    sd::log::debug "jit: $fn_or_exe $init_fn"

    for fn_or_exe in $fn_or_exes ; do
        _SD_JITTED_FUNCS+=("$fn_or_exe")

        local init_var_name="_SD_JITTED_INITS_${fn_or_exe}"

        read -r -d "" func_def <<-EOF
            $init_var_name+=(${init_fn@Q})

            function ${fn_or_exe} {
                sd::log::debug "calling init fns"
                unset -f ${fn_or_exe}
                for fn in "\${$init_var_name[@]}" ; do
                    \$fn
                done
                "${fn_or_exe}" "\$@"
            }
EOF
        
        eval "$func_def"
    done
}

function sd::func::jit_clear {
    for fn_or_exe in "${_SD_JITTED_FUNCS[@]}" ; do
        unset -f "$fn_or_exe"
        unset "_SD_JITTED_INITS_${fn_or_exe}"
    done
}
sd::func::jit_clear

function sd::func::exists {
    if [[ $# -ne 1 ]] ; then
        echo "Usage: $0 FUN_NAME"
        echo
        echo "Successful exit code means it exists"
    fi

    declare -F "$1" >/dev/null 2>&1
}

function _sd::func::do_lazy_create {
    if [ $# -lt 5 ] ; then
        sd::log::error "_sd::func::do_lazy_create needs five args"
        return 1
    fi

    local target_fn="$1"
    shift
    local check_fn="$1"
    shift
    local install_fn="$1"
    shift
    local init_fn="$1"
    shift
    local needs_sudo="$1"
    shift

    sd::log::debug "Lazily creating $target_fn"

    if ! "$check_fn" && ! [ -z "$install_fn" ] ; then
        sd::log::warn "${target_fn} doesn't exist, but it requires dependencies before it can be initialized"
        sd::log::warn "An install function has been defined:"
        sd::log::warn ""
        fn_src "$install_fn" | sd::log::box_indent

        if ! sd::func::aliased sd::ux::confirm "Do you want to install ${target_fn} dependencies?" ; then
            sd::log "Ok, not installing"
            return 1
        fi

        if [ "$needs_sudo" = true ] ; then
            sd::log::debug "Priming sudo ..."
            sudo echo -n
        fi

        "$install_fn" "$target_fn"
    fi

    if ! "$check_fn" ; then
        sd::log::warn "Cannot init the function ${target_fn}: check function failed after install"
        return 1
    fi

    sd::log::debug "Unsetting lazy func create hook"
    unset -f "$target_fn"

    set -a
    "$init_fn" "$target_fn"
    set +a

    if ! sd::func::exists "$target_fn" ; then
        sd::log::warn "${target_fn} still isn't defined, recreating lazy create hook"

        local args=(
            --func "$target_fn"
            --check "$check_fn"
            --install "$install_fn"
            --init "$init_fn"
        )
        if [ "$needs_sudo" = true ] ; then
            args+=(
                --needs-sudo
            )
        fi
        sd::func::lazy_create "${args[@]}"

        return 1
    fi

    "$target_fn" "$@"
}

function sd::func::lazy_create {
    local this_fn="$0"
    local usage="sd::func::lazy_create --func FUNC_NAME --create CREATE_FUNC_OR_EXE_NAME [--needs-sudo]"

    local target_fn=""
    local check_fn=""
    local install_fn=""
    local init_fn=""
    local needs_sudo=false

    while [ $# -ne 0 ] ; do
        arg="$1"
        shift
        case "$arg" in
            --help|-h)
                sd::log::info "$usage"
                return 1
                ;;
            --func)
                target_fn="$1"
                shift
                ;;
            --check)
                check_fn="$1"
                shift
                ;;
            --install)
                install_fn="$1"
                shift
                ;;
            --init)
                init_fn="$1"
                shift
                ;;
            --needs-sudo)
                needs_sudo=true
                ;;
            *)
                break;
                ;;
        esac
    done

    error=false
    if [ -z "$target_fn" ] ; then
        sd::log::error "--func must be provided to lazily create fn"
        error=true
    fi

    # install_fn is allowed to be empty
    # check_fn is allowed to be empty if install_fn is empty

    if ! [ -z "$install_fn" ] && [ -z "$check_fn" ] ; then
        sd::log::error "--check must be provided with --install to lazily create fn"
        error=true
    fi

    if [ -z "$init_fn" ] ; then
        sd::log::error "--init must be provided to lazily create fn"
        error=true
    fi

    if [ "$error" = true ] ; then
        return 1
    fi

    if sd::func::exists "$target_fn" ; then
        sd::log::debug "Target function '$target_fn' exists, no need to lazy create"
        return 0
    fi

    read -r -d "" func_def <<EOF
    function ${target_fn} {
        _sd::func::do_lazy_create "${target_fn}" "${check_fn}" "${install_fn}" "${init_fn}" "${needs_sudo}" "\$@"
    }
EOF

    export _SD_LAZY_CREATED_FN_HOOKS+=("$target_fn")

    eval "$func_def"
}

function sd::func::clear_lazy_create_hooks {
    sd::log::debug "Clearing defined lazy create hooks (${#_SD_LAZY_CREATED_FN_HOOKS[@]})"
    for hook in "${_SD_LAZY_CREATED_FN_HOOKS[@]}" ; do
        unset -f "$hook"
    done
    export _SD_LAZY_CREATED_FN_HOOKS=()
}

sd::func::clear_lazy_create_hooks


function sd::func::override_ {
    if [ $# -ne 2 ] ; then
        sd::log "USAGE: $0 FN_NAME_TO_REPLACE FN_NAME_REPLACEMENT"
        return 1
    fi

    orig_func_name="$1"
    new_func_name="$2"

    sd::log overriding "$orig_func_name" with "$new_func_name"

    read -r -d '' func_def <<EOF
    function $orig_func_name {
        $new_func_name "\$@"
    }
EOF
    eval "$func_def"
    export -f "$orig_func_name"
}

# DESC: Returns a single string with each provided argument correctly quoted.
#       The string should be able to be used as-is without quotes, e.g. to
#       forward a command and its arguments into bash -c
# ARGS: OUTVAR $@
function sd::func::escaped_args {
    if ! [ "$1" = "--out" ] && ! [ "$3" = "--" ] ; then
        sd::log::error "USAGE: $0 --out out_var -- arg1 arg2 ..."
        return 1
    fi

    shift # get rid of the "--out" param

    out_var="$1"
    shift 

    shift # get rid of the --
    
    res=""
    idx=1
    for arg in "$@" ; do
        eval 'res="$res ${'$idx'@Q}"'
        idx=$(($idx+1))
    done

    eval "$out_var=\$res"
}

# ARGS: alias_name $@
function sd::func::aliased {
    alias_name=$1
    shift
    alias_def=$(alias -p | grep "alias ${alias_name}=")

    # if no alias exists, treat it like a normal command and also let it fail
    if [ $? -ne 0 ] ; then
        sd::func::escaped_args --out escaped_args -- "$alias_name" "$@"
        $alias_name "$@"
        return $?
    fi

    local actual_cmd=$(sed -r "s/alias ${alias_name}='(.*)'\$/\1/" <<<$alias_def)

    # now call the alias
    sd::func::escaped_args --out escaped_args -- "$actual_cmd" "$@"
    $actual_cmd "$@"
}
