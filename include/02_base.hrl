%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.11.1

-ifndef('02_base').
-define('02_base', true).

-define('02_base_gpb_version', "4.11.1").

-ifndef('PT_201_C_PB_H').
-define('PT_201_C_PB_H', true).
-record(pt_201_c,
        {name = <<>>            :: iodata() | undefined % = 1
        }).
-endif.

-ifndef('PT_201_S_PB_H').
-define('PT_201_S_PB_H', true).
-record(pt_201_s,
        {ret = 0                :: non_neg_integer() | undefined % = 1, 32 bits
        }).
-endif.

-endif.