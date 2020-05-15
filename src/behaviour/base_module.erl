%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% base_module
%%% @end
%%% Created : 15. 5月 2020 15:31
%%%-------------------------------------------------------------------
-module(base_module).
-author("shiyu").
-include("player.hrl").

-callback from_db(Player :: #player{}) -> NewPlayer :: #player{}.

-callback to_db(Player :: #player{}) -> term().

-callback get(K :: term(), Player :: #player{}, Default :: term()) -> term().

-callback put(K :: term(), V :: term(), Player :: #player{}) -> NewPlayer :: #player{}.

-optional_callbacks([get/3, put/3]).