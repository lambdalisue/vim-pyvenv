let s:Path = vital#pyvenv#import('System.Filepath')


function! pyvenv#backend#base#is_invalid(env) abort
  let path = pyvenv#util#normalize(a:env)
  return s:is_invalid(path)
endfunction

function! pyvenv#backend#base#activate(env) abort
  let path = pyvenv#util#normalize(a:env)
  if !s:is_invalid(path)
    call s:activate(path)
    return 1
  endif
endfunction

function! pyvenv#backend#base#deactivate(env) abort
  let path = pyvenv#util#normalize(a:env)
  if !s:is_invalid(path)
    call s:deactivate(path)
    return 1
  endif
endfunction


" Private --------------------------------------------------------------------
if has('win32') || has('win64')
  function! s:is_invalid(path) abort
    if !executable(s:Path.join(a:path, 'python'))
      return 1
    elseif !isdirectory(s:Path.join(a:path, 'lib'))
      return 1
    endif
  endfunction

  function! s:activate(path) abort
    call pyvenv#util#add_path(s:Path.join(a:path, 'Library', 'bin'))
    call pyvenv#util#add_path(s:Path.join(a:path, 'Scripts'))
    call pyvenv#util#add_path(a:path)
  endfunction

  function! s:deactivate(path) abort
    call pyvenv#util#remove_path(s:Path.join(a:path, 'Library', 'bin'))
    call pyvenv#util#remove_path(s:Path.join(a:path, 'Scripts'))
    call pyvenv#util#remove_path(a:path)
  endfunction
else
  function! s:is_invalid(path) abort
    if !executable(s:Path.join(a:path, 'bin', 'python'))
      return 1
    elseif !isdirectory(s:Path.join(a:path, 'lib'))
      return 1
    endif
  endfunction

  function! s:activate(path) abort
    call pyvenv#util#add_path(s:Path.join(a:path, 'bin'))
  endfunction

  function! s:deactivate(path) abort
    call pyvenv#util#remove_path(s:Path.join(a:path, 'bin'))
  endfunction
endif
