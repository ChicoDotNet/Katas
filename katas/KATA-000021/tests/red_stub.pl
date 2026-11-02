% SPDX-License-Identifier: MIT
:- module(red_stub, [roman/2]).
roman(Number, 'I') :- integer(Number), between(1, 3999, Number).
