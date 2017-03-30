function! pyvenv#activate(...) abort
  let path = a:0 ? a:1 : $VIRTUAL_ENV
  if empty(path)
    return
  endif
  call pyvenv#venv#activate(path)
  if !has('nvim')
    call pyvenv#vim#activate()
  endif
endfunction

function! pyvenv#deactivate() abort
  if empty($VIRTUAL_ENV)
    return
  endif
  call pyvenv#venv#deactivate()
  if !has('nvim')
    call pyvenv#vim#deactivate()
  endif
endfunction

function! pyvenv#component() abort
  let venv = $VIRTUAL_ENV
  if empty(venv)
    return 'system'
  else
    return fnamemodify(venv, ':~:.')
  endif
endfunction
