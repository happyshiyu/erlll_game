%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% 序列化工具类
%%% @end
%%% Created : 06. 5月 2020 14:59
%%%-------------------------------------------------------------------
-module(lib_serialize).
-author("shiyu").

%% API
-export([
    serialize/1,
    deserialize/1

]).

-spec serialize(Term :: term()) -> binary().
serialize(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).

-spec deserialize(Binary :: binary()) -> term() | undefined | {error, tuple()}.
deserialize(<<>>) -> undefined;
deserialize(Binary) when is_binary(Binary)->
    case do_deserialize(Binary) of
        {ok, Term} ->
            Term;
        {error, ErrorInfo} ->
            {error, ErrorInfo}
    end;
deserialize(_) -> undefined.

do_deserialize(Binary) ->
    case erl_scan:string(erlang:binary_to_list(Binary) ++ ".") of
        {ok, Tokens, _} ->
            erl_parse:parse_term(Tokens);
        {error, ErrorInfo, _} ->
            {error, ErrorInfo}
    end.