

# DESC: Force sudo to not keep any permissions cached. This is to prevent
#       install functions from accidentally running install scripts that can
#       use the cached sudo creds
function sd::sudo::auto_drop {
    read -r -d "" to_eval <<-EOF
        function sudo {
            sd::func::escaped_args --out cmd_to_run -- "\$@"
            sd::log::warn "Running with sudo: \$cmd_to_run"
            \$(which sudo) "\$@"
            res=\$?
            \$(which sudo) -k
            return \$res
        }
        export -f sudo
EOF
    
    eval "$to_eval"
    sudo -k

    "$@"

    unset -f sudo
}
