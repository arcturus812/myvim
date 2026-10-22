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

" ,cq asks Copilot in a popup at the cursor without opening a chat window.
" Context is the visual selection, or lines around the cursor.
" In the popup: j/k/Ctrl-d/Ctrl-u scroll, y yanks the answer, q/Esc closes.
let s:copilot_popup_context_lines = 40

function! s:CopilotPopupFilter(winid, key) abort
    let l:scroll = {'j': 1, 'k': -1, "\<C-d>": 10, "\<C-u>": -10}
    if has_key(l:scroll, a:key)
        let l:first = max([1, popup_getoptions(a:winid).firstline + l:scroll[a:key]])
        call popup_setoptions(a:winid, {'firstline': l:first})
    elseif a:key ==# 'y'
        call setreg('"', getbufline(winbufnr(a:winid), 1, '$'))
        echo 'Copilot answer yanked'
    elseif a:key ==# 'q' || a:key ==# "\<Esc>"
        call popup_close(a:winid)
    else
        return 0
    endif
    return 1
endfunction

function! s:CopilotPopupDone(winid, output, job, status) abort
    if empty(popup_getpos(a:winid))
        return
    endif
    try
        let l:answer = json_decode(join(a:output, ''))
        let l:lines = split(l:answer.choices[0].message.content, "\n")
    catch
        let l:lines = ['Copilot request failed (exit ' . a:status . '):'] + a:output
    endtry
    call popup_settext(a:winid, l:lines)
endfunction

function! s:CopilotPopupAsk(visual) abort
    if !s:CopilotChatLoad()
        return
    endif
    if empty(g:copilot_chat_token)
        echohl WarningMsg | echomsg 'Copilot is still signing in; try again shortly' | echohl None
        return
    endif
    if a:visual
        let [l:first, l:last] = [line("'<"), line("'>")]
    else
        let l:first = max([1, line('.') - s:copilot_popup_context_lines / 2])
        let l:last = min([line('$'), line('.') + s:copilot_popup_context_lines / 2])
    endif
    let l:question = input('Copilot> ')
    redraw
    if empty(l:question)
        return
    endif
    let l:context = printf("File: %s (lines %d-%d, cursor at line %d)\n```%s\n%s\n```",
                \ expand('%:.'), l:first, l:last, line('.'), &filetype,
                \ join(getline(l:first, l:last), "\n"))
    let l:body = json_encode({
                \ 'model': copilot_chat#models#Current(),
                \ 'stream': v:false,
                \ 'messages': [
                \   {'role': 'system', 'content': 'You are a code review assistant. Answer concisely.'},
                \   {'role': 'user', 'content': l:context . "\n\n" . l:question}]})
    let l:tmpfile = tempname()
    call writefile([l:body], l:tmpfile)
    let l:winid = popup_create(['Copilot: thinking...'], {
                \ 'line': 'cursor+1', 'col': 'cursor', 'pos': 'topleft',
                \ 'minwidth': 40, 'maxwidth': min([100, &columns - 4]),
                \ 'maxheight': max([5, &lines / 2]),
                \ 'border': [], 'padding': [0, 1, 0, 1], 'title': ' Copilot: ' . l:question . ' ',
                \ 'scrollbar': 1, 'wrap': 1, 'mapping': 0,
                \ 'filter': function('s:CopilotPopupFilter')})
    call setbufvar(winbufnr(l:winid), '&filetype', 'markdown')
    let l:output = []
    call job_start(['curl', '-s', '-X', 'POST',
                \ '-H', 'Content-Type: application/json',
                \ '-H', 'Authorization: Bearer ' . g:copilot_chat_token,
                \ '-H', 'Editor-Version: vscode/1.107.0',
                \ '-H', 'Editor-Plugin-Version: copilot-chat/0.36.2025121601',
                \ '-d', '@' . l:tmpfile, 'https://api.githubcopilot.com/chat/completions'], {
                \ 'out_cb': {ch, msg -> add(l:output, msg)},
                \ 'exit_cb': {job, status -> [delete(l:tmpfile), s:CopilotPopupDone(l:winid, l:output, job, status)]}})
endfunction

nnoremap <silent> <leader>cq :call <SID>CopilotPopupAsk(0)<cr>
xnoremap <silent> <leader>cq :<C-u>call <SID>CopilotPopupAsk(1)<cr>
