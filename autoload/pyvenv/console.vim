let s:PREFIX = 'pyvenv: '


function! pyvenv#console#debug(...) abort
  if !&verbose
    return
  endif
  echohl Comment
  call call(function('s:echo'), a:000)
  echohl None
endfunction

function! pyvenv#console#info(...) abort
  call call(function('s:echo'), a:000)
endfunction

function! pyvenv#console#warning(...) abort
  echohl WarningMsg
  call call(function('s:echo'), a:000)
  echohl None
endfunction

function! pyvenv#console#error(...) abort
  echohl ErrorMsg
  call call(function('s:echo'), a:000)
  echohl None
endfunction

function! s:echo(...) abort
  echo s:PREFIX . (a:0 == 1 ? a:1 : call('printf', a:000))
endfunction
