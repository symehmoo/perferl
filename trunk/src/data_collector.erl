-module(data_collector).
-compile(export_all).

start(ProcessCount) ->    spawn_link(fun() -> data_collector:loop(0, ProcessCount, 0, 0) end).

currentStatus(Pid) -> rpc(Pid, current_status).
%gatherRuntimeData(Pid) -> rpc(Pid, gather_runtime_data).

loop(FinishedCount, ProcessCount, RuntimeTimer, ActiveUsers) ->
	receive
		{ok, Pid} ->
			log:info("Pid ~p finished.(~p:~p)~n", [Pid, FinishedCount + 1, ProcessCount]),
			case (FinishedCount + 1 =:= ProcessCount) of
				true ->  {ok, Stats} = analyser:snapshot(whereis(observer)),
				         io:format("Stats:~p~n", [Stats]),
				         whereis(theprogram) ! {self(), start_teardown};
				false -> void
			end,
			loop(FinishedCount + 1, ProcessCount, RuntimeTimer, ActiveUsers - 1);
		{Pid, current_status} ->
			Pid ! { self(), {FinishedCount, ProcessCount, ActiveUsers}},
			loop(FinishedCount, ProcessCount, RuntimeTimer, ActiveUsers);
		{Pid, kill} ->
			log:info("Collector Teardown:Status:(~p:~p:~p)~n", [FinishedCount, ProcessCount, ActiveUsers]),
			timer:cancel(RuntimeTimer),
			Pid ! {ok};
%		{Pid, gather_runtime_data} ->
%			{ok, Rt} = timer:apply_interval(1000, analyser, captureSnapshot, [whereis(observer)]),
%			Pid ! {self(), ok},
%			loop(FinishedCount, ProcessCount, Rt, ActiveUsers);
		{Pid, one_more} ->
			Pid ! {self(), ok},                         
			loop(FinishedCount, ProcessCount, RuntimeTimer, ActiveUsers+1);
		{Url, TimeTaken, _Pid} ->
		    analyser:append(whereis(observer), Url, TimeTaken),
			loop(FinishedCount, ProcessCount, RuntimeTimer, ActiveUsers)
	end.

rpc(Pid, Query) ->
    Pid ! {self(), Query},
    receive
        {Pid, Reply} -> Reply
    end.

