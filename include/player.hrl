%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%% about player
%%% @end
%%% Created : 05. 4月 2020 下午 20:51
%%%-------------------------------------------------------------------
-author("shiyu").

-record(player, {
    player_id = 0,
    socket,
    transport,
    base_data = #{},
    kv_data = #{},
    change_k_set = sets:new()
}).