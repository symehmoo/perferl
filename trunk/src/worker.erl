-module(worker).
-compile(export_all).

fetch(URL, Controller) ->
	case timer:tc(http, request, URL) of
		{TimeTaken, {ok, {{_Version, 200, _ReasonPhrase}, _Headers, _Body}}} ->
				{collector, Controller} ! {URL, TimeTaken, self()};
		{TimeTaken, {ok, {{_Version, 302, _ReasonPhrase}, Headers, _Body}}} ->
				{value, {_, RedirectUrl}} = lists:keysearch("location", 1, Headers),
				{collector, Controller} ! {URL, TimeTaken, self()},
				fetch(builder:req(get, RedirectUrl), Controller);
		{TimeTaken, {error, Reason}} ->
				log:info("<~p>: Error accessing ~p: ~p~n", [self(), lists:nth(2,URL), Reason]),
				{collector, Controller} ! {URL, TimeTaken, self()};
		{TimeTaken, _Other} ->
				log:info("<~p>: Unknown Error accessing ~p : ~p~n", [self(), lists:nth(2,URL), _Other]),
				{collector, Controller} ! {URL, TimeTaken, self()}
	end.

fetchRequests(_TableId, '$end_of_table', _) -> void;
fetchRequests(TableId, Key, Controller) ->
	Val = ets:lookup(TableId, Key),
	TheUrl = element(2, lists:nth(1, Val)),
    fetch(TheUrl, Controller),
    fetchRequests(TableId, ets:next(TableId, Key), Controller).

fetch_and_measure(Controller) ->
	receive
		{Urls} ->
			lists:map(fun(Url) -> fetch(Url, Controller) end, Urls),
%            TableId = Urls,
%			fetchRequests(TableId, ets:first(TableId), Controller),
			{collector, Controller} ! {ok, self()};
		Other ->
			io:format("Wrong param  ~p !~n", [Other]),
			fetch_and_measure(Controller)
	end.