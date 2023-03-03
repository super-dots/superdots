#!/usr/bin/env bash


THIS_PROG="$0"


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
