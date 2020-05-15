%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 28. 3月 2020 10:25
%%%-------------------------------------------------------------------
%%%-------------------------------------------------------------------
-module(player).

-behaviour(gen_server).
-behaviour(ranch_protocol).

-include("player.hrl").
-include("01_login.hrl").

%% API.
-export([start_link/4]).

%% gen_server.
-export([init/4]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% API.

start_link(Ref, Socket, Transport, Opts) ->
    proc_lib:start_link(?MODULE, init, [Ref, Socket, Transport, Opts]).

%% gen_server.

%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
init([]) -> {ok, undefined}.

init(Ref, Socket, Transport, _Opts = []) ->
    erlang:process_flag(trap_exit, true),
    ok = proc_lib:init_ack({ok, self()}),
    ok = ranch:accept_ack(Ref),
    ok = Transport:setopts(Socket, [binary, {active, once}, {packet, 0}]),
    erlang:send_after(5 * 60 * 1000, self(), {check_verify}),
    gen_server:enter_loop(?MODULE, [], #player{socket = Socket, transport = Transport}, infinity).

handle_info({tcp, Socket, Data}, State = #player{socket = Socket, transport = Transport}) ->
    Transport:setopts(Socket, [{active, once}]),
    ProtoList = try lib_proto:unpack(Data) catch _E1:_E2:_StackTrace -> [] end,
    io:format("ProtoList => ~p ~n", [ProtoList]),
    F = fun({ProtoId, ProtoTuple}, TmpState) ->
        handle_proto(ProtoId, ProtoTuple, TmpState)
        end,
    NewState = lists:foldl(F, State, ProtoList),
    {noreply, NewState};
handle_info({send, {ProtoId, Tuple}}, #player{} = State) when is_tuple(Tuple) ->
    #player{socket = Socket, transport = Transport} = State,
    Transport:send(Socket, lib_proto:pack(ProtoId, Tuple)),
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
    {stop, normal, State};
handle_info({check_verify}, #player{is_verify = false} = Player) ->
    {stop, normal, Player};
handle_info({chkek_verify}, #player{is_verify = true} = Player) ->
    {noreply, Player};
handle_info({tcp_error, _, Reason}, State) ->
    {stop, Reason, State};
handle_info(timeout, State) ->
    {stop, normal, State};
handle_info(_Info, State) ->
    {stop, normal, State}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, Player) ->
    player_init:offline(Player),
    io:format("~n ~p  |||||", [_Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal.
handle_proto(101, ProtoTuple, #player{transport = Transport, socket = Socket} = Player) ->
    Handler = handler_router:route(101),
    {reply, Tuple, NewPlayer} = Handler:handle(101, ProtoTuple, Player),
    Transport:send(Socket, lib_proto:pack(101, Tuple)),
    NewPlayer;
handle_proto(ProtoId, ProtoTuple, #player{is_verify = true, transport = Transport, socket = Socket} = Player) ->
    Handler = handler_router:route(ProtoId),
    try Handler:handle(ProtoId, ProtoTuple, Player) of
        {reply, Tuple} when is_tuple(Tuple) ->
            Transport:send(Socket, lib_proto:pack(ProtoId, Tuple)),
            Player;
        {reply, Tuple, NewPlayer} when is_tuple(Tuple) ->
            Transport:send(Socket, lib_proto:pack(ProtoId, Tuple)),
            NewPlayer;
        {noreply, NewPlayer} ->
            NewPlayer;
        {noreply} ->
            Player;
        Other ->
            io:format("Fail! ProtoID: ~p, Other: ~p", [ProtoId, Other]),
            Player
    catch E1:E2:StackTrace ->
        io:format("Error Msg: ~p ~p ~p", [E1, E2, StackTrace])
    end;
handle_proto(ProtoId, ProtoTuple, Player) ->
    io:format("player is not verified: ~p ~p", [ProtoId, ProtoTuple]),
    Player.