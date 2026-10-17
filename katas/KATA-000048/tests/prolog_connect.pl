% SPDX-License-Identifier: MIT
% Relational depth-first Hex path search (not C++ BFS or Python DSU).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- initialization(main, main).
cell(Board,R,C,Value) :-
    nth0(R,Board,Row),string_chars(Row,Chars),nth0(C,Chars,Value).
offset(-1,0). offset(-1,1). offset(0,-1).
offset(0,1). offset(1,-1). offset(1,0).
adjacent(Board,R,C,NR,NC,Piece) :-
    offset(DR,DC),NR is R+DR,NC is C+DC,
    NR>=0,NC>=0,cell(Board,NR,NC,Piece).
goal(Board,'O',R,_) :- length(Board,H),R is H-1.
goal(Board,'X',_,C) :- Board=[Row|_],string_length(Row,W),C is W-1.
reach(Board,Piece,R,C,_) :- goal(Board,Piece,R,C),!.
reach(Board,Piece,R,C,Visited) :-
    adjacent(Board,R,C,NR,NC,Piece),
    \+ memberchk(NR-NC,Visited),
    reach(Board,Piece,NR,NC,[NR-NC|Visited]).
starts(Board,'O',0,C) :-
    Board=[Row|_],string_length(Row,W),
    Max is W-1,between(0,Max,C),cell(Board,0,C,'O').
starts(Board,'X',R,0) :-
    length(Board,H),Max is H-1,
    between(0,Max,R),cell(Board,R,0,'X').
winning(Board,Piece) :-
    starts(Board,Piece,R,C),reach(Board,Piece,R,C,[R-C]),!.
decide(Board,"O") :- winning(Board,'O'),!.
decide(Board,"X") :- winning(Board,'X'),!.
decide(_,".").
main :-
    json_read_dict(user_input,Cases),maplist(decide,Cases,Answers),
    json_write(user_output,Answers),nl.
