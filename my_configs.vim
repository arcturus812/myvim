" [PHW] my common config
set smartindent
set tabstop=4
set expandtab
set shiftwidth=4

map <F1>  :vert resize 80<CR>
map <F2>  :vert resize 30<CR>
map <F10> :diffthis<CR>
map <F11> :NERDTreeToggle<CR>
if executable('ctags')
	map <F12> :Tlist<CR>
else
	map <F12> :echoerr 'taglist requires ctags (e.g. dnf install ctags)'<CR>
endif
let Tlist_Use_Right_Window = 0

set number

colorscheme peaksea
set background=dark
set t_Co=256

" [PHW] my ctags/cscope config
" On startup, look for tags/cscope.out from the current directory upward.
" If missing and the current directory is a project root, build them in the
" background. :MakeTags (re)builds them in the current directory on demand.
set tags=./tags;,tags;

let g:tags_project_markers = ['.git', 'Makefile', 'CMakeLists.txt']
let g:cscope_file_exts = ['c', 'h', 'cc', 'cpp', 'cxx', 'hh', 'hpp', 'hxx']
let s:tags_outputs = ['tags', 'cscope.files', 'cscope.out', 'cscope.in.out', 'cscope.po.out']

function! s:CscopeConnect(db) abort
	if !filereadable(a:db)
		return
	endif
	let l:db = fnamemodify(a:db, ':p')
	silent! execute 'cs kill' l:db
	silent! execute 'cs add' l:db fnamemodify(l:db, ':h')
endfunction

function! s:IsProjectRoot(dir) abort
	if a:dir ==# expand('~') || a:dir ==# '/'
		return 0
	endif
	for l:marker in g:tags_project_markers
		if !empty(glob(a:dir . '/' . l:marker, 1))
			return 1
		endif
	endfor
	return 0
endfunction

" Keep generated files out of `git status` without touching .gitignore
function! s:GitExclude(dir) abort
	let l:exclude = a:dir . '/.git/info/exclude'
	if !isdirectory(a:dir . '/.git/info')
		return
	endif
	let l:lines = filereadable(l:exclude) ? readfile(l:exclude) : []
	let l:missing = filter(map(copy(s:tags_outputs), '"/" . v:val'), 'index(l:lines, v:val) < 0')
	if !empty(l:missing)
		call writefile(l:lines + l:missing, l:exclude)
	endif
endfunction

function! s:MakeTagsDone(dir, what, verbose, job, status) abort
	if a:status != 0
		echohl WarningMsg | echomsg 'MakeTags: failed in ' . a:dir . ' (exit ' . a:status . ')' | echohl None
		return
	endif
	call s:CscopeConnect(a:dir . '/cscope.out')
	let l:built = filter(map(copy(a:what), 'v:val ==# "ctags" ? "tags" : "cscope.out"'),
				\ 'filereadable(a:dir . "/" . v:val)')
	if a:verbose || !empty(l:built)
		echomsg 'MakeTags: ' . (empty(l:built) ? 'nothing to index' : join(l:built, ', ') . ' ready') . ' in ' . a:dir
	endif
endfunction

" a:what: list of 'ctags'/'cscope'. cscope is skipped when no C/C++ sources exist.
function! s:MakeTags(dir, what, verbose) abort
	let l:cmds = []
	if index(a:what, 'ctags') >= 0 && executable('ctags')
		call add(l:cmds, 'ctags -R --exclude=.git .')
	endif
	if index(a:what, 'cscope') >= 0 && executable('cscope')
		let l:names = join(map(copy(g:cscope_file_exts), '"-name ''*." . v:val . "''"'), ' -o ')
		call add(l:cmds, 'find . -path ./.git -prune -o -type f \( ' . l:names . ' \) -print > cscope.files'
					\ . ' && if [ -s cscope.files ]; then cscope -bq -i cscope.files; else rm -f cscope.files; fi')
	endif
	if empty(l:cmds)
		if a:verbose
			echohl WarningMsg | echomsg 'MakeTags: ctags/cscope not installed (e.g. dnf install ctags cscope)' | echohl None
		endif
		return
	endif
	call s:GitExclude(a:dir)
	call job_start(['sh', '-c', join(l:cmds, ' && ')],
				\ {'cwd': a:dir, 'exit_cb': function('s:MakeTagsDone', [a:dir, a:what, a:verbose])})
endfunction

function! s:TagsOnStartup() abort
	let l:dir = getcwd()
	let l:db = findfile('cscope.out', l:dir . ';')
	call s:CscopeConnect(l:db)
	let l:missing = []
	if empty(findfile('tags', l:dir . ';'))
		call add(l:missing, 'ctags')
	endif
	if empty(l:db)
		call add(l:missing, 'cscope')
	endif
	if !empty(l:missing) && s:IsProjectRoot(l:dir)
		call s:MakeTags(l:dir, l:missing, 0)
	endif
endfunction

command! MakeTags call s:MakeTags(getcwd(), ['ctags', 'cscope'], 1)

augroup phw_tags
	autocmd!
	autocmd VimEnter * call s:TagsOnStartup()
augroup END


nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>
