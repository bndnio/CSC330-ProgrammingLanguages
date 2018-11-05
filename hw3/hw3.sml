(* Assign 03 Provided Code *)

(*  Version 1.0 *)

exception NoAnswer

datatype pattern = Wildcard
		 | Variable of string
		 | UnitP
		 | ConstP of int
		 | TupleP of pattern list
		 | ConstructorP of string * pattern

datatype valu = Const of int
	      | Unit
	      | Tuple of valu list
	      | Constructor of string * valu

(* Description of g: *)
fun g f1 f2 p =
    let
	val r = g f1 f2
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end

(**** put all your code after this line ****)

(* 1 *)
val only_capitals = List.filter (fn s => Char.isUpper (String.sub(s, 0)))

(* 2 *)
val longest_string1 =
	List.foldl
		(fn (s, max_str) =>
			if (String.size(s) > String.size(max_str))
			then s
			else max_str)
		""
	

(* 3 *)
val longest_string2 =
	List.foldl
		(fn (s, max_str) => 
			if (String.size(s) >= String.size(max_str))
			then s
			else max_str
		)
		""

(* 4 *)
fun longest_string_helper(cmp_func: (int * int) -> bool) =
	List.foldl
		(fn (s, max_str) =>
			if cmp_func(String.size(s), String.size(max_str))
			then s
			else max_str)
	""

val longest_string3 = longest_string_helper Int.>

val longest_string4 = longest_string_helper Int.>=

(* 5 *)
val longest_capitalized = longest_string3 o only_capitals

(* 6 *)
val rev_string = implode o rev o explode

(* 7 *)
fun first_answer f l =
	case List.foldl
		(fn (e, first) =>
			if isSome(first)
			then first
			else case f(e) of
					NONE => first
				  | SOME e => SOME e
		)
		NONE
		l
	of
		NONE => raise NoAnswer
	  | SOME e => e

(* 8 *)
fun all_answers f l =
	let
		fun check_answers(l, acc) =
			case l of
				[] => acc
			  | lh::lt =>
			  		case f(lh) of
						SOME e => check_answers(lt, acc@e)
					  | _ => []
	in
		if l = []
		then SOME []
		else case check_answers(l, []) of
			[] => NONE
		  | answers => SOME answers
	end

(* 9a *)
(* 
	g accepts two functions and a pattern p in a curried fashion
	g computes the sum of the output of f1 and f2 for each element in pattern p
	where function f1 is applied to Wildcard patterns
	and function f2 is applied to Variable patterns
 *)

(* 9b *)
val count_wildcards = g (fn() => 1) (fn (x) => 0)

(* 9c *)
val count_wild_and_variable_lengths = g (fn() => 1) (fn (x) => String.size(x))

(* 9d *)
fun count_some_var(name, ps) = g (fn() => 0) (fn (x) => if x=name then 1 else 0) ps

(* 10 *)
fun check_pat(pat) = 
	let
		fun traverse(p) = 
			case p of
				Wildcard          => []
			  | Variable x        => [x]
			  | TupleP ps         => List.foldl (fn (p, acc) => (traverse p) @ acc) [] ps
			  | ConstructorP(_,p) => traverse p
			  | _                 => []
		fun unique_str(lst) =
			case lst of
				[] => true
			  | head::rest =>
					if List.exists (fn(e) => e=head) rest
					then false
					else unique_str(rest)
	in
		unique_str(traverse(pat))
	end

(* 11 *)
fun match(v: valu, p: pattern): (string * valu) list option =
	let 
		fun foldtuple ((vs: valu list, ps: pattern list), acc: (string * valu) list option): (string * valu) list option =
			case (vs,ps) of
				([],[]) => acc
			  | (vhd::vtl, phd::ptl) => (
					case match(vhd,phd) of 
						(NONE) => NONE
					  | (SOME out) => foldtuple((vtl,ptl), SOME((if isSome acc then valOf acc else [])@out))
				)
			  | (_,_) => NONE
	in
		case (v, p) of 
			(_, Wildcard)          => SOME []
		  | (_, Variable s)        => SOME [(s, v)]
		  | (Unit, UnitP)          => SOME []
		  | (Const x, ConstP s)    => if x=s then SOME [] else NONE
		  | (Tuple vs, TupleP ps)  => foldtuple((vs, ps), NONE)
		  | (Constructor(s1,v), ConstructorP(s2,p)) => if s1=s2 then match(v,p) else NONE
		  | (_,_)                 => NONE
	end

(* 12 *)
fun first_match (v: valu) (ps: pattern list): (string * valu) list option =
	SOME (first_answer (fn (p) => match(v, p)) ps) handle NoAnswer => NONE
