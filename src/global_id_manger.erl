%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020, junhai
%%% @doc
%%% global_id is int64
%%% | PlatId (10bit) | ServerId (12bit) | UnixTime(s) (32bit) | IncreaseId (10bit) |
%%% @end
%%% Created : 21. 5月 2020 17:21
%%%-------------------------------------------------------------------
-module(global_id_manger).
-author("shiyu").

-behaviour(gen_server).

%% API
-export([
    start_link/0,
    create_id/0
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

%%% | PlatId (10bit) | ServerId (12bit) | UnixTime(s) (32bit) | IncreaseId (10bit) |
-define(PLAT_ID_BITS, 10).
-define(SERVER_ID_BITS, 12).
-define(UNIX_TIME_BITS, 32).
-define(INCREASE_BITS, 10).

-record(state, {
    last_unixtime = 0,
    increase_id = 0
}).

%%%===================================================================
%%% API
%%%===================================================================
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

create_id() ->
    gen_server:call(?SERVER, get_id).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    {ok, #state{}}.


-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call(get_id, _From, #state{last_unixtime = LastTime, increase_id = IncreaseId} = State) ->
    NowTime = time_util:time(),
    RetId = try_create_id(NowTime, LastTime, IncreaseId),
    NewIncreaseId = case LastTime =/= NowTime of true -> 0; false -> IncreaseId + 1 end,
    {reply, RetId, State#state{last_unixtime = NowTime, increase_id = NewIncreaseId}};
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
try_create_id(NowTime, LastTime, IncreaseId) ->
    case NowTime =/= LastTime andalso IncreaseId < 1024 of
        true ->
            create_id(NowTime, IncreaseId);
        false ->
            timer:sleep(1000),
            create_id(NowTime, IncreaseId)
    end.

create_id(NowTime, IncreaseId) ->
    PlatId = env_util:get(plat_id,0),
    ServerId = env_util:get(server_id, 0),
    (PlatId bsl (?SERVER_ID_BITS + ?UNIX_TIME_BITS + ?INCREASE_BITS)) + (ServerId bsl (?UNIX_TIME_BITS + ?INCREASE_BITS)) +
        (NowTime bsl ?INCREASE_BITS) + IncreaseId.