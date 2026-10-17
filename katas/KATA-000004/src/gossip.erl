%% SPDX-License-Identifier: MIT
%% Original functional, synchronous information-propagation simulation.
-module(gossip).
-export([solve/1, solve/2]).

-type stop_id() :: non_neg_integer().
-type answer() :: pos_integer() | never.
-spec solve([[stop_id()]]) -> answer().
solve(Routes) -> solve(Routes, 480).

-spec solve([[stop_id()]], pos_integer()) -> answer().
solve(Routes, MaxStops)
  when is_list(Routes), is_integer(MaxStops), MaxStops >= 1 ->
    validate(Routes),
    N = length(Routes),
    Initial = [1 bsl Id || Id <- lists:seq(0, N - 1)],
    visit(0, Routes, Initial, (1 bsl N) - 1, MaxStops);
solve(_, _) -> erlang:error(badarg).

validate(Routes) ->
    N = length(Routes),
    ValidRoutes = lists:all(
        fun(Route) ->
            is_list(Route) andalso Route =/= [] andalso length(Route) =< 64 andalso
            lists:all(fun(Stop) -> is_integer(Stop) andalso Stop >= 0 end, Route)
        end, Routes),
    case N >= 1 andalso N =< 16 andalso ValidRoutes of
        true -> ok;
        false -> erlang:error(badarg)
    end.

%% Index zero refers to the initial encounter, which counts as stop visit one.
%% Masks are read from the previous round before any mask is replaced.
visit(Index, _Routes, _Masks, _All, Limit) when Index >= Limit -> never;
visit(Index, Routes, Masks, All, Limit) ->
    Stops = [lists:nth((Index rem length(Route)) + 1, Route) || Route <- Routes],
    SharedByStop = lists:foldl(
        fun({Stop, Mask}, Seen) ->
            maps:update_with(Stop, fun(Previous) -> Previous bor Mask end, Mask, Seen)
        end, #{}, lists:zip(Stops, Masks)),
    Updated = [maps:get(Stop, SharedByStop) || Stop <- Stops],
    case lists:all(fun(Mask) -> Mask =:= All end, Updated) of
        true -> Index + 1;
        false -> visit(Index + 1, Routes, Updated, All, Limit)
    end.
