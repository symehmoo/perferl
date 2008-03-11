-module(publisher).
-compile(export_all).

-include_lib("/home/srk/otp_src_R12B-0/lib/stdlib/include/qlc.hrl" ).

-record(test_results, {url,
                 average,
                 min,
                 max,
                 process_times = []}).

-record(runtime_test_results, {time_stamp,
                               url,
                               active_users = 0,
                               process_times_size = 0}).

do_this_once() ->
    mnesia:create_schema([node()]),
    io:format("do_this_once"),
    mnesia:start(),
    mnesia:create_table(test_results,   [{attributes, record_info(fields, test_results)}]),
    mnesia:create_table(runtime_test_results,   [{attributes, record_info(fields, runtime_test_results)}]),
    mnesia:stop().
    
start() ->
	mnesia:start(),
	mnesia:wait_for_tables([test_results, runtime_test_results], 1000).

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

insert(Row) ->
    F = fun() ->
                 mnesia:write(Row)
        end,
    mnesia:transaction(F).
   

persist(Key, Value) ->
    Url = element(1,Key),
    Row = #test_results{url=Url, average=10, min=0,max=10, process_times =Value},
    insert(Row).

persist_runtime(TimeStamp, Key, Value, ActiVusers) ->
    Url = element(1,Key),
    Row = #runtime_test_results{time_stamp=TimeStamp, url=Url, active_users=ActiVusers, process_times_size = lists:flatlength(Value)},
    log:info("inserting: ~p",[Row]),
    insert(Row).

publish_runtime(TimeStamp, ResultsDict, ActiVusers) ->
    lists:foreach(fun(A) -> persist_runtime(TimeStamp,A, dict:fetch(A, ResultsDict), ActiVusers) end, dict:fetch_keys(ResultsDict)).

publish(ResultsDict) ->
    lists:foreach(fun(A) -> persist(A, dict:fetch(A, ResultsDict)) end, dict:fetch_keys(ResultsDict)),
    stop().

fetchRuntimeData() ->
    do(qlc:sort(qlc:q([{X#runtime_test_results.time_stamp, X#runtime_test_results.active_users} || X <- mnesia:table(runtime_test_results)]))).
    

stop() ->
    TestResults = do(qlc:q([X || X <- mnesia:table(test_results)])),
    RuntimeTestResults = do(qlc:q([X || X <- mnesia:table(runtime_test_results)])),
%    log:info("test_results: ~p",[TestResults]),
%    log:info("stopping publisher, runtime_test_results: ~p",[RuntimeTestResults]),
    mnesia:stop().
    