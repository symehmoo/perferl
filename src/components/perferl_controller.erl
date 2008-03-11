% yaws -i -sname main -pa /home/srk/dev/erlang/deployment/perferl/lib/erlyweb-0.6.2/ebin --conf /home/srk/dev/erlang/deployment/perferl/yaws.conf
-module(perferl_controller).
-erlyweb_magic(erlyweb_controller).
-define(Debug(Msg, Params), erlyweb_util:log(?MODULE, ?LINE, debug, Msg, Params)).
-export([
	 home/2,
	 layout/1,
	 startit/1,
	 status/1,
	 snapshot/1,
	 finished/1
	]).

layout(Method) -> 
    case Method of
        home -> true;
        _ -> false
    end.

snapshot(_A) ->
    Analyser = whereis(observer),
    case Analyser of
        undefined -> {data, {"Analyser undefined Error"}};
        _ ->
            {ok, Snapshot} = analyser:snapshot(Analyser),
            {data, {Snapshot}}
    end.

status(_A) ->
    CollectorPid = whereis(collector),
    case CollectorPid of
        undefined ->  {data, {"0", " specified "}};
        _ -> {FinishedCount, ProcessCount, _ActiveUsers} = data_collector:currentStatus(CollectorPid),
             {data, {integer_to_list(FinishedCount), integer_to_list(ProcessCount)}}
    end.

startit(A) ->
    perferl:start("Created the Process"),
	ok = timer:sleep(1000),
    Params = dict:from_list(yaws_api:parse_post(A)),
    {ok, Pc} = dict:find("Pc", Params),
    {ok, Rt} = dict:find("Rt", Params),
	case whereis(observer) of
	    undefined ->
            TheMain = whereis(theprogram),
            ok = perferl:initialize(TheMain, erlang:list_to_integer(Pc), erlang:list_to_integer(Rt) * 1000),
            ok = perferl:startTheTests(TheMain),
            {data, {""}};
        _ ->
            {data, {"Already Started"}}
    end.

home(_A, Model) ->
	{data, {integer_to_list(lists:flatlength(lists:subtract(net_adm:world(), [node()])))}}.

finished(_A) ->
    io:format("Cleaning up~n"),
    {ok, Averages} = analyser:averages(whereis(observer)),
    Chart1 = "http://chart.apis.google.com/chart?cht=bvs&chs=500x200&chco=ff0000&chd=t:" ++ lists:nth(1,Averages) ++ "," ++lists:nth(2,Averages) ++ "," ++lists:nth(3,Averages),
    log:info("Returning chart ~p:", [Chart1]),
    Chart2 = chart:generate(),
    perferl:clean(),
	{data, {Chart1, Chart2}}.
