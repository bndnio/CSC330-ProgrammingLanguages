(* if you use this function to compare two strings (returns true if the same
   string), then you avoid some warning regarding polymorphic comparison  *)

fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* Part 1 *)

(* 1 *)
fun all_except_option(s: string, sl: string list): string list option = 
    let 
        fun string_in_list(s: string, sl: string list): bool =
            case sl of
                [] => false
              | s0::sl' =>
                    if same_string(s0, s)
                    then true
                    else string_in_list(s, sl')
        val s_in_list = string_in_list(s, sl)
        fun all_except(s: string, sl: string list): string list =
            case sl of
                [] => []
              | s1::sl' =>
                    if same_string(s, s1)
                    then all_except(s, sl')
                    else s1::all_except(s, sl')
    in
        if s_in_list
        then SOME ( all_except(s, sl) )
        else NONE
    end

(* 2 *)
fun get_substitutions1(sll: string list list, s: string): string list = []

(* 3 *)
fun get_substitutions2(sll: string list list, s: string): string list = []

(* 4 *)
fun similar_names(sll: string list list, {first: string, middle: string, last: string}) = []


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
fun card_color(s: suit, r: rank): color =
    if s = Diamonds orelse s = Hearts
    then Red
    else Black

(* 6 *)
fun card_value(s: suit, r: rank): int = 
    case r of
        Num i => i
      | (Ace) => 11
      | (King | Queen | Jack) => 10

(* 7 *)
fun remove_card(cs: card list, c: card, e: exn): card list =
    case cs of
        [] => raise e
      | head::tail =>
            if head = c
            then tail
            else head::remove_card(tail, c, e)

(* 8 *)
fun all_same_color(cs: card list): bool =
    let
        fun ***(cs: card list, co: color): bool =
            case cs of
                [] => true
              | head::tail =>
                    if card_color(head) = co
                    then ***(tail, co)
                    else false
    in
        case cs of
            [] => true
          | head::tail => ***(tail, card_color(head))
    end

(* 9 *)
fun sum_cards(cs: card list): int = 
    let
        fun sum(l, acc) =
            case l of
                [] => acc
              | head::tail => sum(tail, card_value(head)+acc)
    in
        sum(cs, 0)
    end

(* 10 *)
fun score(cs: card list, g: int): int = 0

(* 11 *)
fun officiate(cs: card list, ml: move list, g: int): int = 0
