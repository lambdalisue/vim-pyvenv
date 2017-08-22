function! pyvenv#config#define(prefix, default) abort
  let prefix = a:prefix =~# '^g:' ? a:prefix : 'g:' . a:prefix
  for [key, Value] in items(a:default)
    let name = prefix . '#' . key
    if !exists(name)
      execute 'let ' . name . ' = ' . string(Value)
    endif
    unlet Value
  endfor
endfunction

function! pyvenv#config#extend(a, default) abort
  return extend(a:default, get(a:a, 0, {}))
endfunction
