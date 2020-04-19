%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% 协议打包、解包
%%% @end
%%% Created : 05. 4月 2020 上午 11:17
%%%-------------------------------------------------------------------
-module(lib_proto).
-author("shiyu").

%% API
-export([
    unpack/1,
    pack/2,
    client_unpack/2
]).

%%-----------------------------------
%% 获得编/解码模块
%%-----------------------------------
get_edecoder(ProtoId) ->
    ProtoType = ProtoId div 1000,
    case ProtoType of
        1 -> '01_login';
        _ -> false
    end.

%%-----------------------------------
%% 解包
%%-----------------------------------
unpack(BinData) ->
    lists:reverse(unpack(BinData, [])).

unpack(Data, UnPackList) ->
    <<Length:32/unsigned, ProtoId:16/unsigned, Bin/binary>> = Data,
    ProtoHeadLen = erlang:size(Data) - erlang:size(Bin),
    BodyLen = Length - ProtoHeadLen,
    {UnpackBin, LeftBin} = erlang:split_binary(Bin, BodyLen),
    ProtoName = erlang:list_to_atom("pt_" ++ erlang:integer_to_list(ProtoId) ++ "_c"),
    Decoder = get_edecoder(ProtoId),
    NewUnPackList = [{ProtoId, Decoder:decode_msg(UnpackBin, ProtoName)} | UnPackList],
    case erlang:size(LeftBin) >= 6 of
        true -> unpack(LeftBin, NewUnPackList);
        false -> NewUnPackList
    end.

%%-----------------------------------
%% 打包
%%-----------------------------------
pack(ProtoId, Tuple) when is_tuple(Tuple) ->
    Encoder = get_edecoder(ProtoId),
    Bin = Encoder:encode_msg(Tuple),
    Length = erlang:size(Bin) + 6,
    <<Length:32/unsigned, ProtoId:16/unsigned, Bin/binary>>.

%% -----------------------------------
%% 客户端测试专用  for test client
%% -----------------------------------
client_unpack(Data, UnPackList) ->
    <<Length:32/unsigned, ProtoId:16/unsigned, Bin/binary>> = Data,
    ProtoHeadLen = size(Data) - size(Bin),
    BodyLen = Length - ProtoHeadLen,
    {UnpackBin, LeftBin} = erlang:split_binary(Bin, BodyLen),
    ProtoType = ProtoId div 1000,
    ProtoName = erlang:list_to_atom("pt_" ++ erlang:integer_to_list(ProtoId) ++ "_s"),
    NewUnPackList = case ProtoType of
                        1 -> ['01_login':decode_msg(UnpackBin, ProtoName) | UnPackList];
                        _ -> false
                    end,
    case erlang:size(LeftBin) >= 6 of
        true -> unpack(LeftBin, NewUnPackList);
        false -> NewUnPackList
    end.