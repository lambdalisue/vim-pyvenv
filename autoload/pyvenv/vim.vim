function! pyvenv#vim#activate() abort
  call pyvenv#vim#deactivate()

  let executable_py2 = executable('python2')
  let executable_py3 = executable('python3')

  if !executable_py2 && !executable_py3
    let major_version = matchstr(
          \ system('python --version 2>/dev/null'),
          \ 'Python \zs\d',
          \)
    if !empty(major_version) && s:is_enabled_py{major_version}
      call s:activate_py{major_version}('python')
    endif
  else
    if executable_py2
      call s:activate_py2()
    endif
    if executable_py3
      call s:activate_py3()
    endif
  endif
endfunction

function! pyvenv#vim#deactivate() abort
  call s:deactivate_py2()
  call s:deactivate_py3()
endfunction


function! s:is_enabled_py2() abort
  if exists('s:_is_enabled_py2')
    return s:_is_enabled_py2
  endif
  if !has('python')
    let s:_is_enabled_py2 = 0
    return 0
  endif
  try
    python 1
    let s:_is_enabled_py2 = 1
    return 1
  catch
    let s:_is_enabled_py2 = 0
  endtry
  return 0
endfunction

function! s:is_enabled_py3() abort
  if exists('s:_is_enabled_py3')
    return s:_is_enabled_py3
  endif
  if !has('python3')
    let s:_is_enabled_py3 = 0
    return 0
  endif
  try
    python3 1
    let s:_is_enabled_py3 = 1
    return 1
  catch
    let s:_is_enabled_py3 = 0
  endtry
  return 0
endfunction

function! s:activate_py2(...) abort
  if !s:is_enabled_py2()
    return
  endif
  if exists('s:_sys_path_py2')
    call s:deactivate_py2()
  endif
  let expr = a:0 ? a:1 : 'python2'
  let output = system(expr . ' -c "import sys; print(\"\n\".join(sys.path))"')
  if v:shell_error
    return
  endif
  let outer_path = filter(split(output, '\r\?\n'), '!empty(v:val)')
  let saved_path = pyeval('sys.path')
  python <<EOC
def _pyvenv_temporary_scope():
  import vim, sys
  sys.path[:] = vim.eval('outer_path')
  sys.path.append('_vim_path_')
_pyvenv_temporary_scope()
EOC
  let s:_sys_path_py2 = saved_path
endfunction

function! s:deactivate_py2() abort
  if !exists('s:_sys_path_py2') || !s:is_enabled_py2()
    return
  endif
  let saved_path = s:_sys_path_py2
  python <<EOC
def _pyvenv_temporary_scope():
  import vim, sys
  sys.path[:] = vim.eval('saved_path')
_pyvenv_temporary_scope()
EOC
  unlet s:_sys_path_py2
endfunction

function! s:activate_py3(...) abort
  if !s:is_enabled_py3()
    return
  endif
  if exists('s:_sys_path_py3')
    call s:deactivate_py3()
  endif
  let expr = a:0 ? a:1 : 'python3'
  let output = system(expr . ' -c "import sys; print(\"\n\".join(sys.path))"')
  if v:shell_error
    return
  endif
  let outer_path = filter(split(output, '\r\?\n'), '!empty(v:val)')
  let saved_path = py3eval('sys.path')
  python3 <<EOC
def _pyvenv_temporary_scope():
  import vim, sys
  sys.path[:] = vim.eval('outer_path')
  sys.path.append('_vim_path_')
_pyvenv_temporary_scope()
EOC
  let s:_sys_path_py3 = saved_path
endfunction

function! s:deactivate_py3() abort
  if !exists('s:_sys_path_py3') || !s:is_enabled_py3()
    return
  endif
  let saved_path = s:_sys_path_py3
  python3 <<EOC
def _pyvenv_temporary_scope():
  import vim, sys
  sys.path[:] = vim.eval('saved_path')
_pyvenv_temporary_scope()
EOC
  unlet s:_sys_path_py3
endfunction
