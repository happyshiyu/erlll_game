%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 08. 5月 2020 17:49
%%%-------------------------------------------------------------------
-module(lib_player_kv).
-author("shiyu").

-include("player.hrl").

%% API
-export([
    get/3,
    put/3
]).

-export([
    initialize/1,
    shutdown/1
]).

initialize(#player{player_id = PlayerId} = Player) ->
    Sql = "SELECT `k`, `v` FROM `player_kv` WHERE `player_id` = ?",
    DataList = db:execute(Sql, [PlayerId]),
    lists:foreach(fun([K, V]) ->
        cache:put(?MODULE, K, V, PlayerId)
                  end, DataList),
    Player.

shutdown(#player{player_id = PlayerId} = _Player) ->
    KVList = cache:get_all(?MODULE, PlayerId),
    do_shutdown(KVList, PlayerId).

get(K, PlayerId, Default) ->
    cache:get(?MODULE, K, PlayerId, Default).

put(K, V, PlayerId) ->
    cache:put(?MODULE, K, V, PlayerId).

%% private
do_shutdown([], _) -> ok;
do_shutdown([K, V | L], Id) ->
    Sql = "REPLACE INTO `player_kv`(`player_id`, `k`, `v`) WHERE `player_id` = ? AND `k` = ?",
    db:execute(Sql, [Id, K, V]),
    do_shutdown(L, Id).