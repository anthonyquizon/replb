#!/usr/bin/env bqn

# Reference: https://github.com/Brian-ED/bqn-socket/blob/master/socket.bqn
# Reference: https://github.com/anthonyquizon/dbq/blob/bcd6c4bcff9c9912032a1c30b946bdba7158e47e/src/rt.bqn
# TODO read config file for port?


lf           ← @+10
af_inet      ← 2
inaddr_any   ← 0
sock_stream  ← 1
sol_socket   ← 65535                                                  # 0xffff
so_reuseaddr ← 2                                                      # 0x0004

sockaddr    ← "{u16,[14]u8}"
sockaddr_in ← "{u16,u16,{u32},[8]u8}"

socket     ← @ •FFI "i32"‿"socket"‿"i32"‿"i32"‿"i32"
setsockopt ← @ •FFI "i32"‿"setsockopt"‿"i32"‿"i32"‿"i32"‿"*i32"‿"i32"
bind       ← @ •FFI "i32"‿"bind"‿"i32"‿('&'∾sockaddr_in)‿"u32"
listen     ← @ •FFI "i32"‿"listen"‿"i32"‿"i32"
accept     ← @ •FFI "i32"‿"accept"‿"i32"‿('&'∾sockaddr)‿"&u32"
send       ← @ •FFI "i64"‿"send"‿"i32"‿"*u8"‿"u64"‿"i32"

htons      ← @ •FFI "i32"‿"htons"‿"i32"
read       ← @ •FFI "i32"‿"read"‿"i32"‿"&u8"‿"i32"

Debug←{
  𝕊𝕩:•Show 𝕩
; 𝕨𝕊𝕩: 
    •Out (»⊸∨' '⊸≠)⊸/𝕨∾":" # output trimmed line
    •Out "    "∾(•Fmt 𝕩)
}

repl←•ReBQN { 
  repl⇐"none" 
  system⇐⟨
    # overrides of system function
    "args"‿⟨"debug"⟩
    "debug"‿Debug

    # remapping of system functions - no •system list
    "bqn"‿•Bqn
    "currenterror"‿•CurrentError
    "exit"‿•Exit
    "ffi"‿•FFI
    "file"‿•file
    "flines"‿•flines
    "fmt"‿•fmt
    "hash"‿•hash
    "hashmap"‿•hashMap
    "internal"‿•internal
    "unixtime"‿•unixtime
    "makerand"‿•makeRand
    "math"‿•math
    "ns"‿•ns
    "out"‿•out
    "show"‿•show
    "parsefloat"‿•parseFloat
    "path"‿•path
    "primitives"‿•primitives
    "repr"‿•repr
    "rand"‿•rand
    "term"‿•term
    "toutf8"‿•toUTF8
    "type"‿•type
    "wdpath"‿•wdpath
    "while"‿•_while_
  ⟩
}

Eval←{ 
  •Out "=== REPL ==="
  l←(lf⊸=)⊸((¬/+`)∘⊣⊔¬⊸/) 𝕩 # split lines by newline
  r0‿r1←•ParseFloat¨(':'⊸=)⊸((¬/+`)∘⊣⊔¬⊸/) ⊑l # parse line number range
  r←(r0)+↕(1+r1)-r0 # line number range 
  c←{('"'∾𝕩∾'"')∾"⊸•DEBUG "∾𝕩}¨⌾(r⊸⊏) l # TODO escape strings
  # TODO parse if cursor is in function 
  Repl ∾lf⊸∾¨1↓c
}

Run←{
  𝕊 ⟨⟩: 𝕊 8080
; 𝕊 ⟨port⟩: 0≡•Type port? 𝕊 ⟨•ParseFloat port⟩
; 𝕊 ⟨port⟩:
    srv_addr ← ⟨af_inet,Htons ⟨port⟩,⟨0⟩,8⥊0⟩
    srv_fd←Socket af_inet‿sock_stream‿0
    Setsockopt srv_fd‿sol_socket‿so_reuseaddr‿⟨1⟩‿4
    Bind ⟨srv_fd,⋈srv_addr,16⟩
    Listen srv_fd‿3

    •Out "listening to port "∾•Fmt port

    {𝕊:
      c_fd‿·‿· ← Accept⟨srv_fd, ⋈⟨0, 14⥊0⟩, ⋈16⟩
      n‿ch←Read ⟨c_fd,1024⥊0,1024⟩ # b: buffer
      Eval •FromUTF8 n↑ch
      1
    } •_while_ ⊢ 1
}

Test←{𝕊:
  Eval "1:1
    a←1
    b←2
    c←3
  "
}

{
  𝕩:𝕩≡⟨"test"⟩?Test@
; 𝕩:Run 𝕩
} •args
