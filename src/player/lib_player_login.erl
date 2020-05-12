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
    handle_login/3,
    handle_register/3
]).

%% 登录
handle_login(Username, Password, Role) ->
    Sql = "SELECT `id` FROM `user` WHERE `username` = ? AND `password` = ?",
    case db:execute(Sql, [Username,Password]) of
        [[ID]] ->
            {true, Role#player{player_id = ID}};
        false ->
            {false, ?ERR_PASSWORD_INCORRECT}
    end.

%% 注册
handle_register(Username, Password, Role) ->
    %% todo unique_id
    UID = rand:uniform(abs(99999999 - 9999999)) + 9999999,
    Sql = "INSERT INTO `user`(`id`, `username`, `passowrd`) VALUES(?,?,?)",
    case db:execute(Sql, [UID, Username, Password]) of
        AffNum when is_integer(AffNum) andalso AffNum > 0 ->
            {true, Role#player{player_id = UID}};
        _ ->
            {false, ?ERR_USER_HAS_EXISTED}
    end.