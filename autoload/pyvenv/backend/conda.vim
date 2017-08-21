let s:PREFIX = 'conda:'


function! pyvenv#backend#conda#is_available() abort
  return executable(g:pyvenv#backend#conda#executable)
endfunction

function! pyvenv#backend#conda#is_activated() abort
  if !pyvenv#backend#conda#is_available()
    return 0
  endif
  return !empty($CONDA_DEFAULT_ENV)
endfunction

function! pyvenv#backend#conda#envs(...) abort
  let options = extend({
        \ 'cache': 1,
        \}, get(a:000, 0, {})
        \)
  if !pyvenv#backend#conda#is_available()
    return []
  elseif exists('s:envs_cache') && options.cache
    return s:envs_cache
  endif
  let output = systemlist(printf(
        \ '%s info -e',
        \ g:pyvenv#backend#conda#executable,
        \))
  let s:envs_cache = map(
        \ filter(output, '!empty(v:val) && v:val !~# ''^#'''),
        \ 's:parse_env(v:val)',
        \)
  return s:envs_cache
endfunction

function! pyvenv#backend#conda#activate(env, quiet) abort
  if !pyvenv#backend#conda#is_available()
    redraw | call pyvenv#console#warning(
          \ 'Anaconda/Conda is not available.',
          \)
    return
  endif
  let env = get(filter(pyvenv#backend#conda#envs(), 'v:val.name ==# a:env'), 0)
  if empty(env)
    call pyvenv#console#warning('No conda environment "%s" is found', a:env)
    return
  endif
  let $CONDA_DEFAULT_ENV = env.name
  call pyvenv#backend#base#activate(env.path)
  if !a:quiet
    redraw | call pyvenv#console#info(
          \ 'A conda environment "%s" has activated',
          \ matchstr(env.name, printf('^%s\zs.*', s:PREFIX))
          \)
  endif
  return 1
endfunction

function! pyvenv#backend#conda#deactivate(quiet) abort
  if !empty($CONDA_DEFAULT_ENV)
    return
  endif
  let env = pyvenv#backend#base#deactivate($CONDA_DEFAULT_ENV)
  if empty(env)
    return
  endif
  let $CONDA_DEFAULT_ENV = ''
  if !a:quiet
    call pyvenv#console#info('Conda environment has deactivated')
  endif
  return 1
endfunction

function! pyvenv#backend#conda#component() abort
  return empty($CONDA_DEFAULT_ENV) ? 'root' : $CONDA_DEFAULT_ENV
endfunction


" Private --------------------------------------------------------------------
function! s:parse_env(record) abort
  let name = matchstr(a:record, '^.\{-}\ze\s\+\%(\*\s\+\)\?.*$')
  let path = matchstr(a:record, '^.\{-}\s\+\%(\*\s\+\)\?\zs.*$')
  return {
        \ 'name': s:PREFIX . name,
        \ 'path': simplify(path),
        \ 'active': match(a:record, printf('%s\s\+\*\s\+%s$', name, path)) != -1
        \}
endfunction



" Config ---------------------------------------------------------------------
call pyvenv#config#define('g:pyvenv#backend#conda', {
      \ 'executable': 'conda',
      \})
