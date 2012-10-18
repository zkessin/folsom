%%%
%%% Copyright 2011, Boundary
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%


%%%-------------------------------------------------------------------
%%% File:      folsom_metrics_counter.erl
%%% @author    joe williams <j@boundary.com>
%%% @doc
%%% @end
%%%-----------------------------------------------------------------

-module(folsom_metrics_counter).

-export([new/1,
         inc/1,
         inc/2,
         dec/1,
         dec/2,
         get_value/1,
         clear/1]).

-include("folsom.hrl").

new(Name) ->
    Counter = {Name, 0},
    ets:insert(?COUNTER_TABLE, Counter).

inc(Name) ->
    inc(Name, 1).

inc(Name, Value) when is_integer(Value) ->
    ets:update_counter(?COUNTER_TABLE, Name, Value);
inc(Name, Value) when is_float(Value) ->
    inc_float_racy_but_good_enough(Name, Value).

inc_float_racy_but_good_enough(Name, Value) ->
    Old = case ets:lookup(?COUNTER_TABLE, Name) of
              [{_, Val}] -> Val;
              []         -> 0.0
          end,
    true = ets:insert(?COUNTER_TABLE, {Name, Old + Value}).

dec(Name) ->
    dec(Name, -1).

dec(Name, Value) when is_integer(Value) ->
    ets:update_counter(?COUNTER_TABLE, Name, -Value);
dec(Name, Value) when is_float(Value) ->
    inc_float_racy_but_good_enough(Name, -1.0 * Value).

get_value(Name) ->
    [{_, Values}] = ets:lookup(?COUNTER_TABLE, Name),
    Values.

clear(Name) ->
    new(Name).
