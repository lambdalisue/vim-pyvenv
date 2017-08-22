let s:Path = vital#pyvenv#import('System.Filepath')
let s:is_windows = has('win32') || has('win64')
let s:path_separator = s:is_windows ? ';' : ':'


function! pyvenv#util#normalize(env) abort
  return fnamemodify(simplify(a:env), ':p')
endfunction

function! pyvenv#util#add_path(path) abort
  let pathlist = split($PATH, s:path_separator)
  if isdirectory(a:path) && index(pathlist, a:path) == -1
    call insert(pathlist, a:path, 0)
  endif
  let $PATH = join(pathlist, s:path_separator)
endfunction

function! pyvenv#util#remove_path(path) abort
  let pathlist = split($PATH, s:path_separator)
  let index = index(pathlist, a:path)
  if index != -1
    call remove(pathlist, index)
  endif
  let $PATH = join(pathlist, s:path_separator)
endfunction

function! pyvenv#util#doautocmd(name) abort
  execute printf('doautocmd <nomodeline> User %s', a:name)
endfunction

function! pyvenv#util#escape_patterns(str) abort
  " escape characters for no-magic (Ref: Vital.Data.String)
  return escape(a:str, '^$~.*[]\')
endfunction
