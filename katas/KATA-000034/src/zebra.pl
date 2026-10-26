:- module(zebra, [solution/2, layout/1]).
:- use_module(library(clpfd)).
% Each variable is the 1-based position of a property.
layout(houses(Colors, Nations, Drinks, Pets, Hobbies)) :-
    Colors = [Red, Green, Ivory, Yellow, Blue],
    Nations = [English, Spanish, Ukrainian, Norwegian, Japanese],
    Drinks = [Coffee, Tea, Milk, Orange, Water],
    Pets = [Dog, Snails, Fox, Horse, Zebra],
    Hobbies = [Dancing, Painting, Reading, Football, Chess],
    append([Colors, Nations, Drinks, Pets, Hobbies], Vars),
    Vars ins 1..5,
    maplist(all_distinct, [Colors, Nations, Drinks, Pets, Hobbies]),
    English #= Red,
    Spanish #= Dog,
    Green #= Coffee,
    Ukrainian #= Tea,
    Green #= Ivory + 1,
    Snails #= Dancing,
    Yellow #= Painting,
    Milk #= 3,
    Norwegian #= 1,
    abs(Reading - Fox) #= 1,
    abs(Painting - Horse) #= 1,
    Football #= Orange,
    Japanese #= Chess,
    abs(Norwegian - Blue) #= 1,
    labeling([ffc], Vars),
    integer(Water), integer(Zebra).

resident_at(Position, [English, Spanish, Ukrainian, Norwegian, Japanese], Name) :-
    nth1(Index, [English, Spanish, Ukrainian, Norwegian, Japanese], Position),
    nth1(Index, [englishman, spaniard, ukrainian, norwegian, japanese], Name).

solution(WaterResident, ZebraOwner) :-
    layout(houses(_, Nations, [_, _, _, _, Water], [_, _, _, _, Zebra], _)),
    resident_at(Water, Nations, WaterResident),
    resident_at(Zebra, Nations, ZebraOwner).
