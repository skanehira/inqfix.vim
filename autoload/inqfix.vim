" inqfix
" Author: skanehira
" License: MIT

function! inqfix#enable() abort
  augroup inqfix
    au!
    au CmdlineChanged [/?] call <SID>on_change()
    au CmdlineLeave [/?] call <SID>on_leave()
  augroup END
endfunction

function! inqfix#disable() abort
  augroup inqfix
    au!
  augroup END
  augroup! inqfix
endfunction

function! s:search(word) abort
  let oldpos = getpos(".")
  call cursor(1, 1)
  let poslist = []
  while 1
    let pos = searchpos(a:word, "W")
    if pos ==# [0, 0]
      break
    endif
    call add(poslist, pos)
  endwhile
  call setpos(".", oldpos)
  return poslist
endfunction

function! s:is_quickfix(winid) abort
  let info = getwininfo(a:winid)
  if empty(info)
    return 0
  endif
  return info[0].quickfix ==# 1
endfunction

function! s:setqflist(fname, poslist) abort
  let qflist = []
  call setqflist(qflist, 'r')
  for pos in a:poslist
    let [lnum, col] = pos
    let text = getline(lnum)
    call add(qflist, {
          \ 'filename': a:fname,
          \ 'lnum': lnum,
          \ 'col': col,
          \ 'text': text,
          \ })
  endfor
  call setqflist(qflist, 'r')
endfunction

function! s:on_change() abort
  if s:is_quickfix(win_getid())
    return
  endif
  let input = getcmdline()
  if input is# ''
    return
  endif
  let s:old_winid = win_getid()
  let poslist = s:search(input)
  let fname = expand("%")
  call s:setqflist(fname, poslist)
endfunction

function! s:on_leave() abort
  if s:is_quickfix(win_getid())
    return
  endif
  copen
  call win_gotoid(s:old_winid)
endfunction

"call s:setqflist(expand("%"), s:search("on_c"))
