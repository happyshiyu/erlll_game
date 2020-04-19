%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020, junhai
%%% @doc
%%%
%%% @end
%%% Created : 12. 4月 2020 下午 22:03
%%%-------------------------------------------------------------------
-module(mysql_pool).
-author("shiyu").

%% API
-export([
    query/1,
    query/2
]).


query(Sql) ->
    case poolboy:transaction(?MODULE, fun(Worker) -> gen_server:call(Worker, {query, Sql}) end) of
        {ok, _, Ret} -> Ret;
        _ -> false
    end.

query(Sql, Params) ->
    case poolboy:transaction(?MODULE, fun(Worker) -> gen_server:call(Worker, {query, Sql, Params}) end) of
        {ok, _, Ret} -> Ret;
        _ -> false
    end.