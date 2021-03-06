scriptencoding utf-8

let s:power = 0
let s:prev = ''

function! s:sb()
  if !has_key(s:, 'bar')
    let s:bar = vim#widgets#progressbar#NewSimpleProgressBar("死", 100, winnr())
    call s:bar.incr(100)
  endif
  return s:bar
endfunction

function! s:shi()
  if s:sb().cur_value == 0
    if len(split(execute(":buffers"),"\n")) == 1
      qall!
    endif
    bw!
    call s:bar.incr(100)
  endif
endfunction

function! s:power_down(...)
  call s:sb().incr(-1)
  call s:shi()
endfunction

function! s:power_up(key)
  if s:prev != a:key | call s:sb().incr(1) | let s:prev = a:key | endif
  return a:key
endfunction

function! s:init()
  call timer_start(100, function('s:power_down'), {'repeat': -1})
  nnoremap <expr> j <SID>power_up('j')
  nnoremap <expr> k <SID>power_up('k')
endfunction

au! VimEnter * call s:init()
