%%%-------------------------------------------------------------------
%% @doc erlll_game top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(erlll_game_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    NodeName = erlang:atom_to_list(node()),
    StartType = case string:find(NodeName, "gateway") of
                    _ -> gateway
                end,
    SupFlags = #{strategy => one_for_all, intensity => 0, period => 1},
    {ok, {SupFlags, get_child_spec(StartType)}}.

%% internal functions
get_child_spec(game_server) ->
    [
        #{id => pool_sup, start => {pool_sup, start_link, []}, type => supervisor},
        #{id => net_listener, start => {net_listener, start_link, []}, type => worker},
        #{id => gateway_connector, start => {gateway_connector, start_link, []}, type => worker}
    ];
get_child_spec(gateway) ->
    [
        #{id => pool_sup, start => {pool_sup, start_link, []}, type => supervisor},
        #{id => gateway_server, start => {gateway_server, start_link, []}}
        #{id => game_server_manager, start => {game_server_manager, start_link, []}}
    ].