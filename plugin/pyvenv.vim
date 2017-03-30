if exists('g:pyvenv_loaded')
  finish
endif
let g:pyvenv_loaded = 1

command! -nargs=? -complete=dir PyvenvActivate call pyvenv#activate(<q-args>)
command! PyvenvDeactivate call pyvenv#deactivate()

if get(g:, 'pyvenv#enable_startup', 1)
  call pyvenv#activate()
endif
