%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% 登录处理器
%%% @end
%%% Created : 05. 4月 2020 下午 23:16
%%%-------------------------------------------------------------------
-module(login_handler).
-author("shiyu").

-include("01_login.hrl").

%% API
-export([
    handle/3
]).

handle(_ProtoId, Tuple, State) ->
    do_handle(Tuple, State).

do_handle(#pt_1001_c{user_id = UserId}, _State) ->
    case lib_game_login:handle_login(UserId) of
        true ->
            {reply, #pt_1001_s{result = 0}};
        false ->
            {reply, #pt_1001_s{result = 1}}
    end.