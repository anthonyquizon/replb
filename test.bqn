


#cc←"
  #Foo←{•SHow 𝕩}
#"
#re←•ReBQN { scope⇐"read" }
#Re cc∾"Foo 1"
#•Exit 0

#•Show 1
#•Show 2
#•Show 3
#•Show 4
#•Show 4

n←"1:10"
•SHow m←':'=n
•SHow 
•SHow •ParseFloat¨((+`/˜¬)m)⊔(¬m)/n
•SHow •ParseFloat¨((¬/+`)m)⊔(¬m)/n
#•SHow •ParseFloat¨m (¬/+`)⊸⊔ ¬⊸/⊢ n
•SHow (¬/+`) m
•SHow z←m ¬⊸/ n
•SHow m ((¬/+`)∘⊣⊔¬⊸/) n
•SHow x0‿x1←•ParseFloat¨(':'⊸=)⊸((¬/+`)∘⊣⊔¬⊸/) n


#n+`m
a←"
1+1
2+2
3+3
"


lf←@+10
#l←((⊢-˜+`×¬)∘=⊔⊢)
l←(+`lf=⊢)a # line numbers
b←¯1↓1↓1⊸↓¨l⊔a

•Show ≠b
•SHow xx←x0+↕(x1-x0)
•SHow xx↩xx/˜(≠b)>xx
#•SHow ("•SHow "⊸∾¨)⌾((⋈xx)⊸⊏) b
•Show 
•SHow {('"'∾𝕩∾'"')∾"⊸•SHow "∾𝕩}¨⌾(xx⊸⊏) b
#•SHow xx↩∾⟜⟨"•SHOW "⟩ ¨xx
#•Sho(≠b)⥊w ⟨⟨⟩⟩⥊˜≠b
#•Show ⟨"•Show "⟩/˜1=↕≠b


