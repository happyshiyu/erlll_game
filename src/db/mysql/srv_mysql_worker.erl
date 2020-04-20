%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% mysql工作进程
%%% @end
%%% Created : 06. 4月 2020 下午 20:29
%%%-------------------------------------------------------------------
-module(srv_mysql_worker).
-author("shiyu").

-behaviour(gen_server).

%% API
-export([
    start_link/1
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
    conn
}).

%%%===================================================================
%%% API
%%%===================================================================
start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init(Args) ->
    {ok, Conn} = mysql:start_link(Args),
    {ok, #state{conn = Conn}}.


-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call({execute, Statement, Args}, _From, #state{conn = Conn} = State) ->
    Ret = case mysql:execute(Conn, Statement, Args) of
              ok ->
                  mysql:affected_rows(Conn);
              {ok, _ColumnNames, Data} ->
                  Data;
              {ok, Data} ->
                  Data;
              {error, Reason} ->
                  {error, Reason}
          end,
    {reply, Ret, State};
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
