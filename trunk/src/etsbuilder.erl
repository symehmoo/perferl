-module(etsbuilder).
-compile(export_all).

req(get, Url) -> [get, {Url,[]}, [{autoredirect, true}],[]].
req(post, Url, Params) -> [post, {Url,[], "application/x-www-form-urlencoded", Params}, [], []].

list(Pid) -> rpc(Pid, list).

table(Pid) -> rpc(Pid, tableid).

stop(Pid) -> rpc(Pid, stop).

add(Pid, Details) -> rpc(Pid, Details).

start() ->
    spawn(fun() -> loop(ets:new(requests, [set])) end).

rpc(Pid, Query) ->
    Pid ! {self(), Query},
    receive
        {Pid, Reply} ->
            Reply
	after 5000 ->
		io:format("Builder Timeout")
    end.


loop(X) ->
    receive
		{From, {Name, Method, Url}} ->
			io:format("Received URL:~p~p~n" ,[Method, Url]),
			From ! {self(), ok},
			ets:insert(X, {Name, req(Method, Url)}),
			loop(X);
		{From, {Name, Method, Url, Params}} ->
			io:format("Received URL:~p:~p~n" ,[Method, Url]),
			From ! {self(), ok},
			ets:insert(X, {Name, req(Method, Url, Params)}),
			loop(X);
		{From, list} ->
			From ! {self(), values(X)},
            loop(X);
		{From, tableid} ->
			From ! {self(), X},
            loop(X);
		{From, display} ->
			io:format("Listing requests:~n"),
%			displayMap(X),
			From ! {self(), ok},
            loop(X);
		{From, stop} ->
			io:format("Stopping...~n"),
			From ! {self(), values(X)};
        {From,Any} ->
            io:format("Received:~p~n" , [Any]),
            From ! {self(), ok},
			loop(X)
    end.
	
displayMap(Map) ->
	lists:map(fun(E) -> io:format("~p:~p~n", [E, dict:fetch(E, Map)]) end, dict:fetch_keys(Map)).

values(TableId) ->
	{_keys, Values} = lists:unzip(ets:tab2list(TableId)),
	Values.

buildRIDRequests() ->
	B = etsbuilder:start(),
	etsbuilder:add(B, {"param-get", get, "http://localhost:8080/ViewProfileSearch.action"}),
	etsbuilder:add(B, {"param-post", post, "http://localhost:8080/ProfileSearch.action", "criteria.requestedPage.size=10"}),
	etsbuilder:add(B, {"param-post2", post, "http://localhost:8080/ProfileSearch.action", "criteria.lastName=test&criteria.requestedPage.size=10"}),
	etsbuilder:add(B, {"param-post3", post, "http://localhost:8080/ProfileSearch.action", "criteria.lastName=tom*&criteria.requestedPage.size=10"}),
	etsbuilder:add(B, {"param-post4", post, "http://localhost:8080/rid/A-1000-2033", "navigatable=true"}),
	etsbuilder:add(B, {"param-post5", post, "http://localhost:8080/rid/A-1000-2038", "navigatable=true"}),
	etsbuilder:table(B).
	