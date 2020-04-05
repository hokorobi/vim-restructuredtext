scriptencoding utf-8

" Insert bullet {{{
let s:bullets = '*+-'
let s:regexBullets = '[' .. s:bullets .. ']'

function! s:isList(t) abort
  return a:t =~# '^\s*\%([0-9]\+\.\|[a-zA-Z#]\.\|' .. s:regexBullets .. '\)\s'
endfunction

function! s:getListHead(t) abort
  " s:bullets, #. なら同じもの
  if s:hasBullet(a:t)
    return strpart(a:t, 0, matchend(a:t, '^\s*' .. s:regexBullets .. '\s'))
  endif
  if a:t =~# '^\s*#\.\s'
    return strpart(a:t, 0, matchend(a:t, '^\s*#\.\s'))
  endif

  "数字なら次の数
  if a:t =~# '^\s*[0-9]\+\.\s'
    let head = strpart(a:t, 0, matchend(a:t, '^\s*[0-9]\+\.\s'))
    let idxFirstNum = match(head, '[1-9]')
    let bullet = strpart(head, idxFirstNum, matchend(head, '\.\s') - idxFirstNum -2)
    let newBullet = bullet + 1
    return substitute(head, bullet, newBullet, '')
  endif

  "TODO: a-zA-Z なら次のアルファベットを使用
  return strpart(a:t, 0, matchend(a:t, '^\s*[a-zA-Z]\.\s'))
endfunction

function! s:hasBullet(t) abort
  return a:t =~# '^\s*' .. s:regexBullets .. '\s'
endfunction

function! s:hasNumericBullet(t) abort
  return a:t =~# '^\s*\%([0-9]\+\|[a-zA-Z#]\)\.\s'
endfunction

function! s:rotateBullet(t, n) abort
  if !s:hasBullet(a:t)
    return a:t
  endif

  let bullet = strpart(a:t, match(a:t, s:regexBullets), 1)
  let i = stridx(s:bullets, bullet)
  if i + a:n > len(s:bullets) - 1
    let j = (i + a:n) % len(s:bullets)
  elseif i + a:n < 0
    let j = (i + a:n + len(s:bullets) - 1)
  else
    let j = i + a:n
  endif
  let newBullet = strpart(s:bullets, j, 1)
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
