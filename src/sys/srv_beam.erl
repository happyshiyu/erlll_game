%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020, junhai
%%% @doc
%%%
%%% @end
%%% Created : 06. 4月 2020 下午 21:53
%%%-------------------------------------------------------------------
-module(srv_beam).

-behaviour(gen_server).

-define(ETS_BEAM_CACHE, ets_beam_md5_cache).

%% API
-export([start_link/0]).

-export([u/0, u/1, u/2, m/0, mu/0, mu/1]).
-define(EBIN_ROOT_DIR, "./ebin").

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-record(state, {path = "."}).


%%%===================================================================
%%% API m只会在开发服调用
%%%===================================================================
m() ->
    %% 修正ebin目录
    Dir = get_default_path(),
    case file:get_cwd() of
        {ok, Dir} -> ok;
        _ -> file:set_cwd(Dir)
    end,
    Rtn = make:all([debug_info,{parse_transform, lager_transform}, {outdir, "./ebin"}, {d, debug}]),
    Rtn.

mu() ->
    case m() of
        up_to_date -> u();
        _ -> ok
    end.

mu(Args) ->
    case m() of
        up_to_date -> u(Args);
        _ -> ok
    end.

u() ->
    N = beam_hash(),
    O = ets:tab2list(?ETS_BEAM_CACHE),
    do_up(N, O, [], fun code:soft_purge/1).
u(force) ->
    N = beam_hash(),
    O = ets:tab2list(?ETS_BEAM_CACHE),
    do_up(N, O, [], fun code:purge/1);
u(ModList) ->
    O = ets:tab2list(?ETS_BEAM_CACHE),
    N = do_beam_hash(ModList, []),
    do_up(N, O, [], fun code:soft_purge/1).
u(ModList, force) ->
    O = ets:tab2list(?ETS_BEAM_CACHE),
    N = do_beam_hash(ModList, []),
    do_up(N, O, [], fun code:purge/1).


load_file() ->
%%    io:format("dir=~p ~n",[get_ebin_dir()]),
    case file:list_dir(get_ebin_dir()) of
        {ok, FList} ->
            F = fun(Module) ->
                case filename:extension(Module) =:= ".beam" of
                    true ->
                        Module_1 = filename:basename(filename:rootname(Module)),
                        Module_2 = list_to_atom(Module_1),
                        code:load_file(Module_2);
                    _ -> ok
                end
                end,
            lists:foreach(F, FList);
        {error, Why} -> io:format("load_file ~w",[Why])
    end.

%%
get_ebin_dir() ->
    {ok, Root} = file:get_cwd(),
    filename:join(Root, "ebin").

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    % ?INFO("启动热更新服务"),
    ets:new(?ETS_BEAM_CACHE, [named_table, public, set]),
    io:format("xxxxxxx => ~p", [file:get_cwd()]),
    [ets:insert(?ETS_BEAM_CACHE, X) || X <- beam_hash()],
    {ok, Dir} = file:get_cwd(),
    load_file(),
%%    Dir =  io_lib:format("~s/~s)",[RootDir, "ebin"]),
    {ok, #state{path = Dir}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({default_path}, _From, State) ->
    Reply = State#state.path,
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
beam_file() ->
    case file:list_dir(?EBIN_ROOT_DIR) of
        {ok, FList} -> {ok, do_beam_file(FList, [])};
        {error, Why} -> {error, Why}
    end.

beam_hash() ->
    case beam_file() of
        {ok, F} -> do_beam_hash(F, []);
        {error, Why} -> {error, Why}
    end.

do_beam_file([], List) -> List;
do_beam_file([F | T], List) ->
    NL = case filename:extension(F) =:= ".beam" of
             true ->
                 M = filename:basename(filename:rootname(F)), [M | List];
             _ -> List
         end,
    do_beam_file(T, NL).

do_beam_hash([], List) -> List;
do_beam_hash([N | T], List) ->
    NL = case beam_lib:md5(io_lib:format("~s/~s", [?EBIN_ROOT_DIR, N])) of
             {ok, {M, Md5}} -> [{M, md5(Md5)} | List];
             {error, _, Why} ->
                 io:format("获取MD5失败:~w", [Why]),
                 List
         end,
    do_beam_hash(T, NL).

do_up([], _O, Rtn, _Fun) ->
    io:format("HOT:~w ~n", [Rtn]),
    Rtn;
do_up([{Mod, NewHash} | N], O, Rtn, Fun) ->
    NewRtn = case lists:keyfind(Mod, 1, O) of
                 false -> [load_beam(Mod, NewHash, Fun) | Rtn];
                 {_, OldHash} ->
                     case OldHash =:= NewHash of
                         true -> Rtn;
                         false -> [load_beam(Mod, NewHash, Fun) | Rtn]
                     end
             end,
    do_up(N, O, NewRtn, Fun).

load_beam(Mod, Hash, PurgeFun) ->
    PurgeFun(Mod),
    case code:load_file(Mod) of
        {module, _} ->
            ets:insert(?ETS_BEAM_CACHE, {Mod, Hash}), {Mod, ok};
        {error, Why} -> {Mod, {error, Why}}
    end.

get_default_path() ->
    gen_server:call(?MODULE, {default_path}).

md5(S) ->
    list_to_binary([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(S))]).