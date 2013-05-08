let mapleader = " "

set nocompatible
set nobackup
set nowritebackup
set noswapfile
set history=50
set ruler
set incsearch
set hlsearch
set ignorecase
set smartcase
set laststatus=2
set encoding=utf-8
set showcmd
set showmode
set scrolloff=5
set autoread
set cc=130
" hi ColorColumn ctermbg=lightblue guibg=lightblue
set tabstop=2
set shiftwidth=2
set expandtab
set list listchars=tab:»·,trail:·

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on

augroup vimrcEx
  au!

"   For all text files set 'textwidth' to 78 characters.
"  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
augroup END

if executable("ag")
  set grepprg=ag\ --nogroup\ --nocolor
endif

" Color scheme
set background=dark
colorscheme twilight256
" highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0
highlight ColorColumn ctermbg=darkgray guibg=#ADD8E6

" Numbers
set number
set numberwidth=5

" Snippets are activated by Shift+Tab
let g:snippetsEmu_key = "<S-Tab>"

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
set complete=.,w,t
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>

" Exclude Javascript files in :Rtags via rails.vim due to warnings when parsing
let g:Tlist_Ctags_Cmd="ctags --exclude='*.js'"

" Index ctags from any project, including those outside Rails
map <Leader>ct :!ctags -R .<CR>
map <Leader>l :NERDTreeToggle<CR>
map <Leader>L :NERDTree<CR>

" Cucumber navigation commands
autocmd User Rails Rnavcommand step features/step_definitions -glob=**/* -suffix=_steps.rb
autocmd User Rails Rnavcommand config config -glob=**/* -suffix=.rb -default=routes

" Switch between the last two files
nnoremap <leader><leader> <c-^>
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>
nnoremap <Leader>s :call RunCurrentSpecFile()<CR>
"nnoremap <Leader>s :call RunNearestSpec()<CR>
"nnoremap <Leader>l :call RunLastSpec()<CR>
nnoremap <Leader>e :e .<CR>
nnoremap <Leader>a :Tabularize /:/l0l1
silent! nnoremap <unique> <silent> <Leader>t :CtrlP<CR>
silent! nnoremap <unique> <silent> <Leader>b :CtrlPBuffer<CR>
silent! nnoremap <unique> <silent> <Leader>T :CtrlPTag<CR>
silent! nnoremap <unique> <silent> <Leader>f :CtrlPFiletype<CR>

function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

nnoremap <C-n> :call NumberToggle()<CR>

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Set syntax highlighting for specific file types
au BufRead,BufNewFile *.md set filetype=markdown

" Enable spellchecking for Markdown
au BufRead,BufNewFile *.md setlocal spell

" Automatically wrap at 80 characters for Markdown
" au BufRead,BufNewFile *.md setlocal textwidth=80

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
