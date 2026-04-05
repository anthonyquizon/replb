#!/usr/bin/env bqn

# Reference: https://github.com/Brian-ED/bqn-socket/blob/master/socket.bqn
# Reference: https://github.com/anthonyquizon/dbq/blob/bcd6c4bcff9c9912032a1c30b946bdba7158e47e/src/rt.bqn
# TODO read config file for port?

lf           ← @+10
af_inet      ← 2
inaddr_any   ← 0
sock_stream  ← 1
sol_socket   ← 65535                               # 0xffff
so_reuseaddr ← 2                                   # 0x0004

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
repl       ← @
port       ← 8080
ref        ← ⟨⟩                                    # reference table of id numbers to line info 

cur        ← @                                     # current buffer to be evaluated that has been sent over from the socket

Debug←{
  •Out (»⊸∨' '⊸≠)⊸/(𝕨⊑ref)∾":"                     # output trimmed line
  •Out "    "∾(•Fmt 𝕩)
}

ctx←{
  s    ⇐ ⟨⟩
  Push ⇐ {𝕊:s∾↩<𝕩}
  Peek ⇐ {𝕊:0=≠s?⟨⟩;¯1⊑s}                          # Return but don't pop top value
  Pop  ⇐ {t←-𝕩⋄(s↓˜↩t)⊢⌽t↑s}                       # Pop 𝕩 values; return as list
}

Eval⇐{ 𝕨 𝕊 l:
  r0‿r1←•ParseFloat¨(':'⊸=)⊸((¬/+`)∘⊣⊔¬⊸/) 1⊑l     # parse line number range
  r←(r0+1)+↕r0-˜1+r1                               # line number range 
  i←(≠l)↑r⊔∾⟜"⊸▫"∘•Fmt¨(≠ref)+↕≠r                  # format indices
  ref↩ref∾r⊏l
  c←i ∾∘∾¨⌾(r⊸⊏) l
  𝕨 Repl ∾lf⊸∾¨2↓c
}

Import←{
    𝕊 𝕩: ⟨⟩ 𝕊 𝕩
; 𝕨 𝕊 𝕩:
  p‿·‿·←ctx←⟨•file.Parent ctx.Peek@, •file.Name 𝕩, 𝕨⟩
  { 𝕩:𝕩≡0⊑cur? ctx Eval cur
  ; 𝕩:ctx Repl •file.Chars 𝕩
  } p∾𝕩
}

ReBQN←{ 𝕊 path:
  re←•ReBQN {
    primitives⇐•primitives∾⟨
      '▯'‿•Show                                    # TODO remove replaced by ▫ after parsing
      '▫'‿Debug
    ⟩,
    system⇐⟨
      "bqn"‿•Bqn,               "currenterror"‿•CurrentError,  "exit"‿•Exit
      "ffi"‿•FFI,               "file"‿•file,                  "flines"‿•flines,
      "fmt"‿•Fmt,               "hash"‿•hash,                  "hashmap"‿•hashmap
      "internal"‿•internal,     "unixtime"‿•unixtime,          "makerand"‿•MakeRand
      "math"‿•math,             "ns"‿•ns,                      "out"‿•Out,
      "parsefloat"‿•ParseFloat, "path"‿path,                  "primitives"‿•primitives
      "repr"‿•repr,             "rand"‿•rand,                  "show"‿•show
      "term"‿•term,             "toutf8"‿•ToUTF8,              "type"‿•Type
      "wdpath"‿•wdpath,         "while"‿•_while_,              "rebqn"‿•rebqn
      # ==== overrides ====
      "import"‿Import
    ⟩
  }

  Repl↩{ ·‿f‿· 𝕊 𝕩:
    ctx.Push f
    𝕨 Re 𝕩
    ctx.Pop 1
  }
}

Run←{𝕊 entry:
  srv_addr ← ⟨af_inet,Htons ⟨port⟩,⟨0⟩,8⥊0⟩
  srv_fd←Socket af_inet‿sock_stream‿0
  Setsockopt srv_fd‿sol_socket‿so_reuseaddr‿⟨1⟩‿4
  Bind ⟨srv_fd,⋈srv_addr,16⟩
  Listen srv_fd‿3

  •Out "listening to port "∾•Fmt port

  {𝕊:
    c_fd‿·‿· ← Accept⟨srv_fd, ⋈⟨0, 14⥊0⟩, ⋈16⟩
    n‿ch←Read ⟨c_fd,1000000⥊0,1000000⟩
    
    •Out "--"
    b←•FromUTF8 n↑ch
    l←(lf⊸=)⊸((¬/+`)∘⊣⊔¬⊸/) b                      # split lines by newline
    l↩l/˜⌈`0≠≠¨l                                   # drop empty leading header lines
    l↩(»⊸∨' '⊸≠)⊸/¨⌾(0‿1⊸⊏) l                      # f: filename, n: selection range - strip leading spaces (helps with debugging/tests)
    cur↩l ⋄ ref↩⟨⟩

    { 𝕩:(𝕩⊸≡∨≡⟜@)entry?                                   # if buffer is entry, eval now
        path←•file.Parent 𝕩
        repl↩ReBQN path
        ⟨path, entry, •args⟩ Eval 𝕩
    ; 𝕩:                                           # eval buffer on •Import 
        ch←•file.Chars entry
        path←•file.Parent entry
        repl↩ReBQN path
        ⟨path, entry, •args⟩ Repl ch
    } 0⊑l

    cur↩@ ⋄ ref↩⟨⟩
    1
  } •_while_ ⊢ 1
}

{
  ⟨s⇐socket,out⟩:
    # TODO override effs
    @
; 𝕩:𝕩≡"test"?@                                     # TODO delete
; 𝕩:1=≠𝕩? Run •path •file.At ⊑𝕩                    # Run with 
; 𝕩: Run@
} •args

