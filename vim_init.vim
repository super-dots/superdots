set encoding=utf-8
let s:this_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')


function! s:source_dot(dot_dir)
    for f in split(glob(a:dot_dir."/vim-sources/*.vim"), '\n')
        exe 'source' f
    endfor
endfunction


let s:vim_scripts_dir = expand(s:this_dir."/dots/")
" source system first
call s:source_dot(s:this_dir."/dots/system")
for fdir in split($DOTS, '|')
    let fdir = s:vim_scripts_dir.fdir
    call s:source_dot(fdir)
endfor
" source local last
call s:source_dot(s:this_dir."/dots/local")
