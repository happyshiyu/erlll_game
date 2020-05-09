%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 12. 4月 2020 下午 22:03
%%%-------------------------------------------------------------------
-module(cache).
-author("shiyu").

%% API
-export([
    put/4,
    get/4,
    get_all_key/2,
    get_all/2
]).

q(Command) ->
    poolboy:transaction(?MODULE, fun(Worker) -> gen_server:call(Worker, {q, Command}) end).


put(Module, K, V, PlayerId) ->
    MergeKey = merge_key(PlayerId, Module),
    q(["HSET", MergeKey, lib_serialize:serialize(K), lib_serialize:serialize(V)]).

get(Module, K, PlayerId, Default) ->
    MergeKey = merge_key(PlayerId, Module),
    case q(["HGET", MergeKey, lib_serialize:serialize(K)]) of
        <<>> ->
            Default;
        Data when is_binary(Data) ->
            lib_serialize:deserialize(Data);
        _ ->
            Default
    end.

get_all_key(Module, PlayerId) ->
    MergeKey = merge_key(PlayerId, Module),
    q(["HKEYS", MergeKey]).

get_all(Module, PlayerId) ->
    MergeKey = merge_key(PlayerId, Module),
    q(["HGETALL", MergeKey]).

merge_key(PlayerId, Module) ->
    list_to_binary(integer_to_list(PlayerId) ++ ":" ++ atom_to_list(Module)).