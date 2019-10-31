#!/usr/bin/env bash


# defines bash completion utility functions
#
# e.g.
#
#     function do_completion {
#         echo 1110 1111 1101 1100
#     }
#    
#     add_completion a_few_binary_numbers do_completion
#     function a_few_binary_numbers {
#         echo $1
#     }
#
function add_completion {
    fn_name="$1"
    completion_fn="$2"

    local tmp_fn="_${fn_name}__completion__"
    local func_def=""
    eval "function ${tmp_fn} { ${fn_name} ; }"

    read -r -d '' func_def <<EOF
    function ${tmp_fn} {
        COMPREPLY=()
        cur="\${COMP_WORDS[COMP_CWORD]}"
        prev="\${COMP_WORDS[COMP_CWORD]}"
        opts="\$(${completion_fn})"

        COMPREPLY=( \$(compgen -W "\${opts}" -- \${cur}) )
        return 0
    }
EOF

    # define the temporary function
    eval "$func_def"

    # assign the temporary function as the completion for fn_name
    complete -F "${tmp_fn}" "${fn_name}"
}
