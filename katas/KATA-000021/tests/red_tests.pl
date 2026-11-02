% SPDX-License-Identifier: MIT
:- use_module(red_stub).
:- begin_tests(roman_red).
test(subtractive_four) :- red_stub:roman(4, 'IV').
:- end_tests(roman_red).
