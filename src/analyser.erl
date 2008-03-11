-module(analyser).
-compile(export_all).

start() ->    spawn_link(fun() -> analyser:loop([], dict:new()) end).
	
append(Pid, Url, TimeTaken) -> rpc(Pid, {Url, TimeTaken}).
kill(Pid) -> rpc(Pid, kill).
publish_results(Pid) -> rpc(Pid, publish).
display(Pid) -> rpc(Pid, display).
snapshot(Pid) -> rpc(Pid, snapshot).
captureSnapshot(Pid) -> rpc(Pid, capture_snapshot).
averages(Pid) -> rpc(Pid, averages).

loop(Stats, Dict) ->
    receive
	    {From, snapshot} ->
            From ! {self(), {ok, findSnapshotFromDict(Dict)}},
            loop(Stats, Dict);
	    {From, averages} ->
            From ! {self(), {ok, average_times(Dict)}},
            loop(Stats, Dict);
	    {From, capture_snapshot} ->
            From ! {self(), ok},
	        {FinishedCount, ProcessCount, ActiveUsers} = data_collector:currentStatus(whereis(collector)),
            publisher:publish_runtime(erlang:localtime(),Dict, ActiveUsers),
            loop(Stats, Dict);
	    {From, publish} ->
            publisher:publish(Dict),
            From ! {self(), ok},
            loop(Stats, Dict);
	    {From, display} ->
            From ! {self(), {ok}},
            displayMap(Dict),
            loop(Stats, Dict);
	    {From, kill} ->
	        log:info("Analyser teardown~n", []),
            From ! {self(), ok};
	    {From, {Url, TimeTaken}} ->
            From ! {self(), ok},
            NewDict = dict:append(lists:nth(2,Url), TimeTaken/1000, Dict),
	        loop(Stats, NewDict)
    end.

findSnapshotFromDict(ResultsDict) ->
    Results = dict:to_list(ResultsDict),
    Ur = lists:map(fun(A)-> element(1, element(1, A)) end, Results),
    Times = lists:map(fun(A)-> element(2,  A) end, Results),
	ExtStats = lists:map(fun(A) -> {lists:sum(A)/ lists:flatlength(A), lists:min(A), lists:max(A)} end, Times),
	Final = lists:zipwith(fun(T,U) -> erlang:append_element(T, U) end, ExtStats, Ur),
	Data = lists:map(fun(X)-> A = [element(4, X), integer_to_list(round(element(1, X))), integer_to_list(round(element(2, X))), integer_to_list(round(element(3, X)))], A end, Final),
	Data.

average_times(ResultsDict) ->
    Results = dict:to_list(ResultsDict),
    Times = lists:map(fun(A)-> element(2,  A) end, Results),
	lists:map(fun(A) -> integer_to_list(round(lists:sum(A)/ lists:flatlength(A))) end, Times).

displayMap(Map) ->    io:format("Dict:~p~n", [dict:to_list(Map)]).

rpc(Pid, Query) ->
    Pid ! {self(), Query},
    receive
        {Pid, Reply} ->
            Reply
%	after 100000 ->
%		io:format("Analyser Timeout")
    end.
