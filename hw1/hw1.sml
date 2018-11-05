(*  Assignment #1
    CSC 330

    Brendon Earl
    V00797149
*)

type DATE = (int * int * int)
exception InvalidParameter

(* #1 *)
fun is_older(d1: DATE, d2: DATE): bool =
    if (#1 d1) < (#1 d2)
    then true
    else
        if (#1 d1) > (#1 d2)
        then false
        else
            if (#2 d1) < (#2 d2)
            then true
            else
                if (#2 d1) > (#2 d2)
                then false
                else
                    if (#3 d1) < (#3 d2)
                    then true
                    else false

(* #2 *)
fun number_in_month(dl: DATE list, m: int): int =
    if null dl
    then 0
    else
        if (#2 (hd dl)) = m
        then number_in_month(tl dl, m) + 1
        else number_in_month(tl dl, m)

(* #3 *)
fun number_in_months(dl: DATE list, ml: int list): int = 
    if null ml
    then 0
    else number_in_month(dl, hd ml) + number_in_months(dl, tl ml)

(* #4 *)
fun dates_in_month(dl: DATE list, m: int): DATE list =
    if null dl
    then []
    else
        if (#2 (hd dl)) = m
        then (hd dl)::dates_in_month(tl dl, m)
        else dates_in_month(tl dl, m)

(* #5 *)
fun dates_in_months(dl: DATE list, il: int list): DATE list = 
    if null il
    then []
    else dates_in_month(dl, hd il) @ dates_in_months(dl, tl il)

(* #6 *)
fun get_nth(sl: string list, n: int): string =
    let
        fun iterate_to_nth(sl: string list, n: int, c: int): string =
            if null sl
            then raise InvalidParameter
            else
                if n = c
                then hd sl
                else iterate_to_nth(tl sl, n, c+1)
    in
        if n = 0
        then raise InvalidParameter
        else iterate_to_nth(sl, n, 1)
    end

(* #7 *)
fun date_to_string(d: DATE): string  = 
    let
        fun month_to_string(m: int): string =
            let
                val months = [
                    "January", "February", "March", "April", "May", "June", 
                    "July", "August", "September", "October", "November", "December"
                ]
                fun get_nth_month(ml: string list, m: int, c: int) =
                    if m = c
                    then (hd ml)
                    else get_nth_month(tl ml, m, c+1)
            in
                get_nth_month(months, m, 1)
            end
    in
        (month_to_string(#2 d))^" "^Int.toString(#3 d)^", "^Int.toString(#1 d)
    end

(* #8 *)
fun number_before_reaching_sum(sum: int, il: int list): int =
    let
        fun count_to_sum(sum: int, il: int list, c: int): int =
            if null il
            then 0
            else
                if c + (hd il) >= sum
                then 0
                else 1 + count_to_sum(sum, tl il, c + (hd il))
    in
        count_to_sum(sum, il, 0)
    end

(* #9 *)
fun what_month(d: int): int = 
    let
        val days_of_months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    in
        number_before_reaching_sum(d, days_of_months)+1
    end

(* #10 *)
fun month_range(d1: int, d2: int): int list = 
    let
        fun month_of_days(c: int, e: int): int list =
            if c > e
            then []
            else what_month(c)::month_of_days(c+1, e)
    in
        month_of_days(d1, d2)
    end

(* #11 *)
fun oldest(dl: DATE list): DATE option = 
    if null dl
    then NONE
    else
        let
            fun min_DATE(dl: DATE list, minD: DATE): DATE option =
                if null dl
                then SOME minD
                else 
                    if is_older(minD, hd dl)
                    then SOME minD
                    else min_DATE(tl dl, hd dl)
        in
            min_DATE(tl dl, hd dl)
        end

(* #12, 13, 14, 15 *)
fun reasonable_date(d: DATE): bool = 
    let
        fun days_in_month(d: DATE): int =
            let
                val days_of_months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
                fun get_nth_month(ml: int list, m: int, c: int) =
                    if m = c
                    then (hd ml)
                    else get_nth_month(tl ml, m, c+1)
            in
                get_nth_month(days_of_months, (#2 d), 1)
            end
        fun valid_year(d: DATE): bool = 
            if (#1 d) > 0
            then true
            else false
        fun valid_month(d: DATE): bool =
            if (#2 d) > 0 andalso (#2 d) < 13
            then true
            else false
        fun valid_date(d: DATE): bool =
            if (#3 d) < 1 orelse (#3 d) > 31
            then false
            else 
                if (#1 d) mod 4 = 0 
                    andalso ((#1 d) mod 100 <> 0 orelse (#1 d) mod 400 = 0)
                    andalso (#2 d) = 2 
                    andalso (#3 d) = 29
                then true
                else
                    if (#3 d) <= days_in_month(d)
                    then true
                    else false
    in
        valid_year(d) andalso valid_month(d) andalso valid_date(d)
    end

