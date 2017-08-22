if exists('g:pyvenv_loaded')
  finish
endif
let g:pyvenv_loaded = 1

function! s:activate(env) abort
  return pyvenv#activate(a:env, {
        \ 'verbose': v:cmdbang,
        \})
endfunction

function! s:deactivate() abort
  return pyvenv#deactivate({
        \ 'verbose': v:cmdbang,
        \})
endfunction


command!
      \ -nargs=?
      \ -bang
      \ -complete=customlist,pyvenv#complete
      \ PyvenvActivate
      \ call s:activate(<q-args>)
command!
      \ -bang
      \ PyvenvDeactivate
      \ call s:deactivate()
