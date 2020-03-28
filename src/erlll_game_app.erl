%%%-------------------------------------------------------------------
%% @doc erlll_game public API
%% @end
%%%-------------------------------------------------------------------

-module(erlll_game_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("666"),
    A = jsx:encode([{<<"a">>, 2}]),
    io:format("~p", [A]),
    erlll_game_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
