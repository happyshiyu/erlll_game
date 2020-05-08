%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% application中env相关函数的封装
%%% @end
%%% Created : 26. 4月 2020 下午 18:13
%%%-------------------------------------------------------------------
-module(env_util).
-author("shiyu").

%% API
-export([
    get/1,
    get/2
]).

-define(APP_NAME, erlll_game).

get(Key) ->
    get(Key, false).

get(Key, Default) ->
    application:get_env(?APP_NAME, Key, Default).
