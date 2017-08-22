function! pyvenv#activate(env, ...) abort
  let options = pyvenv#config#extend(a:000, {
        \ 'verbose': 1,
        \})
  if empty(a:env)
    return
  endif
  call pyvenv#deactivate(options)
  if s:activate(a:env, options)
    if !has('nvim')
      call pyvenv#vim#activate()
    endif
    call pyvenv#util#doautocmd('PyvenvActivated')
  endif
endfunction

function! pyvenv#deactivate(...) abort
  let options = pyvenv#config#extend(a:000, {
        \ 'verbose': 1,
        \})
  if s:deactivate(options)
    if !has('nvim')
      call pyvenv#vim#deativate()
    endif
    call pyvenv#util#doautocmd('PyvenvDeactivated')
  endif
endfunction

function! pyvenv#component() abort
  for backend in g:pyvenv#backends
    if pyvenv#backend#{backend.name}#is_activated()
      return pyvenv#backend#{backend.name}#component()
    endif
  endfor
  return 'system'
endfunction

function! pyvenv#complete(arglead, cmdline, cursorpos) abort
  let candidates = []
  let escaped_arglead = pyvenv#util#escape_patterns(a:arglead)
  for backend in g:pyvenv#backends
    call extend(candidates, map(
          \ copy(pyvenv#backend#{backend.name}#envs()),
          \ 'backend.prefix . v:val.name',
          \))
  endfor
  return filter(candidates, 'v:val =~# ''^'' . escaped_arglead')
endfunction


" Private --------------------------------------------------------------------
function! s:activate(env, options) abort
  for backend in g:pyvenv#backends
    let escaped_prefix = pyvenv#util#escape_patterns(backend.prefix)
    if a:env =~# '^' . escaped_prefix
      let env = matchstr(a:env, printf('^%s\zs.*', escaped_prefix))
      if pyvenv#backend#{backend.name}#activate(env, a:options)
        return 1
      endif
    endif
  endfor
endfunction

function! s:deactivate(options) abort
  for backend in g:pyvenv#backends
    if pyvenv#backend#{backend.name}#is_activated()
          \ && pyvenv#backend#{backend.name}#activate(a:options)
      return 1
    endif
  endfor
endfunction


" Config ---------------------------------------------------------------------
call pyvenv#config#define('g:pyvenv', {
      \ 'executable': 'python',
      \ 'backends': [
      \   {'name': 'conda', 'prefix': 'conda:'},
      \   {'name': 'venv', 'prefix': ''},
      \ ]
      \})

augroup pyvenv_autocmd_pseudo
  autocmd! *
  autocmd User PyvenvActivated :
  autocmd User PyvenvDeactivated :
augroup END
