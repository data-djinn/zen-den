        set fileencoding=utf-8

        set expandtab
        set number
        set shiftwidth=4
        set smartcase
        set tabstop=4

        set backspace=indent,eol,start

        set softtabstop=0

        set hlsearch
        set incsearch
        set ignorecase
        set smartcase

        syntax on

        colorscheme molokai

        set wildmenu

        "" always show status bar
        set laststatus=2

        "" center screen on search match
        nnoremap n nnzzzv
        nnoremap N Nzzzv

        let g:indentLine_enabled = 1
        let g:indentLine_faster = 1

        command! FixWhitespace :%s/\s\+$//e

        augroup vimrc-sync-fromstart
          autocmd!
          autocmd BufEnter * :syntax sync maxlines=200
        augroup END

        set autoread
