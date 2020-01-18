" Insert bullet {{{
function! rst#insertSameBullet() abort
  "TODO: bullet がない場合は bullet * を入力
  "TODO: 行の途中なら、それ以降の文字列を次の行に移動
  let line = getline('.')
  if line !~# '^\s*\S\s'
    " TODO: 改行する？
    return
  endif
  let head = strpart(line, 0, matchend(line, '^\s*\S\s'))
  call append('.', head)
  call cursor(line('.') + 1, col('.') + 2)
endfunction

function! rst#insertChildBullet() abort
  "TODO: 行の途中なら、それ以降の文字列を次の行に移動
  let line = getline('.')
  if line !~# '^\s*\S\s'
    " TODO: 改行する？
    return
  endif
  let head = strpart(line, 0, matchend(line, '^\s*\S\s'))
  if stridx(head, '*') > -1
    let bullet = '+'
  else
    let bullet = '-'
  endif
  call append('.', '  ' .. substitute(head, '\S', bullet, ''))
  call cursor(line('.') + 1, col('.') + 4)
endfunction

function! rst#insertParentBullet() abort
  "TODO: 行の途中なら、それ以降の文字列を次の行に移動
  let line = getline('.')
  if line !~# '^\s\+\S\s'
    " TODO: 改行する？
    return
  endif
  let head = strpart(line, 0, matchend(line, '^\s\+\S\s'))
  if stridx(head, '+') > -1
    let bullet = '*'
  else
    let bullet = '-'
  endif
  call append('.', strpart(substitute(head, '\S', bullet, ''), 2))
  call cursor(line('.') + 1, col('.'))
endfunction
" }}}
