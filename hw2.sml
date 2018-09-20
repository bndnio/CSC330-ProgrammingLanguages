(* if you use this function to compare two strings (returns true if the same
   string), then you avoid some warning regarding polymorphic comparison  *)

fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* Part 1 *)

(* 1 *)


(* 2 *)


(* 3 *)


(* 4 *)



(************************************************************************)
(* Game  *)

(* you may assume that Num is always used with valid values 2, 3, ..., 10 *)

datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw


exception IllegalMove

(* Part 2 *)

(* 5 *)


(* 6 *)


(* 7 *)


(* 8 *)


(* 9 *)


(* 10 *)


(* 11 *)

