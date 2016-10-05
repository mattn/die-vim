"Progressbar in the statusline
"Author      : politza@fh-trier.de
"Last change : 2007-09-01
"Version     : 1.0

let s:progressbar = {}
let s:cpo=&cpo
set cpo-=C
"Function: NewSimpleProgressBar {{{1
"Create a new progressbar 
"Args: title   : string
"      max_value : int
"      winnr   : int ( optional , default=current_win )
"Returns: new progressbar , if vim version supports it
"         {}              , if not
func! vim#widgets#progressbar#NewSimpleProgressBar(title, max_value, ...)
  if !has("statusline")
    return {}
  endif
  "Optional arg : winnr 
  let winnr = a:0 ? a:1 : winnr()
  let b = copy(s:progressbar)
  let b.title = a:title
  let b.max_value = a:max_value
  let b.cur_value = 0
  let b.winnr = winnr
  let b.items = { 'title' : { 'color' : 'Statusline' }, 'bar' : { 'fillchar' : ' ', 'color' : 'Statusline' , 'fillcolor' : 'DiffDelete' , 'bg' : 'Statusline' } , 'counter' : { 'color' : 'Statusline' } }
  let b.stl_save = getwinvar(winnr,"&statusline")
  let b.lst_save = &laststatus"
  return b
endfun

"Function: progressbar.setStyle {{{1
"Alter colors and the fillchar
"Args: item    : string ( title,bar or counter )
"      style   : hash , e.g. { 'color' : 'Comment' }
"
"valid style values :
"title   => color      : Highlight group
"counter => color      : Highlight group
"bar     => color      : Highlight group for the empty part of the bar,
"                        since it is empty only the bgcolor will be used.
"bar     => fillcolor  : Highlight group for the filled part of the bar.
"bar     => fillchar   : Char to use for the progressing bar, default is <space>.
func! s:progressbar.setStyle( item, style)
  if a:item !~? '^\(title\|bar\|counter\)$'
    throw "progressbar.setStyle : Unknown item -> ".a:item."!"
  elseif type(a:style) != type({})
    throw "progressbar.setStyle : arg#2 must be a hash !"
  endif
  for k in keys(a:style)
    let self.items[a:item][k] = a:style[k]
  endfor
endfun


"Function: progressbar.paint() {{{1
"(Re)paint the statusbar in the coressponding window.
"Note: Will automatically be called after a valid increment.
func! s:progressbar.paint()
  let max_len = winwidth(self.winnr)-1
  let t_len = strlen(self.title)+1+1
  let c_len  = 2*strlen(self.max_value)+1+1+1
  let pb_len = max_len - t_len - c_len - 2
  let cur_pb_len = (pb_len*self.cur_value)/self.max_value

  let t_color = self.items.title.color
  let b_fcolor = self.items.bar.fillcolor
  let b_color = self.items.bar.color
  let c_color = self.items.counter.color
  let fc= strpart(self.items.bar.fillchar." ",0,1)

  let stl =  "%#".t_color."#%-( ".self.title." %)".
            \"%#".b_color."#|".
            \"%#".b_fcolor."#%-(".repeat(fc,cur_pb_len)."%)".
            \"%#".b_color."#".repeat(" ",pb_len-cur_pb_len)."|".
            \"%=%#".c_color."#%( ".repeat(" ",(strlen(self.max_value) - strlen(self.cur_value))).self.cur_value."/".self.max_value."  %)"
  set laststatus=2
  call setwinvar(self.winnr,"&stl",stl)
  redraw
endfun

"Function: progressbar.restore() {{{1
"Restore the statusline to its former value
"Note: Always put this in a finally block,
"      that way the statusline will always
"      be restored.
func! s:progressbar.restore()
  call setwinvar(self.winnr,"&stl",self.stl_save)
  let &laststatus=self.lst_save
  redraw
endfun

"Function: progressbar.incr() {{{1
"Increment the statusbar.
"checks if newvalue > 0 && newvalue < max_value
"and repaints.
"Args: incr    : int ( positive or negative , default = +1 )

func! s:progressbar.incr( ... )
  let i = a:0 ? a:1 : 1
  let i+=self.cur_value
  let i = i < 0 ? 0 : i > self.max_value ?  self.max_value : i
  let self.cur_value = i
  call self.paint()
  return self.cur_value
endfun
" }}}

let &cpo=s:cpo
unlet s:cpo
" vim:sw=2:et:fdm=marker:fdl=0
