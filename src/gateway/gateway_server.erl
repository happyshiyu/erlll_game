%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 26. 4月 2020 下午 16:13
%%%-------------------------------------------------------------------
-module(gateway_server).
-author("shiyu").

-behaviour(gen_server).
-include("gateway.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

%% API
-export([
    start_link/0,
    create_token/1
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-define(SERVER, ?MODULE).
-define(VALID_TIME, 300).
-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

-spec(create_token(Username :: binary()) -> Token :: binary()).
create_token(Username) ->
    Tmp0 = erlang:binary_to_list(Username),
    Tmp1 = erlang:integer_to_list(rand:uniform(9999999)),
    Tmp2 = Tmp0 ++ Tmp1,
    MD51 = list_to_binary([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(Tmp2))]),
    Token = erlang:binary_part(erlang:md5(MD51), 8, 16),
    ValidTime = time_util:time() + ?VALID_TIME,
    ets:insert(gateway_token, #gateway_token{token = Token, username = Username, valid_time = ValidTime}),
    Token.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    ets:new(gateway_token, [named_table, set, public, {read_concurrency, true}, {keypos, #gateway_token.token}]),
    erlang:send_after(5 * 60 * 1000, self(), clean_invalid_token),
    Port = env_util:get(port),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/login/", gateway_handler, []}
        ]}
    ]),
    cowboy:start_clear(http_server, [
        {keepalive, false},
        {port, Port}
    ],
        #{env => #{dispatch => Dispatch}}
    ),
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
handle_info(clean_invalid_token, State) ->
    clean_invalid_token(),
    erlang:send_after(5 * 60 * 1000, self(), clean_invalid_token),
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
clean_invalid_token() ->
    Time = time_util:time(),
    MS = ets:fun2ms(
        fun(TmpToken) when
            TmpToken#gateway_token.valid_time =< Time
            -> true
        end),
    ets:select_delete(gateway_token, MS).