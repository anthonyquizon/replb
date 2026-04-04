# ReplB
Socket server wrapper for •ReBQN. 
Prints out expressions on specified lines


Vim mappings
```vim
fu! SendToSocket(host, port) range
  let tmp = tempname()
  call writefile([a:firstline.':'.a:lastline] + getline(1, '$'), tmp)
  call system('nc -c -w0 ' . a:host . ' ' . a:port . ' < ' . tmp . ' &')
  call delete(tmp)
endf
nn <leader>w :call SendToSocket('localhost', 8080)<CR>
vn <leader>w :call SendToSocket('localhost', 8080)<CR>

" add show alias
nn <leader>q a▯<Esc> 
ino <leader>q ▯
```

## TODO
- [ ] AST parsing
- [ ] set starting script 
- [ ] formatting options
- [ ] generate port from parent folder
- [ ] read config file
- [ ] toggle ▯ output

