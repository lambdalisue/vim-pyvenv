let s:CONDA_PREFIX = 'conda:'
let s:BACKENDS = {
      \ 'conda:': 'conda',
      \ '': 'venv',
      \}


function! pyvenv#activate(env, ...) abort
  if empty(a:env)
    return
  endif
  let quiet = a:0 ? a:1 : 0
  call s:deactivate(1)
  call s:activate(a:env, quiet)
  call pyvenv#vim#activate()
  call s:doautocmd('Activated')
endfunction

function! pyvenv#deactivate(...) abort
  let quiet = a:0 ? a:1 : 0
  call s:deactivate(quiet)
  call pyvenv#vim#deactivate()
  call s:doautocmd('Deactivated')
endfunction

function! pyvenv#info() abort
  echo printf('python: %s', exepath('python'))
  echo printf('VIRTUAL_ENV: %s', $VIRTUAL_ENV)
  echo printf('CONDA_DEFAULT_ENV: %s', $CONDA_DEFAULT_ENV)
endfunction

function! pyvenv#component() abort
  for backend in values(s:BACKENDS)
    if pyvenv#backend#{backend}#is_activated()
      return pyvenv#backend#{backend}#component()
    endif
  endfor
  return 'system'
endfunction

function! pyvenv#complete(arglead, cmdline, cursorpos) abort
  let candidates = []
  for backend in values(s:BACKENDS)
    let candidates += map(
          \ copy(pyvenv#backend#{backend}#envs()),
          \ 'v:val.name',
          \)
  endfor
  return filter(
        \ candidates,
        \ 'v:val =~# ''^'' . a:arglead'
        \)
endfunction


" Private --------------------------------------------------------------------
function! s:doautocmd(name) abort
  execute printf('doautocmd <nomodeline> User Pyvenv%s', a:name)
endfunction

function! s:activate(env, quiet) abort
  for [prefix, backend] in items(s:BACKENDS)
    if !empty(prefix) && a:env =~# '^' . prefix
      return pyvenv#backend#{backend}#activate(a:env, a:quiet)
    endif
  endfor
  " Fallback to the default backend
  let backend = s:BACKENDS['']
  return pyvenv#backend#{backend}#activate(a:env, a:quiet)
endfunction

function! s:deactivate(quiet) abort
  for backend in values(s:BACKENDS)
    if pyvenv#backend#{backend}#is_activated()
      return pyvenv#backend#{backend}#deactivate(a:quiet)
    endif
  endfor
endfunction


" Config ---------------------------------------------------------------------
call pyvenv#config#define('g:pyvenv', {
      \ 'executable': 'python',
      \})

augroup pyvenv_autocmd_pseudo
  autocmd! *
  autocmd User PyvenvActivated :
  autocmd User PyvenvDeactivated :
augroup END
