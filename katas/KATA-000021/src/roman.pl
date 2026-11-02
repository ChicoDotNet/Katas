% SPDX-License-Identifier: MIT
% Canonical Roman numerals, 1..3999. Original DCG, no imported starter.
:- module(roman, [roman/2]).

% The public relation supports generation from an integer and parsing an atom.
% The four decimal-place grammars rule out noncanonical subtractive spellings.
roman(Number, Atom) :-
    integer(Number), !,
    between(1, 3999, Number),
    Thousands is Number // 1000,
    Hundreds is (Number // 100) mod 10,
    Tens is (Number // 10) mod 10,
    Ones is Number mod 10,
    phrase(numeral(Thousands, Hundreds, Tens, Ones), Codes),
    atom_codes(Atom, Codes).
roman(Number, Atom) :-
    var(Number), atom(Atom),
    atom_codes(Atom, Codes),
    phrase(numeral(Thousands, Hundreds, Tens, Ones), Codes),
    Number is Thousands * 1000 + Hundreds * 100 + Tens * 10 + Ones,
    between(1, 3999, Number).

numeral(Thousands, Hundreds, Tens, Ones) -->
    thousands(Thousands), hundreds(Hundreds), tens(Tens), ones(Ones).

thousands(0) --> [].
thousands(1) --> "M".
thousands(2) --> "MM".
thousands(3) --> "MMM".

hundreds(0) --> [].
hundreds(1) --> "C".
hundreds(2) --> "CC".
hundreds(3) --> "CCC".
hundreds(4) --> "CD".
hundreds(5) --> "D".
hundreds(6) --> "DC".
hundreds(7) --> "DCC".
hundreds(8) --> "DCCC".
hundreds(9) --> "CM".

tens(0) --> [].
tens(1) --> "X".
tens(2) --> "XX".
tens(3) --> "XXX".
tens(4) --> "XL".
tens(5) --> "L".
tens(6) --> "LX".
tens(7) --> "LXX".
tens(8) --> "LXXX".
tens(9) --> "XC".

ones(0) --> [].
ones(1) --> "I".
ones(2) --> "II".
ones(3) --> "III".
ones(4) --> "IV".
ones(5) --> "V".
ones(6) --> "VI".
ones(7) --> "VII".
ones(8) --> "VIII".
ones(9) --> "IX".
