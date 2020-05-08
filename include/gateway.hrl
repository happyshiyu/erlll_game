%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 26. 4月 2020 下午 19:06
%%%-------------------------------------------------------------------
-author("shiyu").

-record(gateway_token, {
    token = <<>>,
    username = <<>>,
    valid_time = 0
}).

-record(game_server_info, {
    server_id = 0,
    name = <<>>,
    ip = <<>>,
    port = 0,
    status = 0
}).