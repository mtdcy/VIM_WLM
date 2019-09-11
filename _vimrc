""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{{{
" Copyright 2018 (c) Chen Fang
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" 1. Redistributions of source code must retain the above copyright notice, this
" list of conditions and the following disclaimer.
"
" 2. Redistributions in binary form must reproduce the above copyright notice,
" this list of conditions and the following disclaimer in the documentation
" and/or other materials provided with the distribution.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

" => General Options "{{{

" set color and theme
set t_Co=256
set background=dark
colorscheme solarized

" 字体
if has('gui_running')
    if has('linux')
        set guifont=Droid\ Sans\ Mono\ 12
    else
        set guifont=Droid\ Sans\ Mono:h12
    endif
    if has('gui_win32')         " why this only work on win32 gui
        language en             " always English
        language messages en
    endif
endif
set antialias

" 显示行号
set number

" 文件编码
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,latin1

" 文件类型
set fileformat=unix
set ffs=unix,dos

" 不备份文件
set nobackup
set nowritebackup

" 上下移动时，留3行
set so=3

" Don't ask me to save file before switching buffers
set hidden

" 高亮当前行
set cursorline
set nocursorcolumn

" 语法高亮
syntax on
set regexpengine=1  " force old regex engine, solve slow problem

" 使用非兼容模式
set nocompatible

" 有关搜索的选项
set hls
set incsearch
"set ic smartcase

" 一直启动鼠标
set mouse=a

" show command on the bottom of the screen
set showcmd

" 设置mapleader
let mapleader = ";"
let g:mapleader = ";"

" set backspace behavior
set backspace=indent,eol,start

" no bracket match 
set noshowmatch

" Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" }}}

" => Status Line {{{


set laststatus=2
set statusline=[%{mode()}][%n]\ %<%F%m%r%q%w        " buffer property
set statusline+=\ %#warningmsg#                     " syntastic 
set statusline+=\ %{SyntasticStatuslineFlag()}      " syntastic
set statusline+=%*                                  " syntastic: reset color
set statusline+=%=                                  " separation
set statusline+=\ %l/%L:%c\ %p%%                    " cursor position
set statusline+=\ %y[%{&fenc}][%{&ff}]              " file property

" }}}

" => Files "{{{
"
" ts    - tabstop       - tab宽度
" sts   - softtabstop   - 按下tab时的宽度（用tab和space组合填充）
" sw    - shiftwidth    - 自动缩进宽度
" et    - expandtab     - 是否展开tab
" tw    - textwidth     - 文本宽
" ai    - autoindent

" For all
set noautochdir 		        " may cause problem to some plugins

filetype plugin indent on

" common settings
set ts=4 sts=4 sw=4 et ff=unix

" fold default by marker
set foldmethod=marker
set foldlevelstart=99

function! JumpToLastPos()
    if line("'\"") > 0 && line ("'\"") <= line("$") && &ft !~# 'commit'
        exe "normal! g'\""
    endif
endfunction

" autocmd for all files
augroup files
    au!
    " 自动跳转到上一次打开的位置
    au BufReadPost * call JumpToLastPos()
augroup END

" For c/c++
augroup cfiles
    au!
    au FileType c,cpp setlocal tw=79 ff=unix
    au FileType c,cpp setlocal fdm=syntax
augroup END

" For LiteOS project
au FileType *.pkg setlocal filetype=sh

"}}}

" => Plugin "{{{
" NERDTreeToggle
nmap <F9> :NERDTreeToggle <CR>

" tagbar [FIXME: tagbar use on fly tags, but we have loaded a tag file]
nmap <F10> :TagbarToggle<CR>
let g:tagbar_compact = 1                "
let g:tagbar_iconchars = ['+', '-']     "
let g:tagbar_autoshowtag = 1

" syntastic - auto errors check on :w
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_vim_checkers = ['vint']
let g:syntastic_vim_vint_quiet_messages = { "!level" : "errors" }

" set different plugin based on filetype
function! SetupPlugins()
    if expand("%:p") =~# g:tags_interested_types  || &filetype ==? "vim"
        let g:syntastic_mode_map = {"mode":"active", "passive_filetypes":[]}
    else
        let g:syntastic_mode_map = {"mode":"passive", "active_filetypes":[]}
    endif
endfunction

augroup pluginsmngr
    au!
    au BufEnter * call SetupPlugins()
augroup END

" }}}

