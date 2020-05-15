%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% player key-val data module
%%% @end
%%% Created : 08. 5月 2020 17:49
%%%-------------------------------------------------------------------
-module(player_kv).
-author("shiyu").

-behaviour(base_module).

-include("player.hrl").

%% API
-export([
    get/3,
    put/3
]).

-export([
    from_db/1,
    to_db/1
]).

from_db(#player{player_id = PlayerId} = Player) ->
    Sql = "SELECT `k`, `v` FROM `player_kv` WHERE `player_id` = ?",
    DataList = db:execute(Sql, [PlayerId]),
    KvData = lists:foldl(fun([K, V], TmpMap) ->
        K1 = erlang:binary_to_atom(K, utf8),
        V1 = lib_serialize:deserialize(V),
        maps:put(K1, V1, TmpMap) end,
        #{}, DataList),
    Player#player{kv_data = KvData}.

to_db(#player{player_id = PlayerId, kv_data = KvData, change_k_set = ChangeKSet} = _Player) ->
    ChangeKList = sets:to_list(ChangeKSet),
    lists:foreach(fun(K) ->
        V = maps:get(K, KvData),
        Sql = "REPLACE INTO `player_kv`(`player_id`, `k`, `v`) WHERE `player_id` = ? AND `k` = ?",
        K1 = lib_serialize:serialize(K),
        V1 = lib_serialize:serialize(V),
        db:execute(Sql, [PlayerId, K1, V1])
                  end, ChangeKList).

get(K, #player{kv_data = KvData}, Default) ->
    maps:get(K, KvData, Default).

put(K, V, #player{kv_data = KvData, change_k_set = ChangeKSet} = Player) ->
    Player#player{kv_data = KvData#{K => V}, change_k_set = sets:add_element(K, ChangeKSet)}.