%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020, junhai
%%% @doc
%%%
%%% @end
%%% Created : 12. 4月 2020 下午 22:03
%%%-------------------------------------------------------------------
-module(redis_pool).
-author("shiyu").

%% API
-export([
    q/1
]).

q(Command) ->
    poolboy:transaction(?MODULE, fun(Worker) ->
        gen_server:call(Worker, {q, Command})
                                 end).