%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% player base data module
%%% @end
%%% Created : 05. 4月 2020 下午 23:19
%%%-------------------------------------------------------------------
-module(lib_player_login).
-author("shiyu").
-include("player.hrl").
-include("err_code.hrl").

%% API
-export([
    handle_login/2,
    handle_create_role/2
]).

handle_login(PlayerId, #player{} = Player) ->
    Sql = "SELECT COUNT(1) FROM `player` WHERE `id` = ?",
    case db:execute(Sql, [PlayerId]) of
        [[ID]] ->
            {true, Player#player{player_id = ID}};
        false ->
            {false, ?ERR_NOT_CREATED_PLAYER}
    end.

handle_create_role(Name, Player) ->
    UID = global_id_manger:create_id(),
    Sql = "INSERT INTO `player`(`id`, `name`, `lev`) VALUES(?,?,?)",
    case db:execute(Sql, [UID, Name, 0]) of
        AffNum when is_integer(AffNum) andalso AffNum > 0 ->
            {true, Player#player{player_id = UID}};
        _ ->
            {false, ?ERR_ALREADY_HAVE_PLAYER}
    end.