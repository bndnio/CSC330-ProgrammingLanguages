(* if you use this function to compare two strings (returns true if the same
   string), then you avoid some warning regarding polymorphic comparison  *)

fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* Part 1 *)

(* 1 *)
fun all_except_option(s: string, sl: string list): string list option = 
    let 
        exception notFound
        fun all_except(s: string, sl: string list): string list =
            case sl of
                [] => raise notFound
              | s0::sl' =>
                    if same_string(s, s0)
                    then sl'
                    else s0::all_except(s, sl')
    in
        SOME (all_except(s, sl)) handle notFound => NONE
    end

val test1_0 = all_except_option("abc", []) = NONE

(* 2 *)
fun get_substitutions1(sll: string list list, s: string): string list =
    case sll of
        [] => []
      | (sl0::sll') =>
            let
                val names_without = all_except_option(s, sl0)
                (* print(String.concatWith ", " (map fn x => x names_without)) *)
            in
                case names_without of
                    NONE => get_substitutions1(sll', s)
                  | SOME names => names @ (get_substitutions1(sll', s))
            end

(* 3 *)
fun get_substitutions2(sll: string list list, s: string): string list = 
    let
        fun get_substitutions_through_tail(sll: string list list, s: string, osl: string list) =
            case sll of
                [] => osl
              | (sl0::sll') =>
                    let
                        val names_without = all_except_option(s, sl0)
                    in
                        case names_without of
                            NONE => get_substitutions_through_tail(sll', s, osl)
                          | SOME names => (get_substitutions_through_tail(sll', s, osl@names))
                    end
    in
        get_substitutions_through_tail(sll, s, [])
    end

(* 4 *)
fun similar_names(sll: string list list, {first: string, middle: string, last: string}) = 
    let
        val other_names = get_substitutions2(sll, first)
        fun convert_to_full_names(names: string list) =
            case names of
                [] => []
              | name::names' =>
                    {first = name, last = last, middle = middle}::convert_to_full_names(names')
    in
        {first = first, last = last, middle = middle}::convert_to_full_names(other_names)
    end


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

val test5_0 = card_color((Clubs,Ace)) = Black

(* 6 *)
fun card_value(s: suit, r: rank): int = 
    case r of
        Num i => i
      | (Ace) => 11
      | (King | Queen | Jack) => 10

val test6_0 = card_value((Clubs,Ace)) = 11

(* 7 *)
fun remove_card(cs: card list, c: card, e: exn): card list =
    case cs of
        [] => raise e
      | c0::cs' =>
            if c0 = c
            then cs'
            else c0::remove_card(cs', c, e)

exception notFound
val test7_0 = remove_card([], (Clubs, Ace), notFound) = [(Clubs, Ace)] handle notFound => true;

(* 8 *)
fun all_same_color(cs: card list): bool =
    let
        fun same_colors(cs: card list, co: color): bool =
            case cs of
                [] => true
              | c0::cl' =>
                    if card_color(c0) = co
                    then same_colors(cl', co)
                    else false
    in
        case cs of
            [] => true
          | c0::cs' => same_colors(cs', card_color(c0))
    end

val test8_0 = all_same_color([]) = true

(* 9 *)
fun sum_cards(cs: card list): int = 
    let
        fun sum(l, acc) =
            case l of
                [] => acc
              | c0::cs' => sum(cs', card_value(c0)+acc)
    in
        sum(cs, 0)
    end

val test9_0 = sum_cards([(Clubs, Ace), (Diamonds, Jack)]) = 21

(* 10 *)
fun score(cs: card list, g: int): int =
    let
        val game_sum = sum_cards(cs)
        val same_colors = all_same_color(cs)
        val raw_score = if g - game_sum > 0 then g - game_sum else (game_sum - g) * 2
        val final_score = if same_colors then raw_score div 2 else raw_score
    in
        final_score
    end

val test10_0 = score([], 0) = 0

(* 11 *)
fun officiate(cs: card list, ml: move list, g: int): int =
    let
        exception IllegalMove
        fun process_game(cs: card list, ml: move list, hc: card list): card list =
            if sum_cards(hc) > g
            then hc
            else
                case ml of
                    [] => hc
                    | m0::ml' =>
                        case m0 of
                            Discard d => process_game(cs, ml', remove_card(hc, d, IllegalMove))
                            | Draw =>
                                case cs of
                                    [] => hc
                                    | c0::cs' => process_game(cs', ml', c0::hc)
        val sc = score(process_game(cs, ml, []), g)
    in
        score(process_game(cs, ml, []), g)
    end
