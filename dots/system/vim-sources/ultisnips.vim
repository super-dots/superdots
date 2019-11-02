

" add this ultisnips directory to the search path

let s:this_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

let g:UltiSnipsExpandTrigger="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:ultisnips_python_style="v_sphinx"
let g:UltiSnipsEditSplit="vertical"

if !exists("g:UltiSnipsSnippetDirectories")
    let g:UltiSnipsSnippetDirectories=[]
endif

" use the local directory for editing, but source snippets from here
let g:UltiSnipsSnippetsDir=s:this_dir."/../../local/vim-sources/ultisnippets"
let g:UltiSnipsSnippetDirectories=add(g:UltiSnipsSnippetDirectories, s:this_dir."/ultisnippets")
