"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" => General Options "{{{ 

" set color and theme
set t_Co=256
set background=dark
colorscheme solarized

" 字体
set guifont=Droid\ Sans\ Mono:h12
"set gfn=Vera\ Sans\ YuanTi\ Mono:h10
"set gfn=Droid\ Sans\ Fallback:h10
set antialias

" 显示行号
set number 

" 文件编码 
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,latin1

" 文件类型
set fileformat=unix
set ffs=unix,dos
nmap <leader>fd :se ff=dos<cr>
nmap <leader>fu :se ff=unix<cr>

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

" 使用非兼容模式
set nocompatible    " need by vundle 

" 有关搜索的选项
set hls
set incsearch   
"set ic smartcase 

" 一直启动鼠标
set mouse=a

" 设置mapleader
let mapleader = ";"
let g:mapleader = ";"

" 自动跳转到上一次打开的位置
autocmd BufReadPost *
			\ if line("'\"") > 0 && line ("'\"") <= line("$") |
			\ exe "normal! g'\"" |
			\ endif 

" Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" For completion. if pumvisible, then next item; else tab
inoremap <expr><TAB>    pumvisible() ? "\<C-n>" : "\<TAB>"

" set completopt and preview window on the bottom
set completeopt=menuone,longest,preview
set splitbelow

" }}}


" => Tags Management " {{{
" set cscope key map
set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-                          " ???
nnoremap <leader>l :cstag <C-R>=expand("<cword>")<CR><CR>           " junp with cscope tag
nnoremap <leader>fa :cs find a <C-R>=expand("<cword>")<CR><CR>      " a: find assignment to this symbol
nnoremap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>      " s: find this symbol
nnoremap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>      " g: find this definition
nnoremap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>      " c: find functions calling this function
nnoremap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>      " d: find functions called by this function
nnoremap <leader>ft :cs find t <C-R>=expand("<cword>")<CR><CR>      " t: find this text string
nnoremap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR><CR>      " f: find this file
nnoremap <leader>fi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>    " i: find files #include this file

" FIXME: use vim's filetype detection
let g:tags_supported_types = '\.\(asm\|c\|cpp\|cc\|h\|\java\|py\)$'
let g:tags_ctags_cmd = "ctags --fields=+ailS --c-kinds=+p --c++-kinds=+p --sort=no --extra=+q"
let g:tags_cscope_cmd = "cscope -bkq"

function! Fixed_findfile(filename)
    exe "lcd " . expand("%:p:h")
    let result = findfile(a:filename, ".;")
    lcd -
    return result
endfunction

" auto load tags and cscope db
function! LoadTags()
    let loc = fnamemodify(Fixed_findfile("cscope.files"), ":p:h")
    exe "lcd " . loc
    if (!empty(loc))
        if (filereadable("tags"))
            exe "set tags=" . loc . "/tags" 
        endif
        if (filereadable("cscope.out"))
            set nocscopeverbose
            exe "cs add " . loc . "/cscope.out"
            set cscopeverbose
        endif
    endif
    lcd -
endfunction
au BufEnter * call LoadTags()

" cmd for create tags and cscope db
function! CreateTags() 
    let loc = input("project root: ", expand("%:p:h"))
    exe "lcd " . loc
    let files = systemlist("find . -type f")
    call filter(files, 'v:val =~# g:tags_supported_types')
    " create if not exists; or empty target
    exe "silent !echo -n \"\" > cscope.files"
    call writefile(files, "cscope.files", "a")

    " create cscope db 
    exe "silent !" . g:tags_cscope_cmd . " -i cscope.files"
    exe "silent !" . g:tags_ctags_cmd . " -L cscope.files"
    lcd -
    call LoadTags()
endfunction

" auto update tags and cscope db if loaded
function! UpdateTags() 
    let curfile = fnamemodify(expand("%:p"), ":.")
    let loc = fnamemodify(Fixed_findfile("cscope.files"), ":p:h")
    exe "lcd " . loc
    if match(curfile, g:tags_supported_types) >= 0
        if (!empty(loc))
            if (filewritable("tags")) 
                exe "silent !" . g:tags_ctags_cmd . " " . curfile 
                " no need to reload
            endif
            if (filewritable("cscope.out"))
                exe "silent !" . g:tags_cscope_cmd . " " . curfile
                exe "silent cs reset"
            endif
        else
            call CreateTags()
        endif
    endif
    lcd -
endfunction
" update tags on :w
au BufWritePost * call UpdateTags()


"}}}

" => Files "{{{
"
" ts    - tabstop       - tab宽度
" sts   - softtabstop   - 按下tab时的宽度（用tab和space组合填充）
" sw    - shiftwidth    - 自动缩进宽度
" et    - expandtab     - 是否展开tab
" tw    - textwidth     - 文本宽
" ai    - autoindent 

" For all
"set noautochdir 		        " may cause problem to some plugins

" For c/c++ 
au FileType c,cpp setlocal ts=4 sts=4 sw=4 tw=79 et ff=unix

" For python 
au FileType python setlocal ts=4 sts=4 sw=4 tw=79 et ff=unix

au FileType zsh,vim setlocal ts=4 sts=4 sw=4 tw=79 et ff=unix

"}}}


" => Plugin "{{{
" NERDTreeToggle
nmap <F9> :NERDTreeToggle <CR> 

" tagbar [FIXME: tagbar use on fly tags, but we have loaded a tag file]
nmap <F10> :TagbarToggle<CR>
let g:tagbar_compact = 1                "
let g:tagbar_iconchars = ['+', '-']     "
let g:tagbar_autoshowtag = 1

" syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" neocompletion
let g:neocomplete#enable_at_startup = 1
" neocompletion settings
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" <TAB>: completion.
"inoremap <expr><TAB> pumvisible() ? neocomplete#complete_common_string() : "\<TAB>"
" Set minimum match keyword length. 
let g:neocomplete#auto_completion_start_length = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
            \ 'default' : '',
            \ 'vimshell' : $HOME.'/.vimshell_hist',
            \ 'scheme' : $HOME.'/.gosh_completions'
            \ }
" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'
" Plugin key-mappings.
inoremap <expr><C-g>    neocomplete#undo_completion()
inoremap <expr><C-l>    neocomplete#complete_common_string()
" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" jedi completion
let g:jedi#auto_initialization = 1
" jedi settings
let g:jedi#completions_command = '<C-n>'
let g:jedi#show_call_signatures = "2"
" disable neocomplete for python
au FileType python NeoCompleteLock

" }}}

