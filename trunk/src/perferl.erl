-module(perferl).
-compile(export_all).

startTheTests(Pid) -> rpc(Pid, start_tests).
initialize(Pid, ProcessCount, RampUpTime) -> rpc(Pid, {initialize, ProcessCount, RampUpTime}).
cleanup(Pid) -> rpc(Pid, cleanup).
killme(Pid) -> rpc(Pid, kill).

start(Message) ->
	io:format("~p~n", [Message]),
    spawn(fun start/0).

start() ->
    inets:start(),
	process_flag(trap_exit, true),
	register(theprogram, self()),
	loop(0, 0).

loop(ProcessCount, RampUpTime) ->
	receive
	    {From, {initialize, Pc, Rt}} ->
            register(observer, analyser:start()),
            register(collector, data_collector:start(Pc)),
	        publisher:do_this_once(),
	        publisher:start(),
            From ! {self(), ok},
            loop(Pc, Rt);
	    {From, start_tests} ->
            data_collector:gatherRuntimeData(whereis(collector)),
	        ok = timer:sleep(2000),
            test_runner:run(ProcessCount, RampUpTime, builder:buildWebRequests()),
            From ! {self(), ok},
            loop(ProcessCount, RampUpTime);
	    {From, kill} ->
	        From ! {self(), ok};
        {From, cleanup} ->
            analyser:publish_results(whereis(observer)),
            collector ! {self(), kill},
            analyser:kill(whereis(observer)),
            From ! {self(), ok},
            inets:stop(),
            log:info("Cleanup done", []),
            loop(ProcessCount, RampUpTime)
%		{'EXIT', _Analyser, Reason} ->
%			io:format("completed with Reason: ~p~n", [Reason])
%	after 100000 ->
%		io:format("Main Timeout")
	end.

doIt(Pc, Rt) ->
    perferl:start("initialised"),
	ok = timer:sleep(1000),
    perferl:initialize(whereis(theprogram), Pc, Rt * 1000),
    perferl:startTheTests(whereis(theprogram)).

clean() ->
     chart:generate(),
     perferl:cleanup(whereis(theprogram)),
     perferl:killme(whereis(theprogram)).

rpc(Pid, Query) ->
    Pid ! {self(), Query},
    receive
        {Pid, Reply} -> Reply
    end.
