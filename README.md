Vim-prev-indent
===============

Command `PrevIndent` moves the line under the cursor to the previous
indentation level. At the first sight, this command does not seem to be
really helpful as soon as indentation levels in the most of the file types
usually correspond to the value of the `shiftwidth`, and the desired effect
can be easily achieved by pressing `<C-d>` repeatedly in Insert mode. But
this is not always the case.

Command `PrevIndent` merely aligns the beginning of the current line with
the first met line that lies above and starts from a less position.

Recommended mappings are

*Insert mode*

```vim
    imap <silent> <C-d>       <Plug>PrevIndent
```

if you want to use `PrevIndent` instead of the standard Insert mapping, or

```vim
    imap <silent> <C-g><C-g>  <Plug>PrevIndent
```

(press `<C-g>` twice) otherwise.

*Normal mode*

```vim
    nmap <silent> <C-k>k      :PrevIndent<CR>
```

Another command provided by this plugin is `AlignWith`. It finds a symbol
that was specified by the user on the right hand side of the previous line
and then aligns the beginning of the current line with the column of the
found symbol. If the symbol was not found on the right hand side of the
previous line then it gets searched from the beginning of the previous
line. Repeating `AlignWith` will cycle the alignment of the current line to
the right through all positions of the searched symbol in the previous
line. The user can specify the order of the symbol to search. For example,
issuing command

```vim
    :AlignWith 2
```

and then pressing *(* shall skip the first found *(* in the previous line
and align the current line to the second found parenthesis.

Recommended mappings are

*Insert mode*

```vim
    imap <silent> <C-g>g      <Plug>AlignWith
```

*Normal mode*

```vim
    nmap <silent> <C-k>g      :AlignWith<CR>
```

In both Insert and Normal modes command `AlignWith` will wait until the user
enters a character to align with. So, for example, in Insert mode the user
must enter `<C-g>g` and then another character to proceed.

Both `PrevIndent` and `AlignWith` commands should behave well for different
settings of the `<Tab>` expansion.

