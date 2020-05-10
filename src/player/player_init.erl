%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 08. 5月 2020 16:58
%%%-------------------------------------------------------------------
-module(player_init).
-author("shiyu").

-include("err_code.hrl").
-include("player.hrl").

%% API
-export([
    online/1,
    offline/1
]).

-define(ACTIVE_MODULE, [
    lib_player_kv
]).

%% --------------------
%% API
%% --------------------
online(#player{} = Player0) ->
    F = fun(Module, TmpPlayer) ->
        Module:initialize(TmpPlayer)
        end,
    Player1 = lists:foldl(F, Player0, ?ACTIVE_MODULE),
    Player1.

offline(#player{} = Player) ->
    F = fun(Module) ->
        Module:shutdown(Player)
        end,
    lists:foreach(F, ?ACTIVE_MODULE).

%% --------------------
%% private
%% --------------------