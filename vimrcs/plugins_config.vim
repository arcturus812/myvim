"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Important:
"       This requries that you install https://github.com/amix/vimrc !
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""
" => Load pathogen paths
""""""""""""""""""""""""""""""
let s:vim_runtime = expand('<sfile>:p:h')."/.."
" Copilot plugins are loaded on first use (see Copilot Chat below)
let g:pathogen_disabled = ['copilot-chat.vim', 'copilot.vim']
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
"
" ,ce asks Copilot to edit the visual selection (or the function around the
" cursor), applies the result as one undo step and highlights it: removed
" lines show in red above, new lines in green. y keeps it, n undoes it;
" other keys work as usual so the change can be inspected first.
let s:copilot_popup_context_lines = 40
let s:copilot_edit_function_kinds = ['function', 'method', 'member', 'subroutine', 'procedure', 'func']

" Send chat messages to Copilot; a:Callback gets (content, error)
function! s:CopilotRequest(messages, Callback) abort
    let l:tmpfile = tempname()
    call writefile([json_encode({'model': copilot_chat#models#Current(),
                \ 'stream': v:false, 'messages': a:messages})], l:tmpfile)
    let l:output = []
    call job_start(['curl', '-s', '-X', 'POST',
                \ '-H', 'Content-Type: application/json',
                \ '-H', 'Authorization: Bearer ' . g:copilot_chat_token,
                \ '-H', 'Editor-Version: vscode/1.107.0',
                \ '-H', 'Editor-Plugin-Version: copilot-chat/0.36.2025121601',
                \ '-d', '@' . l:tmpfile, 'https://api.githubcopilot.com/chat/completions'], {
                \ 'out_cb': {ch, msg -> add(l:output, msg)},
                \ 'exit_cb': {job, status -> s:CopilotRequestDone(l:tmpfile, l:output, status, a:Callback)}})
endfunction

function! s:CopilotRequestDone(tmpfile, output, status, Callback) abort
    call delete(a:tmpfile)
    try
        let l:content = json_decode(join(a:output, '')).choices[0].message.content
    catch
        call a:Callback('', 'Copilot request failed (exit ' . a:status . '): ' . join(a:output, ' '))
        return
    endtry
    call a:Callback(l:content, '')
endfunction

function! s:CopilotReady() abort
    if !s:CopilotChatLoad()
        return 0
    endif
    if empty(g:copilot_chat_token)
        echohl WarningMsg | echomsg 'Copilot is still signing in; try again shortly' | echohl None
        return 0
    endif
    return 1
endfunction

" Code is sent with '<lnum>: ' prefixes plus ALE diagnostics in the range,
" like CopilotChat.nvim does, so answers can point at exact lines
let s:copilot_line_prefix_note = ' Code lines are prefixed with "<line number>: " for reference only;'
            \ . ' never include these prefixes in code you write.'

