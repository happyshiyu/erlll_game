%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 05. 4月 2020 下午 23:16
%%%-------------------------------------------------------------------
-module(base_handler).
-author("shiyu").

-include("player.hrl").
-include("err_code.hrl").
-include("02_base.hrl").

%% API
-export([
    handle/3
]).

handle(_ProtoId, Tuple, State) ->
    do_handle(Tuple, State).

do_handle(#pt_201_c{name = Name}, Player) ->
    NewPlayer = player_base:put(name, Name, Player),
    {reply, #pt_201_s{}, NewPlayer}.