"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Important:
"       This requries that you install https://github.com/amix/vimrc !
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""
" => Load pathogen paths
""""""""""""""""""""""""""""""
let s:vim_runtime = expand('<sfile>:p:h')."/.."
" copilot-chat.vim is loaded on first use (see Copilot Chat below)
let g:pathogen_disabled = ['copilot-chat.vim']
call pathogen#infect(s:vim_runtime.'/sources_forked/{}')
call pathogen#infect(s:vim_runtime.'/sources_non_forked/{}')
call pathogen#infect(s:vim_runtime.'/my_plugins/{}')
call pathogen#helptags()

""""""""""""""""""""""""""""""
" => CTRL-P
""""""""""""""""""""""""""""""
let g:ctrlp_working_path_mode = 0

let g:ctrlp_map = '<c-f>'
map <leader>j :CtrlP<cr>
map <c-b> :CtrlPBuffer<cr>

let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git'


""""""""""""""""""""""""""""""
" => Vim grep
""""""""""""""""""""""""""""""
set grepprg=/bin/grep\ -nH


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => surround.vim config
" Annotate strings with gettext 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vmap Si S(i_<esc>f)


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => lightline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             ['fugitive', 'readonly', 'filename', 'modified', 'tagbar'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*FugitiveHead")?FugitiveHead():""}',
      \   'tagbar': '%{exists(":TagbarToggle")?tagbar#currenttag("%s","","f"):""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*FugitiveHead") && ""!=FugitiveHead())'
      \ },
      \ 'separator': { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': ' ', 'right': ' ' }
      \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Syntastic (syntax checker)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_linters = {
\   'javascript': ['jshint'],
\   'python': ['flake8']
\}

nmap <silent> <leader>a <Plug>(ale_next_wrap)

" Disabling highlighting
let g:ale_set_highlights = 0

" Keep messages out of the line end (blamer uses it); Vim 9 enables this by default
let g:ale_virtualtext_cursor = 'disabled'

" Only run linting when saving the file
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Git gutter (Git diff)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_enabled=0
nnoremap <silent> <leader>d :GitGutterToggle<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Blamer (inline git blame for the current line)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:blamer_enabled = 1
let g:blamer_delay = 500
let g:blamer_show_in_insert_modes = 0
let g:blamer_show_in_visual_modes = 0
let g:blamer_date_format = '%Y-%m-%d'
nnoremap <silent> <leader>bl :BlamerToggle<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Copilot Chat
"    Needs Vim 9 and starts GitHub sign-in when loaded, so it is
"    loaded on the first ,cp instead of at startup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:CopilotChatLoad() abort
    if v:version < 900
        echohl WarningMsg | echomsg 'Copilot Chat requires Vim 9.0+' | echohl None
        return 0
    endif
    if !exists('g:loaded_copilot_chat')
        " Tokens live here; keep them outside the repo and private
        let g:copilot_chat_data_dir = expand('~/.vim/copilot-chat')
        if !isdirectory(g:copilot_chat_data_dir)
            call mkdir(g:copilot_chat_data_dir, 'p', 0700)
        endif
        execute 'set runtimepath+=' . fnameescape(s:vim_runtime . '/sources_forked/copilot-chat.vim')
        runtime plugin/copilot_chat.vim
    endif
    return 1
endfunction

function! s:CopilotChatOpen() abort
    if s:CopilotChatLoad()
        CopilotChatOpen
    endif
endfunction

function! s:CopilotChatAddSelection() abort
    if s:CopilotChatLoad()
        call copilot_chat#buffer#AddSelection()
    endif
endfunction

nnoremap <silent> <leader>cp :call <SID>CopilotChatOpen()<cr>
xnoremap <silent> <leader>cp :<C-u>call <SID>CopilotChatAddSelection()<cr>
