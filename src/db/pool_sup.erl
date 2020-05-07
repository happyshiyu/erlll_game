%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% 连接池监督者
%%% @end
%%% Created : 12. 4月 2020 下午 20:59
%%%-------------------------------------------------------------------
-module(pool_sup).
-author("shiyu").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%% @doc Starts the supervisor
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%% @private
%% @doc Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
-spec(init(Args :: term()) ->
    {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
        MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
        [ChildSpec :: supervisor:child_spec()]}}
    | ignore | {error, Reason :: term()}).
init([]) ->
    PoolSpecs = lists:map(fun({Name, Mod, SizeArgs, WorkerArgs}) ->
        PoolArgs = [{name, {local, Name}}, {worker_module, Mod}] ++ SizeArgs,
        poolboy:child_spec(Name, PoolArgs, WorkerArgs)
                          end, get_conf()),
    {ok, {{one_for_one, 10, 10}, PoolSpecs}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_conf() ->
    env_util:get(pool_config).
