#!/usr/bin/env bqn

⟨Eval⟩←"test" •Import "./replb.bqn"

lf←@+10

Eval "
  test 
  2:2
  a←1
  b←2 # should print 2
  c←3
"

Eval "
  test
  2:2
  Foo←{
    𝕩+1 # should print 2
  } 
  Foo 1
"



#Eval "
  #test
  #1:1
  #Foo←{𝕩+1} # should add ▫ at x+1
  #Foo 2
#"

