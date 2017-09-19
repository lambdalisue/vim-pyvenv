let s:Job = vital#pyvenv#import('System.Job')
let s:envs_cache = []


function! pyvenv#backend#conda#is_available() abort
  return executable(g:pyvenv#backend#conda#executable)
endfunction

function! pyvenv#backend#conda#is_activated() abort
  if pyvenv#backend#conda#is_available()
    return !empty($CONDA_DEFAULT_ENV)
  endif
endfunction

function! pyvenv#backend#conda#get(env) abort
  let envs = pyvenv#backend#conda#envs()
  let names = map(copy(envs), 'v:val.name')
  let index = index(names, a:env)
  if index == -1
    return {}
  endif
  return envs[index]
endfunction

function! pyvenv#backend#conda#envs() abort
  if !pyvenv#backend#conda#is_available()
    return []
  elseif exists('s:envs_job') && s:envs_job.status() == 'run'
    call s:envs_job.wait()
  endif
  return s:envs_cache
endfunction

function! pyvenv#backend#conda#activate(env, options) abort
  if !pyvenv#backend#conda#is_available()
    return
  endif
  let env = pyvenv#backend#conda#get(a:env)
  if !empty(env) && pyvenv#backend#base#activate(env.path)
    let $CONDA_DEFAULT_ENV = env.name
    if get(a:options, 'verbose')
      redraw | call pyvenv#console#info(
            \ 'A conda env "%s" has activated', a:env
            \)
    endif
    return 1
  elseif get(a:options, 'verbose')
    redraw | call pyvenv#console#info(
          \ 'Failed to activate a conda env "%s"', a:env
          \)
  endif
endfunction

function! pyvenv#backend#conda#deactivate(options) abort
  if empty($CONDA_DEFAULT_ENV)
    return
  endif
  let env = pyvenv#backend#conda#get($CONDA_DEFAULT_ENV)
  if !empty(env) && pyvenv#backend#base#deactivate(env.path)
    let $CONDA_DEFAULT_ENV = ''
    if get(a:options, 'verbose')
      redraw | call pyvenv#console#info(
            \ 'A conda env "%s" has deactivated',
            \ env.name,
            \)
    endif
    return 1
  elseif get(a:options, 'verbose')
    redraw | call pyvenv#console#info(
          \ 'Failed to deactivate a conda env "%s"', $CONDA_DEFAULT_ENV
          \)
  endif
endfunction

function! pyvenv#backend#conda#component() abort
  if exists('s:envs_job') && s:envs_job.status() == 'run'
    return 'loading...'
  endif
  let name = empty($CONDA_DEFAULT_ENV) ? 'root' : $CONDA_DEFAULT_ENV
  let env = pyvenv#backend#conda#get(name)
  return empty(env) ? '' : env.name
endfunction

function! pyvenv#backend#conda#init() abort
  if exists('s:envs_job') && s:envs_job.status() == 'run'
    return
  endif
  let s:envs_job = s:Job.start(
        \ [g:pyvenv#backend#conda#executable, 'info', '-e'], {
        \   'stdout': [],
        \   'on_stdout': function('s:on_stdout'),
        \   'on_exit': function('s:on_exit'),
        \ })
endfunction


" Private --------------------------------------------------------------------
function! s:systemlist(...) abort
  " NOTE: 'systemlist' does not remove trailing '\r' so use 'system' instead
  let output = call('system', a:000)
  return split(output, '\r\?\n')
endfunction

function! s:parse_record(record) abort
  if empty(a:record) || a:record =~# '^#'
    return {}
  endif
  let name = matchstr(a:record, '^.\{-}\ze\s\+\%(\*\s\+\)\?.*$')
  let path = matchstr(a:record, '^.\{-}\s\+\%(\*\s\+\)\?\zs.*$')
  let active = match(a:record, '^.\{-}\s\+\*\s\+\zs.*$') != -1
  return {
        \ 'name': name,
        \ 'path': path,
        \ 'active': active,
        \}
endfunction

function! s:on_stdout(job, msg, event) abort dict
  let leading = get(self.stdout, -1, '')
  silent! call remove(self.stdout, -1)
  call extend(self.stdout, [leading . get(a:msg, 0, '')] + a:msg[1:])
endfunction

function! s:on_exit(job, msg, event) abort dict
  let s:envs_cache = filter(
        \ map(self.stdout, 's:parse_record(v:val)'),
        \ '!empty(v:val)'
        \)
  unlet s:envs_job
  redraw!
endfunction


" Config ---------------------------------------------------------------------
call pyvenv#config#define('g:pyvenv#backend#conda', {
      \ 'executable': 'conda',
      \})

" Init
call pyvenv#backend#conda#init()
