# CSC 330

10 Sept, 2018; Lecture 1


```

function count(str) {
  let counts = {};
  str.forEach(char => counts[char] += 1)
  count.forEach(char => console.log(`${char}: ${counts[char]}`
}
```

Broken into four quadrants, two axis:
- Statically/Dynamically Typed  
- Object Oriented/Functaional

Going to study 'SML' in static & functional quadrant, then 'racket'->'scheme'->'lisp' in dynamic functional quadrant, then 'ruby' in oo dynamic quadrant

---

# SML

Binding: definition of a variable or function  

```sml
(* comments *)  

val x = 34;
(* type of x : int, value of x = 34 *)  

val y = 17;
(* type of x : int, value of x = 34
   type of y : int, value of y = 17
*)  

(* no forward defintions, variables must be defined before *)
val z = (x + y) + (y + 2);
(* type of x : int, value of x = 34
   type of y : int, value of y = 17
   type of z : int, value of z = 70
*)

(* statically typed: infers from initial type *)  
(* at compile time, compiler checks environment: looking for type matching *)  
(* bindings are permanant *)

val z = 10;
(* type of x : int, value of x = 34
   type of y : int, value of y = 17
   type of z : int, value of z = 70
   type of z : int, value of z = 10
*)

val z = z;
(* type of x : int, value of x = 34
   type of y : int, value of y = 17
   type of z : int, value of z = 70
   type of z : int, value of z = 10
   type of z : int, value of z = 10
*)

val q = z+1;
(* type of x : int, value of x = 34
   type of y : int, value of y = 17
   type of z : int, value of z = 70
   type of z : int, value of z = 10
   type of z : int, value of z = 10
   type of q : int, value of q = 11
*)

val abs_of_z = if z < 0 then 0 -z else z;
(* all are bindings or expressions, both expressions (then/else) needs to have the same type because it's required at compile time *)
(* ...
   type of abs_of_z : int, value of abs_of_z 70  
*)

val abs_of_z_simpler = abs z;
val abs_of_z_simpler = abs (z);
(* ^^ equivalent *)

(* ';' optional in program, mandatory in repl *)
val c = #"a"  
(* ...
   type of c : char, value of c = 'a'
*)

2.0 + 1;
(* will throw error *)  

1 > 3;
(* type: false *)

1 <> 3;
(* type : true *)

-1;
(* throws error, interprets - and 1 as separate tokens *)

~1;
(* type : int, value

```

__Syntax__ is just how it's written  
__Semantics__ what it means (comprised of __type-checking__ and __evaluation__)  
__Need to know:__  
- syntax rules
- type checking rules
- evaluation rules

if <true> then <expression is evaluated> else <expression is never evaluated> due to lazy evaluation  

`true orelse exp2`  
`false andalso exp2`  
exp2 will not be evaluated  

^^ syntax sugar  
can be written using `if then else`  


functions:  
```sml  
(* note: correct only if y >= 0 *)  

fun pow (x:int, y:int) = 
  if (y=0)
  then 1  
  else x * pow(x,y-1)

val z = pow(3, 5);
```

have two parts:  
- How they're defined,
- How they're used  

functions are used like variables:  
output of above code :  
```sml  
val pow = fn : int * int ->
val z = 243 : int
END
```

---

10 Sept, 2018; Lecture 2

Tuples are cross products

```
val x = (1, 2.0);
(* val x = (1, 2.0) : int * real *)

(#1 x);
(#2 x);
#1 x;
#1 (x);

fun swap(pr: int*bool) = (#2 pr, #1pr)
```

There's only a single param in functions, they're "pattern matched" to tuples

Tuples are of fixed length, but any mix of types.  
Lists are variable length, but must be all the same type.

```sml
fun sum_list xs: int list): int =
  if null xs
  then 0
  else (hd xs) + sum_list(tl xs)

fun countdown(x : int) : int list =
  (* countdown(4) = [4,3,2,1]
     countdown(0) = []
  *)
  if x = 0
  then []
  else x :: countdown(x-1)

fun append(xs: int list, ys: int list) : int list =
  if null xs
  then ys
  else (hd xs) :: append(tl xs, ys)
```

`()` is called 'unit'

---

13 Sept, 2018; Lecture 3

```sml
fun split(list: int list) : int list * int list = 
  if null lst
  then ([],[])
  else
    let
      val rest = split(tl lst);
    in
      if (hd lst) >= 0
      then ((hd lst)::(#1 rest), (#2 rest))
      else ((#1 rest), (hd lst)::(#2 rest))
    end

val test = split([1,2,~3,9,0,~5])
```

Dynamically typed does not mean the ability to change the type. 
It's that the types are set at runtime, not compile time.

5 aspects to learn about a programming language:  
1. Syntax  
2. Semantics  
3. Idioms (typical patterns of solving problems)  
4. Libraries  
5. Tools (compiler/interpretter, IDE/editor, debugger, linters, package managers)

