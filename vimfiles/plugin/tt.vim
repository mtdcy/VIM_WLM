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

" simple IDE setup by Chen Fang

" ==> Initialization check {{{
if exists("g:simple_ide_setup")
    finish
endif

let g:simple_ide_setup = 1

" <== END }}}

" ==> Functions for tags management {{{

" FIXME: use vim's filetype detection
let s:tags_ctags_cmd = "ctags --fields=+ailS --c-kinds=+p --c++-kinds=+p --sort=no --extra=+q"
let s:tags_cscope_cmd = "cscope -bq"

function! tt#find_project_root()
    if exists('b:project_root')     " cache
        "echo "cached b:project_root: [" . b:project_root . "]"
        return b:project_root
    endif

    exe "lcd " . expand("%:p:h")
    let id = findfile("cscope.files", ".;")
    if (empty(id))
        let b:project_root = ''
    else 
        let b:project_root = fnamemodify(id, ":p:h")
    endif
    "echo "b:project_root: [" . b:project_root . "]"
    lcd -
    return b:project_root
endfunction

" load tags and cscope db
function! tt#tags_load()
    let root = tt#find_project_root()
    if (empty(root))
        return
    else
        exe "lcd " . root
        if (filereadable("tags"))                                   " load ctags
            exe "set tags=" . root . "/tags"
        endif
        if (filereadable("cscope.out"))                             " load cscope db
            set nocscopeverbose
            exe "cs add " . root . "/cscope.out " . root
            set cscopeverbose
        endif
        lcd -
    endif
endfunction

" create tags and cscope db
function! tt#tags_create()
    let root = input("project root: ", expand("%:p:h"))             " project root
    exe "lcd " . root
    let files = glob("**", v:false, v:true)
    call filter(files, 'filereadable(v:val)')                       " filter out directory
    call filter(files, 'v:val =~# g:tags_interested_types')          " only interested files
    call writefile(files, "cscope.files")                           " save list
    exe "silent !" . s:tags_cscope_cmd . " -i cscope.files"
    exe "silent !" . s:tags_ctags_cmd . " -L cscope.files"
    lcd -
    call tt#tags_load()
endfunction

" update tags and cscope db if loaded
function! tt#tags_update()
    let root = tt#find_project_root()
    if (empty(root))
        return
    else
        exe "lcd " . root
        let file = fnamemodify(expand("%:p"), ":.")                     " path related to project root
        if match(file, g:tags_interested_types) >= 0
            let files = readfile("cscope.files")
            if match(files, file) < 0
                files+=file
                call writefile(files, "cscope.files")
            endif
            if (!empty(root))
                if (filewritable("tags"))                               " update ctags
                    exe "silent !" . s:tags_ctags_cmd . " -i cscope.files"
                    " no need to reload
                endif
                if (filewritable("cscope.out"))                         " update cscope db and reload
                    exe "silent !" . s:tags_cscope_cmd . " -L cscope.files"
                    exe "silent cs reset"
                endif
            endif
        endif
        lcd -
    endif
endfunction

function! tt#getchar_bofore_cursor()
    if col('.') > 0 
        return strpart(getline('.'), col('.') - 2, 1)
    else " empty or space
        return ' '
    endif
endfunction

function! tt#supertab()
    if pumvisible()
        " next candidate on pop list
        return "\<C-N>"
    elseif tt#getchar_bofore_cursor() == ' '
        " insert tab
        return "\<TAB>"
    elseif &ft ==? 'python' &&
                \ exists(':JediDebugInfo')
        " using jedi-vim's completion
        return jedi#complete_string(0)
    elseif exists('g:neocomplete#disable_auto_complete') && 
                \ g:neocomplete#disable_auto_complete  &&
                \ exists(':NeoCompleteToggle')
        " because of vim's issue, this may not working 
        " https://github.com/Shougo/neocomplete.vim/issues/334
        let s = neocomplete#complete_common_string()
        if empty(s)
            return neocomplete#start_manual_complete()
        else
            return common
        endif
    else 
        " omni completion
        return "\<C-X>\<C-O>"
    endif
endfunction

" <== END }}}

" ==> Configurations {{{
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

augroup tagsmngr
    au!
    " load tags on BufEnter
    au BufReadPost * call tt#tags_load()
    " update tags on :w
    au BufWritePost * call tt#tags_update()
augroup END

" supertab
inoremap <expr><TAB>  tt#supertab()
nnoremap <TAB> :bn<CR>
nnoremap <S-TAB> :bp<CR>

" <== END }}}

" ==> Commands {{{
command! -nargs=0 -bar InitTags call tt#tags_create()

" <== END }}}
