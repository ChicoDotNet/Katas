% SPDX-License-Identifier: MIT
:- use_module(roman).
:- use_module(library(readutil)).
:- initialization(main, main).

main :-
    read_line_to_string(user_input, Line),
    ( Line == end_of_file -> true
    ; process(Line), main
    ).

process(Line) :-
    ( canonical_decimal(Line, Number), roman(Number, Roman) ->
        format('~w~n', [Roman])
    ; writeln('ERR')
    ).

canonical_decimal(Line, Number) :-
    string_codes(Line, [First | Tail]),
    First >= 0'1, First =< 0'9,
    maplist(ascii_digit, Tail),
    number_string(Number, Line),
    integer(Number), between(1, 3999, Number).

ascii_digit(Code) :- Code >= 0'0, Code =< 0'9.
