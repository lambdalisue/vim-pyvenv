let s:Path = vital#pyvenv#import('System.Filepath')
let s:is_windows = has('win32') || has('win64')
let s:path_separator = s:is_windows ? ';' : ':'


function! pyvenv#venv#activate(venv) abort
  let venv = simplify(resolve(fnamemodify(a:venv, ':p')))
  call pyvenv#venv#deactivate()
  call s:add_path(s:Path.join(venv, 'bin'))
  call s:set_virtualenv(venv)
endfunction

function! pyvenv#venv#deactivate() abort
  if empty($VIRTUAL_ENV)
    return
  endif
  call s:remove_path(s:Path.join($VIRTUAL_ENV, 'bin'))
  call s:set_virtualenv('')
endfunction


" Private --------------------------------------------------------------------
function! s:set_virtualenv(venv) abort
  let $VIRTUAL_ENV = simplify(a:venv)
endfunction

function! s:add_path(path) abort
  let pathlist = split($PATH, s:path_separator)
  if isdirectory(a:path) && index(pathlist, a:path) == -1
    call insert(pathlist, a:path, 0)
  endif
  execute printf('let $PATH = join(pathlist, ''%s'')', s:path_separator)
endfunction

function! s:remove_path(path) abort
  let pathlist = split($PATH, s:path_separator)
  let index = index(pathlist, a:path)
  if index != -1
    call remove(pathlist, index)
  endif
  execute printf('let $PATH = join(pathlist, ''%s'')', s:path_separator)
endfunction
