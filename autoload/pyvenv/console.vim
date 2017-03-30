let s:Console = vital#pyvenv#import('Vim.Console')
call s:Console.prefix = 'pyvenv'


function! pyvenv#console#error(...) abort
  call call(s:Console.error, a:000, s:Console)
endfunction
