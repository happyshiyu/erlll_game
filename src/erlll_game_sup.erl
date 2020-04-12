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
    supervisor:start_link({local, ?SERVER}, ?MODULE, [game]).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([Type]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    {ok, {SupFlags, get_child_spec(Type)}}.

%% internal functions
get_child_spec(game) ->
    [
        #{id => pool_sup, start => {pool_sup, start_link, []}, type => supervisor},
        #{id => srv_net, start => {srv_net, start_link, []}, type => worker}
%%        #{id => srv_beam, start => {srv_beam, start_link, []}, type => worker}
    ];
get_child_spec(login) ->
    [
        #{id => srv_net, start => {srv_net, start_link, []}}
    ].