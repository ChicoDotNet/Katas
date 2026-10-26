:- begin_tests(zebra).
:- use_module('../src/zebra').

test(unique_complete_assignment) :-
    findall(Layout, zebra:layout(Layout), Layouts),
    assertion(length(Layouts, 1)).

test(water_resident) :-
    findall(W, zebra:solution(W, _), Residents),
    assertion(Residents == [norwegian]).

test(zebra_owner) :-
    findall(Z, zebra:solution(_, Z), Owners),
    assertion(Owners == [japanese]).

test(distinct_house_positions) :-
    zebra:layout(houses(Colors, Nations, Drinks, Pets, Hobbies)),
    forall(member(Group, [Colors, Nations, Drinks, Pets, Hobbies]),
           (sort(Group, Sorted), assertion(Sorted == [1,2,3,4,5]))).

:- end_tests(zebra).
