-module(perferl_app_controller).
-export([hook/1]).

hook(A) ->
	{phased, {ewc, A},
		fun(Ewc, Data) ->
			{ewc,Controller,_View, Function,_} = Ewc,
			case Controller:layout(Function) of
				true ->
						{ewc, html_container, index, [A, {data, Data}]};
				false ->
%						{ewc, A}
                        {data, Data}
			end
		end}.
