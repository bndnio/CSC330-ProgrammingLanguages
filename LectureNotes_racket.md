CSC 330

Oct 15, 2018; Lecture 10

dynamically typed.  
more errors at runtime.  

no more infix operators.  

`(function_name param_1 param_2)`  

`1::[]` is equivalent to:  
`(cons 1 null)`  

`car` is head, `cdr` is tail  

### syntax

atom: #t, #f, 34, "hi", null, 4.0, x, ...  
special form: define, lambda, if, ...  
sequence of terms in parans (t1, t2, ... tn)  

```
( if ( cond )
  ( do if true )
  ( do if flase )
)

( cond
  [ ( check ) do ]
  [ ( check ) do ]
)
```

ifs perform lazy evaluation.  

`(cons 1 2)` doesn't create a list, it creates a pair  
`(cons 1 (cons 2 null))` creates a list  
`(cons 1 (cons 2 3)` creates a list with a pair as the last element (2 . 3)  

if `!set` is used, the variable becomes mutable, otherwise externally constant.

`car` returns first element of pair, 
`cdr` returns second (last) element of pair.

---

18 Oct, 2018; Lecture 11

Midterms back. 

Other stuff??

---

22 Oct, 2018; Lecture 12

Didn't take notes.  

talked about macros, lexical scoping in closures.  

Macros do not evaluate parameters until used.  

After class talked about passing by ref or value. 
Doesn't really matter in racket since expensive things are mostly immutable.  

---






