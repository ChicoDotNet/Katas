%% SPDX-License-Identifier: MIT
%% Self-contained behavioral tests: no downloaded third-party test library.
-module(gossip_tests).
-export([run/0]).

assert(Expected, Actual, Name) ->
    case Expected =:= Actual of
        true -> ok;
        false -> erlang:error({assertion_failed, Name, Expected, Actual})
    end.

badarg(Fun, Name) ->
    try Fun() of
        _ -> erlang:error({assertion_failed, Name, expected_badarg})
    catch
        error:badarg -> ok
    end.

run() ->
    assert(5, gossip:solve([[3,1,2,3], [3,2,3,1], [4,2,3,4,5]]),
           source_example_one),
    assert(never, gossip:solve([[2,1,2], [5,2,8]]),
           source_example_two),
    assert(1, gossip:solve([[7,8]]), single_driver_knows_own_gossip),
    assert(1, gossip:solve([[3], [3], [3]]), exchange_at_initial_stop),
    assert(never, gossip:solve([[1], [2]]), isolated_routes),
    assert(3, gossip:solve([[1,2], [1,3], [4,3]]),
           no_instant_global_transitivity),
    assert(2, gossip:solve([[1,2], [3,2]]), reunion_on_second_visit),
    assert(never, gossip:solve([[1,2], [3,2]], 1),
           capped_before_first_reunion),
    assert(2, gossip:solve([[1,2], [3,2]], 2),
           exactly_at_last_allowed_visit),
    badarg(fun() -> gossip:solve([]) end, empty_driver_list),
    badarg(fun() -> gossip:solve([[1], []]) end, empty_route),
    badarg(fun() -> gossip:solve([[1], [-1]]) end, negative_stop),
    badarg(fun() -> gossip:solve([[1]], 0) end, zero_limit),
    io:format("PASS: 13 Erlang behavior, boundary and validation assertions~n"),
    ok.
