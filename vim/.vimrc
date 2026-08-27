set number              " line numbrs
set relativenumber      " relative nums (easier j/k movement)
set history=1000        " keep more commands in history
set undolevels=1000     " deeper undo depth (u)
set title               " show filename in terminal title
set mouse=a             " mouse support (scroll, selection, etc)

syntax on               " syntax hlight
set t_Co=256            " 256 colors for terminal
set cursorline          " highlight current line
set showmatch           " show matching brackets

set tabstop=4           " tab width = 4 spaces
set shiftwidth=4        " indent size for >> and << 
set softtabstop=4       " spaces when hittin tab
set expandtab           " turn tabs into spaces (python style)
set autoindent          " auto indentation
set smartindent         " smart indent for curly braces

set hlsearch            " highlight search results
set incsearch           " search on the fly while typin
set ignorecase          " ignore case when searchin...
set smartcase           " ...until i use uppercase

set encoding=utf-8      " default enc
set fileencodings=utf-8,cp1251,koi8-r  " read older encodings too
set noswapfile          " dont spawn annoying .swp files everywhere
set nobackup            " dont backup on save

" hotkeys
nnoremap <Esc><Space> :noh<CR>
nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprevious<CR>

" move viminfo history out of home root to cache
set viminfofile=$HOME/.cache/viminfo
