set encoding=utf-8
let s:this_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')


if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let s:path = expand('<sfile>:p')
  autocmd VimEnter * PlugInstall --sync | exit
endif


" vim-plug
call plug#begin('~/.vim/plugged')
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
call plug#end()


function! s:source_dot(dot_dir)
    for f in split(glob(a:dot_dir."/vim-sources/*.vim"), '\n')
        exe 'source' f
    endfor
endfunction


let s:vim_scripts_dirs = expand(s:this_dir."/dots/*")
" source system first
call s:source_dot(s:this_dir."/dots/system")
for fdir in split(s:vim_scripts_dirs, '\n')
    if fdir =~ "system$"
        continue
    elseif fdir =~ "local$"
        continue
    endif
    call s:source_dot(fdir)
endfor
call s:source_dot(s:this_dir."/dots/local")
