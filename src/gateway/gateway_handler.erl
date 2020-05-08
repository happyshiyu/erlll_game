%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 26. 4月 2020 下午 16:24
%%%-------------------------------------------------------------------
-module(gateway_handler).

-include("ret_code.hrl").
-include("gateway.hrl").

-export([init/2]).

init(Req0, State) ->
    {ok, Body, _} = cowboy_req:read_body(Req0),
    Body1 = case Body =:= <<>> of true -> <<"{}">>; false -> Body end,
    JsonData = try jsx:decode(Body1)  catch  _:_:_ -> [] end,
    Tag = proplists:get_value(tag, JsonData, false),
    RetData = handle(Tag, JsonData),
    Resp = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, RetData, Req0),
    {ok, Resp, State}.

handle(login, JsonData) ->
    Username = proplists:get_value(<<"username">>, JsonData, <<>>),
    Password = proplists:get_value(<<"password">>, JsonData, <<>>),
    SqlData = [Username, Password],
    [[Count]] = db:execute("SELECT count(*) FROM `user` WHERE `username` = ? AND `password` = ?", [SqlData]),
    case Count =:= 1 of
        true ->
            Token = gateway_server:create_token(Username),
            jsx:encode([
                {<<"ret">>, ?RET_SUCCESS},
                {<<"token">>, Token}
            ]);
        false ->
            jsx:encode([
                {<<"ret">>, ?RET_USER_OR_PASS_INCORRECT}
            ])
    end;

handle(server_list, JsonData) ->
    ServerList = ets:tab2list(game_server),
    Token = proplists:get_value(<<"token">>, JsonData, <<>>),
    case ets:lookup(gateway_token, Token) of
        [] ->
            jsx:encode([
                {<<"ret">>, ?RET_TOKEN_INVALID}
            ]);
        [#gateway_token{}] ->
            RetList = lists:map(fun(#game_server_info{} = Server) ->
                [
                    {<<"server_id">>, Server#game_server_info.server_id},
                    {<<"server_name">>, Server#game_server_info.name},
                    {<<"status">>, Server#game_server_info.status},
                    {<<"ip">>, Server#game_server_info.ip},
                    {<<"port">>, Server#game_server_info.port}
                ]
                                end, ServerList),
            jsx:encode([
                {<<"ret">>, ?RET_SUCCESS},
                {<<"server_list">>, RetList}
            ])
    end;

handle(_, _) -> <<"{}">>.

