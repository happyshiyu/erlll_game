%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% 根据协议号映射到对应的handler
%%% @end
%%% Created : 05. 4月 2020 下午 22:56
%%%-------------------------------------------------------------------
-module(handler_router).
-author("shiyu").

%% API
-export([route/1]).

route(ProtoId) ->
    ProtoType = ProtoId div 100,
    case ProtoType of
        1 -> login_handler;
        2 -> base_handler;
        _ -> false
    end.
