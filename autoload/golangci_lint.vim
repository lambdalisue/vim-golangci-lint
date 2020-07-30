let s:Lambda = vital#golangci_lint#import('Lambda')
let s:Process = vital#golangci_lint#import('Async.Promise.Process')
let s:CancellationTokenSource = vital#golangci_lint#import('Async.CancellationTokenSource')
let s:errorformat = '%W%f:%l:%c: %m,%W%f:%l: %m,%-G%.%#'
let s:source = v:null

function! golangci_lint#call(bang, args) abort
  if s:source isnot# v:null
    if a:bang ==# '!'
      call s:source.cancel()
    else
      echohl WarningMsg
      echo "[golangci_lint] Already golangci-lint has running. Wait or call GolangciLint! instead"
      echohl None
    endif
  endif
  let s:source = s:CancellationTokenSource.new()
  let args = [
        \ g:golangci_lint#prog,
        \ '--color', 'never',
        \ 'run',
        \ '--out-format', 'line-number',
        \]
  let args = args + a:args
  let what = {
        \ 'title': join(args),
        \ 'efm': g:golangci_lint#errorformat,
        \}
  call s:Process.start(args, { 'token': s:source.token })
        \.then({ v -> v.stdout })
        \.then({ v -> filter(v, { -> v:val[:0] =~# '\S' }) })
        \.then({ v -> setqflist([], ' ', extend({'lines': v}, what)) })
        \.catch({ v -> s:echoerr(v) })
        \.finally({ -> s:Lambda.let(s:, 'source', v:null) })
endfunction

function! s:echoerr(m) abort
  echohl ErrorMsg
  echomsg string(a:m)
  echohl None
endfunction

let g:golangci_lint#prog = get(g:, 'golangci_lint#prog', 'golangci-lint')
let g:golangci_lint#errorformat = get(g:, 'golangci_lint#errorformat', s:errorformat)
