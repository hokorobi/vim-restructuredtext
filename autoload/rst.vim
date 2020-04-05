scriptencoding utf-8

" Insert bullet {{{
"TODO: 行の途中なら、それ以降の文字列を次の行に移動

let s:bullets = '*+-'
let s:regexBullets = '[' .. s:bullets .. ']'

function! s:isList(t) abort
  return a:t =~# '^\s*\%([0-9]\+\.\|[a-zA-Z#]\.\|' .. s:regexBullets .. '\)\s'
endfunction

function! s:getNumberedBullet(t) abort
  let idxFirstNum = match(a:t, '[1-9]')
  let listpostfixlen = 2
  return strpart(a:t, idxFirstNum, matchend(a:t, '\.\s') - idxFirstNum - listpostfixlen)
endfunction

function! s:getListHead(t) abort
  " s:bullets, #. なら同じもの
  if s:hasBullet(a:t)
    return strpart(a:t, 0, matchend(a:t, '^\s*' .. s:regexBullets .. '\s'))
  endif
  if a:t =~# '^\s*#\.\s'
    return strpart(a:t, 0, matchend(a:t, '^\s*#\.\s'))
  endif

  " 数字なら次の数
  if a:t =~# '^\s*[0-9]\+\.\s'
    let head = strpart(a:t, 0, matchend(a:t, '^\s*[0-9]\+\.\s'))
    let bullet = s:getNumberedBullet(a:t)
    let newBullet = bullet + 1
    return substitute(head, bullet, newBullet, '')
  endif

  " a-zA-Z なら次のアルファベットを使用
  let head = strpart(a:t, 0, matchend(a:t, '^\s*[a-zA-Z]\.\s'))
  let bullet = strpart(head, match(head, '[a-zA-Z]'), 1)
  let newBullet = nr2char(char2nr(bullet) + 1)
  return substitute(head, bullet, newBullet, '')
endfunction

function! s:hasBullet(t) abort
  return a:t =~# '^\s*' .. s:regexBullets .. '\s'
endfunction

function! s:hasNumberedBullet(t) abort
  return a:t =~# '^\s*\%([0-9]\+\|[a-zA-Z#]\)\.\s'
endfunction

function! s:getRotateNewBullet(t, n, bullet, bullets) abort
  let i = stridx(a:bullets, a:bullet)
  if i + a:n > len(a:bullets) - 1
    let j = (i + a:n) % len(a:bullets)
  elseif i + a:n < 0
    let j = (i + a:n + len(a:bullets))
  else
    let j = i + a:n
  endif
  return strpart(a:bullets, j, 1)
endfunction

function! s:rotateBullet(t, n) abort
  if a:t =~# '^\s*[0-9]\+\.\s'
    let newBullet = s:getRotateNewBullet(a:t, a:n, '#', '#aA')
    return substitute(a:t, s:getNumberedBullet(a:t), newBullet, '')
  endif

  if s:hasBullet(a:t)
    let bullet = strpart(a:t, match(a:t, s:regexBullets), 1)
    let newBullet = s:getRotateNewBullet(a:t, a:n, bullet, s:bullets)
    return substitute(a:t, bullet, newBullet, '')
  endif

  let bullet = strpart(a:t, match(a:t, '[#a-zA-Z]'), 1)
  if bullet =~# '[a-z]'
    let baseBullet = 'a'
  elseif bullet =~# '[A-Z]'
    let baseBullet = 'A'
  else
    let baseBullet = bullet
  endif
  let newBullet = s:getRotateNewBullet(a:t, a:n, baseBullet, '#aA')
  return substitute(a:t, bullet, newBullet, '')
endfunction

function! rst#insertSameBullet() abort
  "TODO: bullet がない場合は bullet * を入力
  let line = getline('.')
  if !s:isList(line)
    return
  endif

  call append('.', s:getListHead(line))
  call cursor(line('.') + 1, col('.') + 2)
endfunction

function! rst#insertRotateBullet(n) abort
  let line = getline('.')
  if !s:isList(line)
    return
  endif
  if a:n > 0
    let newLine = '  ' .. s:rotateBullet(s:getListHead(line), 1)
    let newCol = col('.') + 4
  else
    let newLine = strpart(s:rotateBullet(s:getListHead(line), -1), 2)
    let newCol = col('.')
  endif

  call append('.', ['', newLine])
  call cursor(line('.') + 2, newCol)
endfunction
" }}}
