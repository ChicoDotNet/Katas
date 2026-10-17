% SPDX-License-Identifier: MIT
% Eulerian feasibility by degree parity and undirected connected components.
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- initialization(main, main).
endpoints(Tiles,Vertices) :-
    findall(V,(member(T,Tiles),(V=T.a;V=T.b)),Raw),sort(Raw,Vertices).
degree(Tiles,V,D) :-
    findall(N,(member(T,Tiles),A=T.a,B=T.b,
      (A=:=V,B=:=V -> N=2; A=:=V -> N=1; B=:=V -> N=1; fail)),Count),
    sum_list(Count,D).
neighbor(Tiles,V,Next) :-
    member(T,Tiles),A=T.a,B=T.b,
    (A=:=V,Next=B;B=:=V,Next=A).
flood([],_,Seen,Seen).
flood([V|Queue],Tiles,Seen,Found) :-
    (memberchk(V,Seen) -> flood(Queue,Tiles,Seen,Found)
    ;findall(N,neighbor(Tiles,V,N),Neighbors),
     append(Queue,Neighbors,Q1),
     flood(Q1,Tiles,[V|Seen],Found)).
can_close([]).
can_close(Tiles) :-
    endpoints(Tiles,Vertices),
    Vertices=[First|_],
    forall(member(V,Vertices),(degree(Tiles,V,D),0 is D mod 2)),
    flood([First],Tiles,[],Reached),
    forall(member(V,Vertices),memberchk(V,Reached)).
to_json(Tiles,@(true)) :- can_close(Tiles),!.
to_json(_, @(false)).
main :-
    json_read_dict(user_input,Cases),maplist(to_json,Cases,Answers),
    json_write(user_output,Answers),nl.
