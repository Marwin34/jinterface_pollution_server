%%%-------------------------------------------------------------------
%%% @author Marcin
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Apr 2019 11:17 AM
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Marcin").

%% API
-export([start/0]).

start() ->
  {pollution_client, 'client@DESKTOP-FPSIK9E'} ! {self(), "pid"},
  init().

init() ->
  loop(pollution:createMonitor()).

loop(M) ->
  receive
    {request, Pid, {addStation, {Name, {N, E}}}} ->
      Result = {monitor, pollution:addStation(Name, {N, E}, M)},
      fetchResult(Result, Pid, M);

    {request, Pid, {addValue, {Key, Date, Type, Value}}} ->
      Result = {monitor, pollution:addValue(Key, Date, Type, Value, M)},
      fetchResult(Result, Pid, M);

      {request, Pid, {removeValue, {Key, Date, Type}}} ->
      Result = {monitor, pollution:removeValue(Key, Date, Type, M)},
      fetchResult(Result, Pid, M);

    {request, Pid, {getOneValue, {Key, Date, Type}}} ->
      Result = {value, pollution:getOneValue(Key, Date, Type, M)},
      fetchResult(Result, Pid, M);

    {request, Pid, {getStationMean, {Key, Type}}} ->
      Result = {value, pollution:getStationMean(Key, Type, M)},
      fetchResult(Result, Pid, M);

    {request, Pid, {stop}} ->
      Pid ! {stop, ok};

    {request, Pid, debug} ->
      Pid ! {debug, M};

    {request, crash} ->
      1 / 0
  end.

fetchResult(Result, Pid, M) ->
  case Result of
    {monitor, Value} ->
      case Value of
        {error, Message} -> Pid ! {error, Message}, loop(M);
        _ -> Pid ! {monitor, ok}, loop(Value)
      end;
    {value, Value} ->
      case Value of
        {error, Message} -> Pid ! {error, Message}, loop(M);
        _ -> Pid ! {value, Value}, loop(M)
      end
  end.