-module(test_runner).
-compile(export_all).

for(Max, Max, F) -> [F()];
for(I, Max, F)   -> [F()|for(I+1, Max, F)].

startTests(_Requests, [], _Interval) -> true;
startTests(Requests, Pids, Interval) ->
	[Pid|T] = Pids,
	Pid ! {Requests},
	whereis(collector) ! {self(), one_more},
	log:info("Sent to ~p.~n", [Pid]),
	ok = timer:sleep(Interval),
	startTests(Requests, T, Interval).

spawnProcesses(ProcessCount) ->
     RestOfTheWorld = case lists:flatlength(net_adm:world()) of
        1 -> net_adm:world();
        _ -> lists:subtract(net_adm:world(), [node()])
     end,
     log:info("Spawning processes on ~p instances:~p.~n", [lists:flatlength(RestOfTheWorld), RestOfTheWorld]),
     ProcessesPerNode = ProcessCount div lists:flatlength(RestOfTheWorld),
     Pids = spawnOn(RestOfTheWorld, ProcessesPerNode, []),
     log:info("Spawned ~p Processes~n", [ProcessCount]),
     lists:flatten(Pids).

spawnOn([], _, Pids) -> Pids;
spawnOn(Nodes, Processes, Pids) ->
    [Node|Rest] = Nodes,
    MyPids = for(1,Processes, fun() -> spawn(Node, worker, fetch_and_measure, [node()]) end),
    spawnOn(Rest, Processes, [MyPids|Pids]).

run(ProcessCount, RampUpTime, Requests) ->
    Interval = RampUpTime div ProcessCount,
    Pids = spawnProcesses(ProcessCount),
    startTests(Requests, Pids, Interval).