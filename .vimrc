" Sets how many lines of history VIM has to remember
set history=5000
 
" Use spaces vs hard tab
set ts=2 expandtab
 
" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2
 
" Tab and backspace are smart
set smarttab
 
" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Show (partial) command in status line.
set showcmd

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Remap VIM 0 to first non-blank character
map 0 ^

" With a map leader it's possible to do extra key combinations
let mapleader = ","

" Bold and underline misspelled words
hi SpellBad cterm=underline,bold

" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell! spelllang=en_us<cr>

" Always set cwd to directory of open file
set autochdir

" Allows for clipboard sharing between vim and host (TODO doesn't seem to work on all systems)
set clipboard=unnamedplus

" F5 shows a list of all open buffers, which can be selected from easily
map <F5> :buffers<CR>:buffer<Space>

" Configure tabs to show number, file name and + if edited
" Switch to a given tab with 4gt, for tab 4
"set guitablabel=\[%N\]\ %t\ %M
set guitablabel=%t

" Wrap text at 79 chars
set textwidth=79

set formatoptions=n

" Preserve indentation when wraping text
set breakindent
set showbreak=\ \\_  
