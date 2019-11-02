

" add this ultisnips directory to the search path

let s:this_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

if !exists("g:UltiSnipsSnippetDirectories")
    let g:UltiSnipsSnippetDirectories=[]
endif

" use the local directory for editing, but source snippets from here
let g:UltiSnipsSnippetsDir=s:this_dir."/../../local/vim-sources/ultisnippets"
let g:UltiSnipsSnippetDirectories=add(g:UltiSnipsSnippetDirectories, s:this_dir."/ultisnippets")
