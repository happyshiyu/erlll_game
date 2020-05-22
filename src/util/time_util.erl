%%%-------------------------------------------------------------------
%%% @author shiyu
%%% @copyright (C) 2020
%%% @doc
%%%
%%% @end
%%% Created : 26. 4月 2020 下午 19:04
%%%-------------------------------------------------------------------
-module(time_util).
-author("shiyu").

-define(ONE_MINUTE_SECONDS,	  60).	%% 1分钟60秒

-define(ONE_HOUR_MINUTES,	    60).	%% 1小时60钟
-define(ONE_HOUR_SECONDS,	    3600).	%% 1小时3600秒

-define(ONE_DAY_HOURS,		    24).	%% 1天24小时
-define(ONE_DAY_MINUTES,	    1440).	%% 1天1440分钟
-define(ONE_DAY_SECONDS,	    86400).	%% 1天86400秒

-define(ONE_WEEK_DAYS,		    7).		%% 1星期7天
-define(ONE_WEEK_HOURS,		    168).	%% 1星期168小时
-define(ONE_WEEK_MINUTES,	    10080).	%% 1星期10080分钟
-define(ONE_WEEK_SECONDS,	    604800).%% 1星期604800秒

%% API
-export([
    time/0,
    time/1
]).

time() ->
    {M, S, _} = os:timestamp(),
    M * 1000000 + S.

time(ms) ->
    {M, S, MS} = os:timestamp(),
    trunc(M * 1000000000 + S * 1000 + MS / 1000);

time(today) ->
    {M, S, MS} = os:timestamp(),
    {_, Time} = calendar:now_to_local_time({M, S, MS}),
    M * 1000000 + S - calendar:time_to_seconds(Time);

time(next_day) ->
    time(today) + ?ONE_DAY_SECONDS.
