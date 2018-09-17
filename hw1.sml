(*  Assignment #1 *)

type DATE = (int * int * int)
exception InvalidParameter

(* #1 *)
(* Write a function is_older that takes two dates and evaluates to true or false. It evaluates to true if
the first argument is a date that comes before the second argument. (If the two dates are the same, the
result is false.) *)
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
(* Write a function number_in_month that takes a list of dates and a month (i.e., an int) and returns
how many dates in the list are in the given month *)
fun number_in_month(dl: DATE list, m: int): int =
    if null dl
    then 0
    else
        if (#2 (hd dl)) = m
        then number_in_month(tl dl, m) + 1
        else number_in_month(tl dl, m)

(* #3 *)
(* Write a function
number_in_months
that takes a list of dates and a list of months (i.e., an
int
list
) and returns the number of dates in the list of dates that are in any of the months in the list of
months.  Assume the list of months has no number repeated.  Hint:  Use your answer to the previous
problem. *)
fun number_in_months(dl: DATE list, ml: int list): int = 
    if null ml
    then 0
    else number_in_month(dl, hd ml) + number_in_months(dl, tl ml)

(* #4 *)
(* Write a function
dates_in_month
that takes a list of dates and a month (i.e., an int) and returns a
list holding the dates from the argument list of dates that are in the month.  The returned list should
contain dates in the order they were originally given. *)
fun dates_in_month(dl: DATE list, m: int): DATE list =
    if null dl
    then []
    else
        if (#2 (hd dl)) = m
        then (hd dl)::dates_in_month(tl dl, m)
        else dates_in_month(tl dl, m)

(* #5 *)
(* Write a function
dates_in_months
that takes a list of dates and a list of months (i.e., an int list ) 
and returns a list holding the dates from the argument list of dates that are in any of the months
in the list of months.  Assume the list of months has no number repeated.  Hint:  Use your answer to
the previous problem and ML’s list-append operator (@). *)
fun dates_in_months(dl: DATE list, il: int list): DATE list = 
    if null il
    then []
    else dates_in_month(dl, hd il) @ dates_in_months(dl, tl il)

(* #6 *)
(* Write a function
get_nth that takes a list of strings and an int n and returns the n-th element of
the list where the head of the list is 1st .  Raise the exception
InvalidParameter if n is zero or larger than the length of the list. *)
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
(* Write  a  function date_to_string that  takes  a  date  and  returns  a  string  of  the  form January 20, 2013 (for  example).  
 Use  the  operator ˆ for  concatenating  strings  and  the  library  function Int.toString for converting an int to a string . 
  For producing the month part, do not use a bunch of conditionals.  Instead, use a list holding 12 strings and your answer 
  to the previous problem.   For  consistency,  put  a  comma  following  the  day  and  use  capitalized  English  month  names:
January, February, March, April, May, June, July, August, September, October, November, December
. *)
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
(* Write a function number_before_reaching_sum that takes an int called sum , 
which you can assume is positive,  and an int list ,  which you can assume
 contains all positive numbers,  and returns an int .  You should return an int
n such that the first n elements of the list add to less than sum, but the
 first n + 1 elements of the list add to sum or more.  Assume the entire list sums to more
than the passed in value; it is okay for an exception to occur if this is not the case. *)
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
(* Write a function what_month that takes a day of year (i.e., an int between 1 
and 365) and returns what month that day is in (1 for January, 2 for February, 
etc.). Use a list holding 12 integers and your answer to the previous problem *)
fun what_month(d: int): int = 
    let
        val days_of_months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    in
        number_before_reaching_sum(d, days_of_months)+1
    end

(* #10 *)
(* Write a function month_range that takes two days of the year day1 and day2 
and returns an int list [m1,m2,...,mn] where m1 is the month of day1 , m2 is 
the month of day1+1 , ..., and mn is the month of day day2. Note the result 
will have length day 2 − day 1 + 1 or length 0 if day 1 > day 2 . *)
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
(* Write a function oldest that takes a list of dates and evaluates to a DATE 
option.  It evaluates to NONE if the list has no dates and SOME d if the date d is the oldest date in the list. *)
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
(* Write a function
reasonable_date
that takes a date and determines if it describes a real date in
the common era.  A “real date” has a positive year (year 0 did not exist), a month between 1 and 12,
and a day appropriate for the month.  Solutions should properly handle leap years.  Leap years are
years that are either divisible by 400 or divisible by 4 but not divisible by 100.  (Do not worry about
days possibly lost in the conversion to the Gregorian calendar in the Late 1500s.) *)
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

