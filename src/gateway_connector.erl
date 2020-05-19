%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020,
%%% @doc
%%%
%%% @end
%%% Created : 08. 5月 2020 11:42
%%%-------------------------------------------------------------------
-module(gateway_connector).
-author("shiyu").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {pid}).

%%%===================================================================
%%% API
%%%===================================================================
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    erlang:send_after(5 * 1000, self(), connect_gateway),
    {ok, #state{}}.


-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
    {reply, ok, State}.


-spec(handle_cast(Request :: term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
    {noreply, State}.


-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_info(connect_gateway, State) ->
    Pid = case connect_gateway() of
        {ok, RetPid} ->
            io:format("Connect Gateway Pid => ~p", [RetPid]),
            RetPid;
        _ ->
            io:format("Connect Gateway Fail"),
            retry_connect_gateway(),
            undefined
    end,
    {noreply, State#state{pid = Pid}};
handle_info({nodedown, _Node}, State) ->
    io:format("Gateway Down!!!"),
    retry_connect_gateway(),
    {noreply, State#state{pid = undefined}};
handle_info(_Info, State) ->
    {noreply, State}.


-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
    ok.


-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
    {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
connect_gateway() ->
    GatewayNode = env_util:get(gateway_node),
    case net_kernel:connect_node(GatewayNode) of
        true ->
            erlang:monitor_node(GatewayNode, true),
            ServerId = env_util:get(server_id),
            IP = env_util:get(ip),
            Port = env_util:get(port),
            Name = env_util:get(server_name),
            case catch rpc:call(GatewayNode, game_server_manager, register, [node(), self(), ServerId, Name, IP, Port]) of
                {ok, Pid} ->
                    {ok, Pid};
                _Error ->
                    undefined
            end;
        _Error ->
            undefined
    end.

retry_connect_gateway() ->
    OldRef = erlang:get(reconnect_timer),
    case is_reference(OldRef) of
        false -> ok;
        true -> erlang:cancel_timer(OldRef)
    end,
    Ref = erlang:send_after(60 * 1000, self(), connect_gateway),
    erlang:put(reconnect_timer, Ref).