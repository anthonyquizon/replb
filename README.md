# ReplB
Socket server for evaluating bqn file and prints out specified lines


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

```

## TODO
- [ ] mark lines

