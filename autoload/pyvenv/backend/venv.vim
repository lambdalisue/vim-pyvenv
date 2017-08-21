let s:PREFIX = ''


function! pyvenv#backend#venv#is_available() abort
  return 1
endfunction

function! pyvenv#backend#venv#is_activated() abort
  return !empty($VIRTUAL_ENV)
endfunction

function! pyvenv#backend#venv#envs(...) abort
  let options = extend({
        \ 'root': expand('%:p:h'),
        \}, get(a:000, 0, {})
        \)
  let envs = []
  for name in g:pyvenv#backend#venv#search_names
    let path = finddir(name, fnameescape(options.root) . ';')
    let env = s:normalize(path)
    if empty(path) || index(envs, env) != -1 || !pyvenv#backend#base#is_valid(env)
      continue
    endif
    call add(envs, {
          \ 'name': s:PREFIX . fnamemodify(env, ':~:.'),
          \ 'path': env,
          \ 'active': $VIRTUAL_ENV ==# env,
          \})
  endfor
  return envs
endfunction

function! pyvenv#backend#venv#activate(env, quiet) abort
  let env = matchstr(a:env, printf('^%s\zs.*', s:PREFIX))
  let env = pyvenv#backend#base#activate(s:normalize(env))
  if empty(env)
    return
  endif
  let $VIRTUAL_ENV = env
  if !a:queit
    redraw | call pyvenv#console#info(
          \ 'A venv "%s" has activated',
          \ env.name,
          \)
  endif
  return 1
endfunction

function! pyvenv#backend#venv#deactivate(quiet) abort
  if empty($VIRTUAL_ENV)
    return
  endif
  let env = pyvenv#backend#base#deactivate($VIRTUAL_ENV)
  if empty(env)
    return
  endif
  let $VIRTUAL_ENV = ''
  if !a:queit
    redraw | call pyvenv#console#info('A venv has deactivated')
  endif
  return 1
endfunction

function! pyvenv#backend#venv#component() abort
  return empty($VIRTUAL_ENV) ? '' : fnamemodify($VIRTUAL_ENV, ':~:.')
endfunction


" Private --------------------------------------------------------------------
function! s:normalize(env) abort
  return simplify(resolve(fnamemodify(a:env, ':p')))
endfunction


" Config ---------------------------------------------------------------------
call pyvenv#config#define('g:pyvenv#backend#venv', {
      \ 'search_names': [
      \   '.venv', '.venv2', '.venv3',
      \ ],
      \})

