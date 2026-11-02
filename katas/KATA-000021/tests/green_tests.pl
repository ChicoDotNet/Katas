% SPDX-License-Identifier: MIT
:- use_module('../src/roman').
:- begin_tests(roman_green).
test(one) :- roman:roman(1, 'I').
test(four) :- roman:roman(4, 'IV').
test(nine) :- roman:roman(9, 'IX').
test(forty_nine) :- roman:roman(49, 'XLIX').
test(ninety) :- roman:roman(90, 'XC').
test(four_hundred) :- roman:roman(400, 'CD').
test(nine_hundred) :- roman:roman(900, 'CM').
test(maximum) :- roman:roman(3999, 'MMMCMXCIX').
test(minimum_rejected, [fail]) :- roman:roman(0, _).
test(maximum_rejected, [fail]) :- roman:roman(4000, _).
test(noncanonical, [forall(member(Text, ['IIII', 'VV', 'IL', 'IC', 'MCMC', 'IIV', 'VX', 'MMMCMXCIXI', '']))]) :-
    \+ roman:roman(_, Text).
test(exhaustive_roundtrip, [forall(between(1, 3999, Number))]) :-
    roman:roman(Number, Text),
    findall(Parsed, roman:roman(Parsed, Text), Parses),
    assertion(Parses == [Number]).
:- end_tests(roman_green).
