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
set guifont=Droid\ Sans\ Mono:h12
if has('gui_win32')         " why this only work on win32 gui
    language en             " always English
    language messages en
endif

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

" 语法高亮
syntax on

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

" set backspace behavior
set backspace=indent,eol,start

" Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" set completopt and preview window on the bottom
set completeopt=menuone,longest,preview
set splitbelow

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

"}}}

" => Plugin "{{{
let g:tags_interested_types = '\.\(asm\|c\|cpp\|cc\|h\|\java\|py\|sh\|vim\)$'

" NERDTreeToggle
nmap <F9> :NERDTreeToggle <CR>

" tagbar [FIXME: tagbar use on fly tags, but we have loaded a tag file]
nmap <F10> :TagbarToggle<CR>
let g:tagbar_compact = 1                "
let g:tagbar_iconchars = ['+', '-']     "
let g:tagbar_autoshowtag = 1

" neocomplete for c/cpp
let g:neocomplete#enable_at_startup = 1
"let g:neocomplete#disable_auto_complete = 1
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_smart_case = 1
" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" jedi/python complete settings [ftplugin]
let g:jedi#popup_select_first = 0
let g:jedi#show_call_signatures = "1"
let g:jedi#popup_on_dot = 0

" syntastic - auto errors check on :w
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_vim_checkers = ['vint']
let g:syntastic_vim_vint_quiet_messages = { "!level" : "errors" }

" set different plugin based on filetype
function! SetupPlugins()
    if expand("%:p") =~# g:tags_interested_types  || &filetype ==? "vim"
        let g:syntastic_mode_map = {"mode":"active", "passive_filetypes":[]}
    else
        let g:syntastic_mode_map = {"mode":"passive", "active_filetypes":[]}
    endif

    if &filetype ==? "python"
        call neocomplete#commands#_lock()
    else
        call neocomplete#commands#_unlock()
    endif
endfunction

augroup pluginsmngr
    au!
    au BufEnter * call SetupPlugins()
augroup END

" }}}