Course is about 1, 2, & 3.

Records:  
```
val x = {f1=1, f2="abc", f3="4.0"}

(#f1 x)
- 4.0
```

tuples are actually records where the attribute names are numbers from 1 to n.

writing a record in order as a tuple, would be interpreted and displayed as a tuple.

__Pure Functions__ has no side effect.  

---

17 Sept, 2018; Lecture 4

expression trees

```sml
datatype exp = Constant of int
  | Negate of exp
  | Add    of exp * exp
  | Multiply of exp * exp

fun eval e =
  case e of
      Constant i    => i
    | Negate e2 => ~(eval e2)
...
```

pattern matching is _not_ switch/case statements (expressions)  

```
a::[]
 ^^ 
 ||
 |cons
 |
 infix operator
```

Most datatypes are recursive in sml

`'a` is alpha type, meaning any type

`val (a, b, c) = (1, 2, 3+5)` is valid

`()` is unit. `fun nothing() = ...`  
The `()` is required, as it's the 'unit' parameter

```sml
fun zip list_tripe = 
  case list_triple of
      ([],[],[]) => []
    | (hd1::tl1, hd2::tl2, hd3::tl3) =>
         (hd1,hd2,hd3)::zip(tl1,tl2,tl3)
    | _ => raise ListLengthMistmatch
```

^^ Nice way to use pattern matching to run a zip function

tail recursion optimization: If there's nothing left to do in that recursive function,
it can reuse the stack frame for the next function.

e.g:

```sml
fun fact n =
  let
    fun aux(n,acc) = 
      if 
... continued from sml part 2 slides
```

---

20 Sept, 2018; Lecture 5

Funtions are first class systems

Functions are closures:  
- code +  
- environment

__map__

```sml
fun map (f,xs) =
  case cs of
      [] => []
    | x::xs' => (f x)::(map(f,xs'))
```

__filer__

If function evaluates to false, don't include in returned list.

```sml
fun filter (f,xs) =
  case xs of
      [] => []
    | x:xs' => if f x
               then x::(filter(f,xs'))
               else filter(f,xs')
```

---

24 Sept, 2018; Lecture 6

Feature of __closure__: function travels with code & environment

```sml
fun op + (x, y) = x * y

val z = 4 + 3
(* = 12 *)

infix times

fun times (x, y) = x * y
val z2 = 4 times 3
(* = 12 *)
```

infix operators run left to right (right associative)  

lexical scope: use environment where function is defined  
dynamic scope: use environment where function is called  

---

27 Sept, 2018; Lecture 7

`val h = f o g`, composses g in f as in, `h(x) = f(g(x))`  

infix operators offer from right to left.  

could go:  
```sml
infix |>
fun x |> f = f x

fun sqrt_of_abs i =
  i |> abs |> Real.fromInt |> Math.sqrt

(* instead of *)  
val sqrt_of_abs = Math.sqrt o Real.fromInt o abs
```

__partial application__ is when a curried function is partially resolved

`val x = ref 5` creates ref value  
to set a ref: `x := 3`  
to read a ref: `!x`  

---

1 Oct, 2018; Lecture 8

## Typing

static typing: reject program at compile time  
dynamic typing: run and check types at runtime  

```sml
(*
f: ( T1 * T2 * T3 ) -> T4
T4 =  ( T1 * T2 * T3 ) and T4 = (T1 * T2 * T3)
only satisfiable if T1 = T2
f: ( T1 * T1 * T3 ) => (T1 * T1 * T3)
f: ( 'a * 'a * 'b ) -> ( 'a * 'a * 'b )
*)
fun f(x,y,z) =
  if true
  then (x,y,z)
  else (y,x,z)


(*
compose ( T1 * T2 ) -> T3
anonymous function: T4 -> ( T5 * T6 )
because anonymous function calls param f
T1 = ( T2 * T3 ) -> 

compose: T1 -> T2
f: T3 -> T4
g: T5 -> T6
T2: T7 -> T8 (type of the function returned)
x: T7
the function will return the type of the return value of f
the anon function returns T4
T8 = T4
x is the parameter to g => type of x is T5 => T7 = T5
We pass the return value of g to x => T3 = T6
T1 = (T3->T4, T5->T6)
T1 = (T3->T4, T5->T3)
T2 = (T5->T4)
compose: (T3->T4, T5->T3) -> (T5->T4)
compose: ('a -> 'b) * ('c -> 'a) -> ('c -> 'b)
*)
fun compose (f,g) = fn x => f (g x)

val compose f g = f o g
```

### Signatures

```sml
signature MATHLIB = 
sig
  val fact : int -> int
  val half_pi : real
  val doubler : int -> int
end

structure MyMathLib :> MATHLIB = 
struct
  fun fact x = ...
  fun half_pi = Math.pi / 2.0
  fun doubler x = x * 2
end
```

---

4 Oct, 2018; Lecture 9

talked about sml 04, particularily equivalence

---