function! s:CopilotContext(first, last) abort
    let l:code = map(getline(a:first, a:last), {i, line -> (a:first + i) . ': ' . line})
    let l:context = printf("File: %s (lines %d-%d, cursor at line %d)\n```%s\n%s\n```",
                \ expand('%:.'), a:first, a:last, line('.'), &filetype, join(l:code, "\n"))
    let l:problems = exists('*ale#engine#GetLoclist')
                \ ? filter(copy(ale#engine#GetLoclist(bufnr('%'))), {_, item -> item.lnum >= a:first && item.lnum <= a:last})
                \ : []
    if !empty(l:problems)
        let l:context .= "\nDiagnostics:\n" . join(map(l:problems,
                    \ {_, item -> printf('%d: [%s] %s', item.lnum, get(item, 'type', 'E'), item.text)}), "\n")
    endif
    return l:context
endfunction

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

function! s:CopilotPopupOpen(title, lines) abort
    let l:winid = popup_create(a:lines, {
                \ 'line': 'cursor+1', 'col': 'cursor', 'pos': 'topleft',
                \ 'minwidth': 40, 'maxwidth': min([100, &columns - 4]),
                \ 'maxheight': max([5, &lines / 2]),
                \ 'border': [], 'padding': [0, 1, 0, 1], 'title': ' ' . a:title . ' ',
                \ 'scrollbar': 1, 'wrap': 1, 'mapping': 0,
                \ 'filter': function('s:CopilotPopupFilter')})
    call setbufvar(winbufnr(l:winid), '&filetype', 'markdown')
    return l:winid
endfunction

function! s:CopilotPopupAnswer(winid, content, error) abort
    if !empty(popup_getpos(a:winid))
        call popup_settext(a:winid, split(empty(a:error) ? a:content : a:error, "\n"))
    endif
endfunction

function! s:CopilotPopupAsk(visual) abort
    if !s:CopilotReady()
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
    " #buffer sends the whole file, #gitdiff adds the file's uncommitted git diff
    if l:question =~# '#buffer\>'
        let [l:first, l:last] = [1, line('$')]
    endif
    let l:context = s:CopilotContext(l:first, l:last)
    if l:question =~# '#gitdiff\>'
        let l:diff = systemlist('git -C ' . shellescape(expand('%:p:h')) . ' diff HEAD -- ' . shellescape(expand('%:p')))
        let l:context .= "\nGit diff (uncommitted):\n```diff\n" . join(v:shell_error ? ['(not available)'] : l:diff, "\n") . "\n```"
    endif
    let l:messages = [
                \ {'role': 'system', 'content': 'You are a code review assistant. Answer concisely.' . s:copilot_line_prefix_note},
                \ {'role': 'user', 'content': l:context . "\n\n" . l:question}]
    let l:winid = s:CopilotPopupOpen('Copilot: ' . l:question, ['Copilot: thinking...'])
    call s:CopilotRequest(l:messages, function('s:CopilotPopupAnswer', [l:winid]))
endfunction

" Innermost multi-line function/method around the cursor, via ctags
function! s:EnclosingFunction() abort
    if !executable('ctags')
        return []
    endif
    let l:tmpfile = tempname() . (empty(expand('%:e')) ? '' : '.' . expand('%:e'))
    call writefile(getline(1, '$'), l:tmpfile)
    let l:tags = systemlist('ctags --fields=+neK -o - ' . shellescape(l:tmpfile))
    call delete(l:tmpfile)
    let l:best = []
    for l:tag in l:tags
        let l:fields = split(matchstr(l:tag, ';"\t\zs.*'), "\t")
        if empty(l:fields) || index(s:copilot_edit_function_kinds, l:fields[0]) < 0
            continue
        endif
        let l:start = str2nr(matchstr(l:tag, '\tline:\zs\d\+'))
        let l:end = str2nr(matchstr(l:tag, '\tend:\zs\d\+'))
        if l:start <= line('.') && line('.') <= l:end && l:start < l:end
                    \ && (empty(l:best) || l:start > l:best[0])
            let l:best = [l:start, l:end]
        endif
    endfor
    return l:best
endfunction

function! s:CopilotEditAsk(visual) abort
    if exists('s:copilot_edit')
        echohl WarningMsg | echomsg 'Finish the pending Copilot edit first (y/n)' | echohl None
        return
    endif
    if !s:CopilotReady()
        return
    endif
    if a:visual
        let l:range = [line("'<"), line("'>")]
    else
        let l:range = s:EnclosingFunction()
        if empty(l:range)
            let l:range = [max([1, line('.') - s:copilot_popup_context_lines / 2]),
                        \ min([line('$'), line('.') + s:copilot_popup_context_lines / 2])]
        endif
    endif
    let l:request = input(printf('Copilot edit (lines %d-%d)> ', l:range[0], l:range[1]))
    redraw
    if empty(l:request)
        return
    endif
    let l:messages = [
                \ {'role': 'system', 'content': 'You edit code. Reply with only the complete replacement'
                \   . ' for the given lines in one fenced code block, keeping the original indentation'
                \   . ' and style. Do not add explanations.' . s:copilot_line_prefix_note},
                \ {'role': 'user', 'content': s:CopilotContext(l:range[0], l:range[1]) . "\n\n" . l:request}]
    let l:pending = {'buf': bufnr('%'), 'first': l:range[0], 'last': l:range[1],
                \ 'tick': b:changedtick, 'request': l:request}
    echo 'Copilot: editing...'
    call s:CopilotRequest(l:messages, function('s:CopilotEditApply', [l:pending]))
endfunction

function! s:CopilotEditApply(pending, content, error) abort
    let l:code = matchlist(a:content, '```[^\n]*\n\(\_.\{-}\)\n\?```')
    if !empty(a:error) || empty(l:code)
        call s:CopilotPopupOpen('Copilot edit: no code returned', split(empty(a:error) ? a:content : a:error, "\n"))
        return
    endif
    if bufnr('%') != a:pending.buf || b:changedtick != a:pending.tick
        call s:CopilotPopupOpen('Copilot edit not applied: buffer changed meanwhile', split(l:code[1], "\n"))
        return
    endif
    let l:old = getline(a:pending.first, a:pending.last)
    let l:new = split(l:code[1], "\n", 1)
    " Drop line-number prefixes if the model echoed them back anyway
    if !empty(l:new) && len(filter(copy(l:new), {_, line -> line =~# '^\d\+: '})) == len(l:new)
        call map(l:new, {_, line -> substitute(line, '^\d\+: ', '', '')})
    endif
    let l:first = a:pending.first
    if l:new ==# l:old
        echo 'Copilot: no changes'
        return
    endif
    " Replace as one undo step
    let l:common = min([len(l:old), len(l:new)])
    if l:common > 0
        call setline(l:first, l:new[: l:common - 1])
    endif
    if len(l:new) > len(l:old)
        call append(l:first + len(l:old) - 1, l:new[len(l:old) :])
    elseif len(l:old) > len(l:new)
        call deletebufline('%', l:first + len(l:new), l:first + len(l:old) - 1)
    endif
    call s:CopilotEditHighlight(l:first, l:old, l:new)
    call cursor(l:first, 1)
    let s:copilot_edit = {'buf': a:pending.buf, 'tick': b:changedtick}
    let s:copilot_edit.popup = popup_create([' Accept Copilot edit? [y]es / [n]o '], {
                \ 'line': 1, 'col': &columns, 'pos': 'topright', 'border': [],
                \ 'title': ' ' . a:pending.request . ' ', 'highlight': 'WarningMsg',
                \ 'mapping': 0, 'filter': function('s:CopilotEditFilter')})
endfunction

function! s:CopilotEditHighlight(first, old, new) abort
    if empty(prop_type_get('copilot_edit_del'))
        call prop_type_add('copilot_edit_del', {'highlight': 'DiffDelete'})
    endif
    call sign_define('copilot_edit_add', {'text': '+', 'linehl': 'DiffAdd', 'texthl': 'DiffAdd'})
    let l:last_line = a:first + max([len(a:new), 1]) - 1
    for l:hunk in diff(a:old, a:new, {'output': 'indices'})
        for l:i in range(l:hunk.to_count)
            call sign_place(0, 'copilot_edit', 'copilot_edit_add', '%',
                        \ {'lnum': a:first + l:hunk.to_idx + l:i})
        endfor
        " Removed lines go above the hunk, or below the last line at the end
        let l:anchor = a:first + l:hunk.to_idx
        let l:align = l:anchor > l:last_line ? 'below' : 'above'
        let l:anchor = min([l:anchor, l:last_line])
        for l:line in a:old[l:hunk.from_idx : l:hunk.from_idx + l:hunk.from_count - 1]
            call prop_add(l:anchor, 0, {'type': 'copilot_edit_del', 'text': '- ' . l:line,
                        \ 'text_align': l:align})
        endfor
    endfor
endfunction

function! s:CopilotEditFilter(winid, key) abort
    if a:key ==# 'y'
        call s:CopilotEditFinish(0)
    elseif a:key ==# 'n'
        call s:CopilotEditFinish(1)
    else
        return 0
    endif
    return 1
endfunction

function! s:CopilotEditFinish(reject) abort
    let l:edit = s:copilot_edit
    unlet s:copilot_edit
    call popup_close(l:edit.popup)
    call sign_unplace('copilot_edit')
    call prop_remove({'type': 'copilot_edit_del', 'bufnr': l:edit.buf, 'all': 1})
    if !a:reject
        echo 'Copilot edit accepted'
    elseif getbufvar(l:edit.buf, 'changedtick') != l:edit.tick
        echohl WarningMsg | echomsg 'Buffer was edited during review; undo the Copilot edit manually' | echohl None
    else
        call win_execute(bufwinid(l:edit.buf), 'undo')
        echo 'Copilot edit rejected'
    endif
endfunction

" ,ca toggles Copilot inline completion (copilot.vim). It is off until the
" first ,ca because it sends the whole buffer to GitHub while typing.
" Tab accepts a suggestion, Alt-] / Alt-[ cycles, Ctrl-] dismisses.
function! s:CopilotCompletionToggle() abort
    if v:version < 900
        echohl WarningMsg | echomsg 'Copilot completion requires Vim 9.0+' | echohl None
        return
    endif
    if !exists('g:loaded_copilot')
        let g:copilot_enabled = 0
        execute 'set runtimepath+=' . fnameescape(s:vim_runtime . '/sources_non_forked/copilot.vim')
        runtime plugin/copilot.vim
    endif
    if get(g:, 'copilot_enabled', 1)
        Copilot disable
        echo 'Copilot completion: off'
    else
        Copilot enable
        echo 'Copilot completion: on (run :Copilot setup once to sign in)'
    endif
endfunction

nnoremap <silent> <leader>ca :call <SID>CopilotCompletionToggle()<cr>
nnoremap <silent> <leader>cq :call <SID>CopilotPopupAsk(0)<cr>
xnoremap <silent> <leader>cq :<C-u>call <SID>CopilotPopupAsk(1)<cr>
nnoremap <silent> <leader>ce :call <SID>CopilotEditAsk(0)<cr>
xnoremap <silent> <leader>ce :<C-u>call <SID>CopilotEditAsk(1)<cr>
