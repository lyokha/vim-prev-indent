" File: prev_indent.vim
" Author: Alexey Radkov
" Version: 0.3
" Description: Utility functions for custom indentation of line under cursor
" Usage:
"   Command PrevIndent moves the line under the cursor to the previous
"   indentation level. At the first sight, this command does not seem to be
"   any helpful as soon as indentation levels in the most of the file types
"   usually correspond to the value of 'shiftwidth' and the desired effect can
"   be easily achieved by pressing <C-d> repeatedly in Insert mode. But this
"   is not always the case.
"
"   Command PrevIndent merely aligns the beginning of the current line with
"   the first met line that lies above and starts from a less position.
"
"   Recommended mappings are
"
"   Insert mode:
"
"       imap <silent> <C-d>       <Plug>PrevIndent
"
"   if you want to use PrevIndent instead of the standard Insert mapping, or
"
"       imap <silent> <C-g><C-g>  <Plug>PrevIndent
"
"   (press <C-g> twice) otherwise.
"
"   Normal mode:
"
"       nmap <silent> <C-k>k      :PrevIndent<CR>
"
"   Another command provided by this plugin is AlignWith. It finds a symbol
"   that was specified by the user on the right hand side of the previous line
"   and then aligns the beginning of the current line with the column of the
"   found symbol. If the symbol was not found on the right hand side of the
"   previous line then it gets searched from the beginning of the previous
"   line. Repeating AlignWith will cycle the alignment of the current line to
"   the right through all positions of the searched symbol in the previous
"   line. The user can specify the order of the symbol to search. For example,
"   issuing command
"
"       :AlignWith 2
"
"   and then pressing '(' shall skip the first found '(' in the previous line
"   and align the current line to the second found parenthesis.
"
"   Recommended mappings are
"
"   Insert mode:
"
"       imap <silent> <C-g>g      <Plug>AlignWith
"
"   Normal mode:
"
"       nmap <silent> <C-k>g      :AlignWith<CR>
"
"   In both Insert and Normal modes command AlignWith will wait till the user
"   enters a character to align with. So, for example, in Insert mode the user
"   must enter <C-g>g and then any other character to proceed.
"
"   Both PrevIndent and AlignWith commands should behave well for different
"   settings of the <Tab> expansion.


if exists('g:loaded_PrevIndentPlugin') && g:loaded_PrevIndentPlugin
    finish
endif

let g:loaded_PrevIndentPlugin = 1

function! s:prev_indent()
    let save_cursor = getpos('.')
    let save_winline = winline()
    noautocmd normal ^
    let start_pos = virtcol('.') - 1
    if start_pos == 0
        call setpos('.', save_cursor)
        return ''
    endif
    let rstart_pos = col('.') - 1
    let cur_start_pos = 0
    let subst = ''
    let pass = 0
    while line('.') > 1
        noautocmd normal k^
        if getline('.') =~ '^\s*$'
            continue
        endif
        let cur_start_pos = virtcol('.') - 1
        let rcur_start_pos = col('.') - 1
        if cur_start_pos < start_pos
            let subst = substitute(getline('.'), '\S.*', '', '')
            let pass = 1
            break
        endif
    endwhile
    if !pass
        call setpos('.', save_cursor)
        return ''
    endif
    call setpos('.', save_cursor)
    exe 's/^\s\+/'.subst.'/'
    let save_cursor[2] -= rstart_pos - rcur_start_pos
    if save_cursor[2] < 1
        let save_cursor[2] = 1
    endif
    call setpos('.', save_cursor)
    let scroll = winline() - save_winline
    if scroll != 0
        noautocmd exe 'normal '.abs(scroll).(scroll > 0 ? '': '')
        " by some reason scrolling may move cursor left if it was in the
        " rightmost position: restore it
        call setpos('.', save_cursor)
    endif
    return ''
endfunction

function! s:align_with(symb, ...)
    let save_cursor = getpos('.')
    let add_rstart_pos = getline('.') =~ '^\s*$' && col('.') == col('$') ?
                \ 1 : 0
    noautocmd normal ^
    let start_pos = virtcol('.') - 1 + add_rstart_pos
    let rstart_pos = col('.') - 1 + add_rstart_pos
    let save_start_pos = 0
    let pass = 0
    while line('.') > 1
        noautocmd normal k
        if getline('.') =~ '^\s*$'
            continue
        endif
        let pass = 1
        break
    endwhile
    if !pass
        call setpos('.', save_cursor)
        return ''
    endif
    let last_symb_match = (col('.') + add_rstart_pos >= col('$') - 1) &&
                \ getline('.')[col('$') - 2] == a:symb
    noautocmd normal l
    if add_rstart_pos == 1
        noautocmd normal l
    endif
    let n_repeat = a:0 && a:1 > 0 ? a:1 : 1
    let save_n_repeat = n_repeat
    let save_cursor1 = getpos('.')
    if getline('.')[col('.') - 1] == a:symb
        let n_repeat -= 1
    endif
    if n_repeat > 0
        noautocmd exe 'normal '.n_repeat.'f'.a:symb
    endif
    let n_repeat = save_n_repeat
    if (col('.') == save_cursor1[2] &&
                \ getline('.')[col('.') - 1] != a:symb) || last_symb_match
        noautocmd normal ^
        let save_cursor1 = getpos('.')
        if getline('.')[col('.') - 1] == a:symb
            let n_repeat -= 1
        endif
        if n_repeat > 0
            noautocmd exe 'normal '.n_repeat.'f'.a:symb
        endif
        if col('.') == save_cursor1[2] && n_repeat > 0
            let save_start_pos = 1
        endif
        if col('.') == save_cursor1[2] && getline('.')[col('.') - 1] != a:symb
            call setpos('.', save_cursor)
            return ''
        endif
    endif
    let cur_start_pos = virtcol('.') - 1
    call setpos('.', save_cursor)
    let offset = save_start_pos ? 0 : cur_start_pos - start_pos
    if offset == 0
        call setpos('.', save_cursor)
        return ''
    endif
    if offset > 0
        exe 's/^\s*/\=submatch(0).repeat(" ", '.offset.')/'
    else
        exe 's/^\s*/\=repeat(" ", '.(start_pos + offset).')/'
    endif
    retab!
    noautocmd normal ^
    let save_cursor[2] += col('.') - 1 - rstart_pos + add_rstart_pos
    call setpos('.', save_cursor)
    return ''
endfunction

function! s:getchar_align_with(...)
    while getchar(1)
        call getchar()
    endwhile
    let symb = nr2char(getchar())
    return s:align_with(symb, a:0 ? a:1 : 1)
endfunction

command!          PrevIndent  call s:prev_indent()
command! -nargs=? AlignWith   call s:getchar_align_with(<f-args>)

imap <silent> <Plug>PrevIndent  <C-r>=<SID>prev_indent()<CR>
imap <silent> <Plug>AlignWith   <C-r>=<SID>getchar_align_with()<CR>

