%% SPDX-License-Identifier: MIT
%% One independently specified scenario per input line:
%% stop,stop|stop|stop,stop,...; output one integer or "never" per line.
-module(gossip_cli).
-export([main/0]).

main() -> loop().

loop() ->
    case io:get_line("") of
        eof -> ok;
        Line ->
            try
                Routes = [[list_to_integer(Token) || Token <- string:split(Route, ",", all)]
                          || Route <- string:split(string:trim(Line), "|", all)],
                case gossip:solve(Routes) of
                    never -> io:format("never~n");
                    Visits -> io:format("~B~n", [Visits])
                end
            catch
                _:_ -> io:format("ERROR~n")
            end,
            loop()
    end.
