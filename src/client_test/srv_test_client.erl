%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 05. 4月 2020 下午 12:52
%%%-------------------------------------------------------------------
-module(srv_test_client).
-author("shiyu").

-behaviour(gen_server).
-include("01_login.hrl").

%% API
-export([start_link/0, test/2]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).
-define(TIMEOUT, 5000).

-record(state, {socket}).

%%%===================================================================
%%% API
%%%===================================================================
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

test(ProtoId, Args) ->
    ProtoName = erlang:list_to_atom("pt_" ++ erlang:integer_to_list(ProtoId) ++ "_c"),
    ?MODULE ! {test, ProtoId, erlang:list_to_tuple([ProtoName|Args])}.


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    ?SERVER ! init,
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
handle_info(init, #state{} = State) ->
    {ok, Socket} = gen_tcp:connect("127.0.0.1", 8080, [binary,
        {packet, 0},
        {active, once},
        {send_timeout, 30000},
        {send_timeout_close, true},
        {exit_on_close, true},
        {keepalive, true},
        {delay_send, true},
        {nodelay, true}]),
    {noreply, State#state{socket = Socket}};

handle_info({test, ProtoId, Tuple}, #state{socket = Socket} = State) ->
    Bin = lib_proto:pack(ProtoId, Tuple),
    gen_tcp:send(Socket, Bin),
    {noreply, State};
handle_info({tcp, Socket, Data}, State = #state{socket = Socket}) ->
    ProtoList = lib_proto:client_unpack(Data, []),
    io:format("Data:~p~n", [ProtoList]),
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
    {stop, normal, State};

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
