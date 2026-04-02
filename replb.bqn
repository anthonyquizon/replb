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
ref        ← ⟨⟩

Debug←{
    •Out (»⊸∨' '⊸≠)⊸/(𝕨⊑ref)∾":"                   # output trimmed line
    •Out "    "∾(•Fmt 𝕩)
}

ctx←{
    s    ⇐ ⟨⟩
    Push ⇐ {𝕊:s∾↩<𝕩}
    Peek ⇐ {𝕊:0=≠s?⟨⟩;¯1⊑s}                        # Return but don't pop top value
    Pop  ⇐ {t←-𝕩⋄(s↓˜↩t)⊢⌽t↑s}                     # Pop 𝕩 values; return as list
}

Import←{
    f←•file.Chars ∾⟜𝕩•file.Parent ctx.Peek@
    # TODO parse and index quads
    ctx.Push 𝕩
    Repl f
    ctx.Pop 1
}

repl↩•ReBQN {
  primitives⇐•primitives∾⟨
    '▯'‿•Show                                      # replaced by ▫ after parsing
    '▫'‿Debug
  ⟩,
  system⇐⟨
    "bqn"‿•Bqn,               "currenterror"‿•CurrentError,  "exit"‿•Exit
    "ffi"‿•FFI,               "file"‿•file,                  "flines"‿•flines,
    "fmt"‿•Fmt,               "hash"‿•hash,                  "hashmap"‿•hashmap
    "internal"‿•internal,     "unixtime"‿•unixtime,          "makerand"‿•MakeRand
    "math"‿•math,             "ns"‿•ns,                      "out"‿•Out,
    "parsefloat"‿•ParseFloat, "path"‿•path,                  "primitives"‿•primitives
    "repr"‿•repr,             "rand"‿•rand,                  "show"‿•show
    "term"‿•term,             "toutf8"‿•ToUTF8,              "type"‿•Type
    "wdpath"‿•wdpath,         "while"‿•_while_,              "rebqn"‿•rebqn
    # ==== overrides ====
    "import"‿Import
  ⟩
}

Eval⇐{
  •Out "--"
  ref↩⟨⟩
  l←(lf⊸=)⊸((¬/+`)∘⊣⊔¬⊸/) 𝕩                        # split lines by newline
  l↩l/˜0≠≠¨l                                       # drop empty leading lines
  f‿n←(»⊸∨' '⊸≠)⊸/¨0‿1⊏l                           # f: filename, n: selection range - strip leading spaces

  r0‿r1←•ParseFloat¨(':'⊸=)⊸((¬/+`)∘⊣⊔¬⊸/) n       # parse line number range
  r←(r0+1)+↕(1+r1)-r0                              # line number range 
  i←(≠l)↑r⊔∾⟜"⊸▫"∘•Fmt¨(≠ref)+↕≠r                  # format indices
  ref↩r⊏l
  c←i ∾∘∾¨⌾(r⊸⊏) l

  ctx.Push f
  ⟨"", "", f⟩ Repl ∾lf⊸∾¨2↓c
}

Run←{
  𝕊 ⟨⟩: 𝕊 ⟨8080⟩
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
      n‿ch←Read ⟨c_fd,1000000⥊0,1000000⟩
      Eval •FromUTF8 n↑ch
      1
    } •_while_ ⊢ 1
}

# TODO start with filename
{
  𝕩:𝕩≡"test"?@
; 𝕩:Run 𝕩
} •args

