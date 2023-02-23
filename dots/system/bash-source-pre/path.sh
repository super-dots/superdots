#!/usr/bin/env bash


function sd::path::already_has {
    regex="(^$1:|:$1"'(:|$))'
    [[ "$PATH" =~ $regex ]]
}


function sd::path::prepend {
    if [ $# -ne 1 ] ; then
        echo "USAGE: $0 NEW_PATH_PART"
        return 1
    fi

    if sd::path::already_has "$1" ; then
        return 0
    fi

    export PATH="$1:$PATH"
}

function sd::path::append {
    if [ $# -ne 1 ] ; then
        echo "USAGE: $0 NEW_PATH_PART"
        return 1
    fi

    if sd::path::already_has "$1" ; then
        return 0
    fi

    export PATH="$PATH:$1"
}
