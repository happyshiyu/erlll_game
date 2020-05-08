%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% 游戏管理
%%% @end
%%% Created : 26. 4月 2020 下午 17:08
%%%-------------------------------------------------------------------
-module(game_server_manager).
-author("shiyu").

-behaviour(gen_server).
-include("gateway.hrl").

%% API
-export([
    start_link/0,
    register/6
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

-define(SERVER_CLOSE, 0).
-define(SERVER_OPEN, 1).
-define(SERVER_FIXED, 2).

%%%===================================================================
%%% API
%%%===================================================================
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

-spec(register(Node, Pid, ServerId, Name, IP, Port) -> term() when
    Node :: node(),
    Pid :: pid(),
    ServerId :: integer(),
    Name :: binary(),
    IP :: binary(),
    Port :: integer()
).
register(Node, Pid, ServerId, Name, IP, Port) ->
    gen_server:call(?MODULE, {register_game, Node, Pid, ServerId, Name, IP, Port}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    ets:new(game_server, [named_table, set, public, {read_concurrency, true}, {keypos, #game_server_info.server_id}]),
    {ok, #state{}}.


-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call({register_game, Node, Pid, ServerId, Name, IP, Port}, _From, State) ->
    do_register_game(Node, Pid, ServerId, Name, IP, Port),
    {reply, {ok, self()}, State};
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
handle_info({nodedown, Node}, State) ->
    ServerId = erlang:get(Node),
    ets:delete(game_server, ServerId),
    erlang:erase(Node),
    {noreply, State};
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
do_register_game(Node, Pid, ServerId, Name, IP, Port) ->
    erlang:put(Node, ServerId),
    GameServer = #game_server_info{server_id = ServerId, name = Name, ip = IP, port = Port, status = ?SERVER_OPEN, pid = Pid},
    ets:insert(game_server, GameServer).
