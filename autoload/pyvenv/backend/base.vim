let s:Path = vital#pyvenv#import('System.Filepath')
let s:is_windows = has('win32') || has('win64')
let s:path_separator = s:is_windows ? ';' : ':'


function! pyvenv#backend#base#is_valid(env) abort
  let env = s:normalize_env(a:env)
  return s:is_valid(env)
endfunction

function! pyvenv#backend#base#activate(env) abort
  let env = s:normalize_env(a:env)
  if s:is_valid(env)
    call s:activate(env)
    return env
  endif
  return ''
endfunction

function! pyvenv#backend#base#deactivate(env) abort
  let env = s:normalize_env(a:env)
  if s:is_valid(env)
    call s:deactivate(env)
    return env
  endif
  return ''
endfunction


" Private --------------------------------------------------------------------
function! s:normalize_env(env) abort
  return simplify(resolve(fnamemodify(a:env, ':p')))
endfunction

function! s:add_path(path) abort
  let pathlist = split($PATH, s:path_separator)
  if isdirectory(a:path) && index(pathlist, a:path) == -1
    call insert(pathlist, a:path, 0)
  endif
  let $PATH = join(pathlist, s:path_separator)
endfunction

function! s:remove_path(path) abort
  let pathlist = split($PATH, s:path_separator)
  let index = index(pathlist, a:path)
  if index != -1
    call remove(pathlist, index)
  endif
  let $PATH = join(pathlist, s:path_separator)
endfunction

if s:is_windows
  function! s:is_valid(env) abort
    if !executable(s:Path.join(a:env, 'python'))
      return 0
    elseif !isdirectory(s:Path.join(a:env, 'lib'))
      return 0
    endif
    return 1
  endfunction

  function! s:activate(env) abort
    call s:add_path(a:env)
    call s:add_path(s:Path.join(a:env, 'Scripts'))
  endfunction

  function! s:deactivate(env) abort
    call s:remove_path(a:env)
    call s:remove_path(s:Path.join(a:env, 'Scripts'))
  endfunction
else
  function! s:is_valid(env) abort
    if !executable(s:Path.join(a:env, 'bin', 'python'))
      return 0
    elseif !isdirectory(s:Path.join(a:env, 'lib'))
      return 0
    endif
    return 1
  endfunction

  function! s:activate(env) abort
    call s:add_path(s:Path.join(a:env, 'bin'))
  endfunction

  function! s:deactivate(env) abort
    call s:remove_path(s:Path.join(a:env, 'bin'))
  endfunction
endif
