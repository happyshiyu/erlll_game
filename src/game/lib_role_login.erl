%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% 游戏的登录模块
%%% @end
%%% Created : 05. 4月 2020 下午 23:19
%%%-------------------------------------------------------------------
-module(lib_role_login).
-author("shiyu").
-include("role.hrl").
-include("err_code.hrl").

%% API
-export([
    handle_login/3,
    handle_register/3
]).

%% 登录
handle_login(Username, Password, Role) ->
    Sql = "SELECT `id` FROM `user` WHERE `username` = ? AND `password` = ?",
    case mysql_pool:execute(Sql, [Username,Password]) of
        [[ID]] ->
            {true, Role#role{role_id = ID}};
        false ->
            {false, ?ERR_PASSWORD_INCORRECT}
    end.

%% 注册
handle_register(Username, Password, Role) ->
    %% todo unique_id
    UID = rand:uniform(abs(99999999 - 9999999)) + 9999999,
    Sql = "INSERT INTO `user`(`id`, `username`, `passowrd`) VALUES(?,?,?)",
    case mysql_pool:execute(Sql, [UID, Username, Password]) of
        AffNum when is_integer(AffNum) andalso AffNum > 0 ->
            {true, Role#role{role_id = UID}};
        _ ->
            {false, ?ERR_USER_HAS_EXISTED}
    end.