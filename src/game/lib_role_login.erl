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
-include("ret_code.hrl").

%% API
-export([
    handle_login/3
]).

%% 登录
handle_login(Username, Password, Role) ->
    Sql = "SELECT `id` FROM `user` WHERE `username` = ? AND `password` = ?",
    case mysql_pool:query(Sql, [Username,Password]) of
        [[ID]] ->
            {true, Role#role{role_id = ID}};
        false ->
            {false, ?RET_PASSWORD_INCORRECT}
    end.
