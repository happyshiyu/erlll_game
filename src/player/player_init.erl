%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% player init module
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
    player_base,
    player_kv
]).

%% --------------------
%% API
%% --------------------
-spec(online(#player{}) -> #player{}).
online(#player{} = Player0) ->
    F = fun(Module, TmpPlayer) ->
        Module:from_db(TmpPlayer)
        end,
    Player1 = lists:foldl(F, Player0, ?ACTIVE_MODULE),
    Player1.

-spec(offline(#player{}) -> term()).
offline(#player{} = Player) ->
    F = fun(Module) ->
        Module:to_db(Player)
        end,
    lists:foreach(F, ?ACTIVE_MODULE).

%% --------------------
%% private
%% --------------------