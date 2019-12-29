#!/usr/bin/env bash


function _dots_completion {
    echo "${DOTS_LIST[@]}" local
}


# Drop into a new $SHELL in the specified dot's directory
add_completion superdots-shell _dots_completion
function superdots-shell {
    dot="$1"
    local dot_folder=$(superdots-localname "$1")
    superdots-info "Dropping into a new \$SHELL ($SHELL) in $dot_folder"
    superdots-info "Exit the shell to return to your current location"

    (
        cd "$SUPERDOTS/dots/$dot_folder"
        "$SHELL"
    )
}
