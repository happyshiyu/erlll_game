%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% player base data module
%%% @end
%%% Created : 08. 5月 2020 17:49
%%%-------------------------------------------------------------------
-module(player_base).
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
    Sql = "SELECT `name`, `lev` FROM `player_base` WHERE `player_id` = ?",
    DataList = db:execute(Sql, [PlayerId]),
    BaseData = #{
        name => lib_serialize:deserialize(lists:nth(1, DataList)),
        lev => lib_serialize:deserialize(lists:nth(2, DataList))
    },
    Player#player{base_data = BaseData}.

to_db(#player{player_id = PlayerId, base_data = BaseData} = _Player) ->
    Sql = "UPDATE `player_base` SET `name` = ?, `lev` = ? WHERE `player_id` = ?",
    Name = maps:get(name, BaseData),
    Lev = maps:get(lev, BaseData),
    db:execute(Sql, [Name, Lev, PlayerId]).

get(K, #player{base_data = BaseData}, Default) ->
    maps:get(K, BaseData, Default).

put(K, V, #player{base_data = BaseData} = Player) ->
    Player#player{base_data = BaseData#{K => V}}.
