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
                    NONE => []
                  | SOME names => names @ (get_substitutions1(sll', s))
            end


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
      | c0::cs' =>
            if c0 = c
            then cs'
            else c0::remove_card(cs', c, e)

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

(* 11 *)
fun officiate(cs: card list, ml: move list, g: int): int =
    let
        exception IllegalMove
        fun process_game(cs: card list, ml: move list, hc: card list): card list =
            let
            in
                case ml of
                    [] => hc
                  | m0::ml' =>
                        case m0 of
                            Discard d => process_game(cs, ml', remove_card(hc, d, IllegalMove))
                          | Draw =>
                                case cs of
                                    [] => hc
                                  | c0::cs' => process_game(cs', ml', c0::hc)
            end
    in
        score(process_game(cs, ml, []), g)
    end
