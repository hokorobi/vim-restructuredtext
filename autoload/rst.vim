" Insert bullet {{{
function! s:isList(t) abort
  return a:t =~# '^\s*\%([0-9#]\.\|[*+-]\)\s'
endfunction

function! s:getListHead(t) abort
  return strpart(a:t, 0, matchend(a:t, '^\s*\%([0-9#]\.\|[*+-]\)\s'))
endfunction

function! s:hasBullet(t) abort
  return a:t =~# '^\s*[*+-]\s'
endfunction

function! s:rotateBullet(t, n) abort
  let bullets = '*+-'
  if match(a:t, '[*+-]') == -1
    return a:t
  endif

  let bullet = strpart(a:t, match(a:t, '[*+-]'), 1)
  let i = stridx(bullets, bullet)
  if i + a:n > len(bullets) - 1
    let j = (i + a:n) % len(bullets)
  elseif i + a:n < 0
    let j = (i + a:n + len(bullets) - 1)
  else
    let j = i + a:n
  endif
  let newBullet = strpart(bullets, j, 1)
  return substitute(a:t, bullet, newBullet, '')
endfunction

function! rst#insertSameBullet() abort
  "TODO: bullet がない場合は bullet * を入力
  "TODO: 行の途中なら、それ以降の文字列を次の行に移動
  let line = getline('.')
  if !s:isList(line)
    " TODO: 改行する？
    return
  endif
  call append('.', s:getListHead(line))
  call cursor(line('.') + 1, col('.') + 2)
endfunction

function! rst#insertChildBullet() abort
  "TODO: 行の途中なら、それ以降の文字列を次の行に移動
  let line = getline('.')
  if !s:isList(line)
    " TODO: 改行する？
    return
  endif
  call append('.', '  ' .. s:rotateBullet(s:getListHead(line), 1))
  call cursor(line('.') + 1, col('.') + 4)
endfunction

function! rst#insertParentBullet() abort
  "TODO: 行の途中なら、それ以降の文字列を次の行に移動
  let line = getline('.')
  if !s:isList(line)
    " TODO: 改行する？
    return
  endif
  call append('.', strpart(s:rotateBullet(s:getListHead(line), -1), 2))
  call cursor(line('.') + 1, col('.'))
endfunction
" }}}
