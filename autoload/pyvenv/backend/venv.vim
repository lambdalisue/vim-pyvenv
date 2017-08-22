function! pyvenv#backend#venv#is_available() abort
  return 1
endfunction

function! pyvenv#backend#venv#is_activated() abort
  return !empty($VIRTUAL_ENV)
endfunction

function! pyvenv#backend#venv#get(env) abort
  let path = pyvenv#util#normalize(a:env)
  if pyvenv#backend#base#is_invalid(path)
    return {}
  endif
  return {
        \ 'name': fnamemodify(path, ':~:.'),
        \ 'path': path,
        \ 'active': pyvenv#util#normalize($VIRTUAL_ENV) ==# path,
        \}
endfunction

function! pyvenv#backend#venv#envs() abort
  let root = expand('%:p:h')
  let envs = []
  for name in g:pyvenv#backend#venv#search_names
    let path = finddir(name, fnameescape(root) . ';')
    if empty(path)
      continue
    endif
    call add(envs, pyvenv#backend#venv#get(path))
  endfor
  return filter(envs, '!empty(v:val)')
endfunction

function! pyvenv#backend#venv#activate(env, options) abort
  let env = pyvenv#backend#venv#get(a:env)
  if !empty(env) && pyvenv#backend#base#activate(env.path)
    let $VIRTUAL_ENV = env.path
    if get(a:options, 'verbose')
      redraw | call pyvenv#console#info(
            \ 'A venv "%s" has activated', a:env
            \)
    endif
    return 1
  elseif get(a:options, 'verbose')
    redraw | call pyvenv#console#info(
          \ 'Failed to activate a venv "%s"', a:env
          \)
  endif
endfunction

function! pyvenv#backend#venv#deactivate(options) abort
  if empty($VIRTUAL_ENV)
    return
  endif
  let env = pyvenv#backend#venv#get($VIRTUAL_ENV)
  if !empty(env) && pyvenv#backend#base#deactivate(env.path)
    let $VIRTUAL_ENV = ''
    if get(a:options, 'verbose')
      redraw | call pyvenv#console#info(
            \ 'A venv "%s" has deactivated',
            \ env.name,
            \)
    endif
    return 1
  elseif get(a:options, 'verbose')
    redraw | call pyvenv#console#info(
          \ 'Failed to deactivate a venv "%s"', $VIRTUAL_ENV
          \)
  endif
endfunction

function! pyvenv#backend#venv#component() abort
  let env = pyvenv#backend#venv#get($VIRTUAL_ENV)
  return empty(env) ? '' : env.name
endfunction


" Config ---------------------------------------------------------------------
call pyvenv#config#define('g:pyvenv#backend#venv', {
      \ 'search_names': [
      \   '.venv', '.venv2', '.venv3',
      \ ],
      \})

