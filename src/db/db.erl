%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 12. 4月 2020 下午 22:03
%%%-------------------------------------------------------------------
-module(db).
-author("shiyu").

%% API
-export([
    execute/1,
    execute/2
]).


execute(Sql) ->
    case poolboy:transaction(?MODULE, fun(Worker) -> gen_server:call(Worker, {execute, Sql}) end) of
        {ok, _, Ret} -> Ret;
        _ -> false
    end.

execute(Sql, Params) ->
    case poolboy:transaction(?MODULE, fun(Worker) -> gen_server:call(Worker, {execute, Sql, Params}) end) of
        {ok, _, Ret} -> Ret;
        _ -> false
    end.