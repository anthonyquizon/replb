⟨Eval⟩←"test" •Import "./replb.bqn"

lf←@+10
Eval "
  foo.bqn
  2:2
  a←1
  b←2
  c←3
"

#Eval "1:1
  #Foo←{𝕩+1} # should add DEBUG at x+1
  #Foo 2
#"
