if exists('g:loaded_golangci_lint')
  finish
endif
let g:loaded_golangci_lint = 1

command! -nargs=* -bang GolangciLint call golangci_lint#call(<q-bang>, [<f-args>])
