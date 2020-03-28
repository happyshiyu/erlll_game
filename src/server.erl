%%%-------------------------------------------------------------------
%%% 启动
%%%-------------------------------------------------------------------
-module(server).
-author("shiyu").

%% API
-export([start/0]).

-define(APPS, [inets, erlll_game]).

%% ==============================
%% 启动应用
%% ==============================
start() ->
    [start(App) || App <- ?APPS].

start(App) ->
    start_ok(App, application:start(App, permanent)).

start_ok(_App, ok) -> ok;
start_ok(_App, {error, {already_started, _App}}) -> ok;
start_ok(App, {error, {not_started, Dep}}) ->
    ok = start(Dep),
    start(App);
start_ok(App, {error, Reason}) ->
    erlang:error({app_start_failed, App, Reason}).
