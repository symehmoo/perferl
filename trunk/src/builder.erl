-module(builder).
-compile(export_all).

start() ->    spawn(fun() -> loop(dict:new()) end).

req(get, Url) -> [get, {Url,[]}, [{autoredirect, true}],[]].
req(post, Url, Params) -> [post, {Url,[], "application/x-www-form-urlencoded", Params}, [], []].

list(Pid) -> rpc(Pid, list).
stop(Pid) -> rpc(Pid, stop).
add(Pid, Details) -> rpc(Pid, Details).

loop(X) ->
    receive
		{From, {Name, Method, Url}} ->
			io:format("Received URL:~p~p~n" ,[Method, Url]),
			From ! {self(), ok},
			loop(dict:store(Name, req(Method, Url), X));
		{From, {Name, Method, Url, Params}} ->
			io:format("Received URL:~p:~p~n" ,[Method, Url]),
			From ! {self(), ok},
			loop(dict:store(Name, req(Method, Url, Params), X));
		{From, list} ->
			From ! {self(), values(X)},
            loop(X);
		{From, display} ->
			io:format("Listing requests:~n"),
			displayMap(X),
			From ! {self(), ok},
            loop(X);
		{From, stop} ->
			io:format("Stopping...~n"),
			From ! {self(), values(X)};
        {From,_} ->
            From ! {self(), ok},
			loop(X)
    end.
	
displayMap(Map) ->
	lists:map(fun(E) -> io:format("~p:~p~n", [E, dict:fetch(E, Map)]) end, dict:fetch_keys(Map)).

values(Map) ->
	{_Keys, Values} = lists:unzip(dict:to_list(Map)),
	Values.

buildWebRequests() ->
	buildRequestsFrom("web_requests.perferl").

buildRIDRequests() ->
	buildRequestsFrom("rid_requests.perferl").
	
buildSampleRequests() ->
	buildRequestsFrom("employee_create.perferl").

buildRequestsFrom(FileName) ->
	B = builder:start(),
	Name = string:concat("/home/srk/dev/erlang/deployment/perferl/example_tests/", FileName),
	log:info("consulting: ~p",[Name]),
	{ok, Terms} = file:consult(Name),
	lists:foreach(fun(A) -> builder:add(B, A)end , Terms),
	builder:list(B).

rpc(Pid, Query) ->
    Pid ! {self(), Query},
    receive
        {Pid, Reply} ->    Reply
    end.

