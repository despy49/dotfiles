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

" no jumps for signs
set signcolumn=yes

" hotkeys
nnoremap <Esc><Space> :noh<CR>
nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprevious<CR>


" ==== AUTOCLOSE BRACKETS AND QUOTES

" sam line autoclose
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap " ""<Left>
inoremap ' ''<Left>

" smart autoclose with NL and indentation
" when pressed '{' then 'Enter', Vim will space the bracket and make indent
inoremap { {}<Left>
inoremap {<CR> {<CR>}<Esc>O



" move viminfo history out of home root to cache
set viminfofile=$HOME/.cache/viminfo

" no tab2space conversion in make files
autocmd FileType make set noexpandtab   


" ===============INIT PATHS FOR DOTFILES
" make vim look for files in dotfiels
set packpath^=$HOME/.dotfiles/vim/.vim
set runtimepath^=$HOME/.dotfiles/vim/.vim

" scan for native packages if paths have changed
packloadall


" RUST ANALYZER
if executable('rust-analyzer')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'rust-analyzer',
        \ 'cmd': {server_info->['rust-analyzer']},
        \ 'allowlist': ['rust'],
        \ })
endif





" ================INSTANT AUTOCOMPLETION POPUPS
" Allow popups
let g:asyncomplete_auto_popup = 1

" Forbid asyncomplete to reset windows display params
let g:asyncomplete_auto_completeopt = 0

" menu params:
" menuone — show even for single option
" noinsert — don't paste text automtically
" noselect — don't select 1st str until tab is pressed
set completeopt=menuone,noinsert,noselect

" Close docs window when out of insert mode
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Menu navigation using Tab and Shift+Tab
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Select the hint using Выбор  Enter
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() . "\<cr>" : "\<cr>"


" ============VIM-LSP BINDING and HOTKEYS

function! s:on_lsp_buffer_enabled() abort
    " enable icons to the left from line numbers
    setlocal signcolumn=yes 
    
    " !!!!: disable omnifunc=lsp#complete, for asyncomplete to work while typing
    " If omnifunc is kept here, asynccomplete won't work
    
    " navi hotkeys:
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <f2> <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> <Space>ca <plug>(lsp-code-action-float)
    
    " gofmt on save
    autocmd BufWritePre <buffer> LspDocumentFormatSync
endfunction

augroup lsp_install
    autocmd!
    " enable hotkeys when lsp has connected to the file
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" enable erorrs visual
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_highlights_enabled = 1
let g:lsp_diagnostics_signs_enabled = 1

" show code actions menu floating
let g:lsp_code_action_ui = 'float'


" ====== LSP RESTART
function! s:async_lsp_restart() abort
    " stop server
    execute 'LspStopServer'
    
    " wait for 200 ms and reopen the file
    call timer_start(200, {-> execute('edit')})
endfunction

" iregister the command bound to the func
command! LspRestart call s:async_lsp_restart()




" ============MENU COLORS FOR AUTOMPLTE

" Pmenu — menu line: dark grey background, light grey text
highlight Pmenu ctermfg=251 ctermbg=236

" PmenuSel — selected line: white text, blue background
highlight PmenuSel ctermfg=15 ctermbg=33

" PmenuSbar — scrollbar: grey background
highlight PmenuSbar ctermbg=240

" PmenuThumb — scrollbar slider: light grey
highlight PmenuThumb ctermbg=247




" ============INTERACTIVE FILE SEARCH (FZF + RG) 

" append system path for  fzf from Arch Linux
set runtimepath+=/usr/share/fzf

" load added pkgs
packloadall

" Hotkeys
nnoremap <C-p> :Files<CR>
nnoremap <Space>fg :Rg<CR>

" Cheap and simple file jumps
nnoremap <leader>h1 'A
nnoremap <leader>h2 'B
nnoremap <leader>h3 'C

