%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 28. 3月 2020 10:25
%%%-------------------------------------------------------------------
%%%-------------------------------------------------------------------
-module(client_protocol).

-behaviour(gen_server).
-behaviour(ranch_protocol).

-include("01_login.hrl").

%% API.
-export([start_link/4]).

%% gen_server.
-export([init/4]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
    socket,
    transport,
    user_id = 0
}).

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
    ok = Transport:setopts(Socket, [{active, once}]),
    gen_server:enter_loop(?MODULE, [], #state{socket = Socket, transport = Transport}, infinity).

handle_info({tcp, Socket, Data}, State = #state{socket = Socket, transport = Transport}) ->
    Transport:setopts(Socket, [{active, once}]),
    ProtoList = lib_proto:unpack(Data),
    io:format("ProtoList => ~p ~n", [ProtoList]),
    F = fun({ProtoId, ProtoTuple}, TmpState) ->
        Handler = handler_router:route(ProtoId),
        case Handler:handle(ProtoId, ProtoTuple, TmpState) of
            {reply, Tuple} when is_tuple(Tuple) ->
                Transport:send(Socket, lib_proto:pack(ProtoId, Tuple)),
                TmpState;
            {reply, Tuple, TmpNewState} when is_tuple(Tuple) ->
                Transport:send(Socket, lib_proto:pack(ProtoId, Tuple)),
                TmpNewState;
            {noreply, TmpNewState} ->
                TmpNewState;
            {noreply} ->
                TmpState;
            _Other ->
                io:format("_Other => ~p", [_Other]),
                TmpState
        end
        end,
    NewState = lists:foldl(F, State, ProtoList),
    {noreply, NewState};
handle_info({send, {ProtoId, Tuple}}, #state{} = State) when is_tuple(Tuple) ->
    #state{socket = Socket, transport = Transport} = State,
    Transport:send(Socket, lib_proto:pack(ProtoId, Tuple)),
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
    {stop, normal, State};
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

terminate(_Reason, _State) ->
    io:format("~n ~p  |||||", [_Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal.