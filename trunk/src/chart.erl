-module(chart).
-compile(export_all).
%"http://chart.apis.google.com/chart?chxt=x,y,r&chxr=0,0,10|1,0,10|2,0,100&cht=lc&chco=76A4FB,FF0000,FF0000,FF0000&chls=2&chs=600x400&chd=t:0,30,60,70,90,95,50|20,30,40,50,60,70,.08|10,30,40,45,.522|80,70,40,25,.1".

generate() ->
    Prefix = "http://chart.apis.google.com/chart?",
    Options = buildOptions(userRampUp()),
    string:concat(Prefix, Options).

buildOptions(UserRampUp) ->
    AxisType = "chxt=x,y,r",
    Type = "cht=lc",
    Color = "chco=76A4FB",
    Size = "chs=600x400",
    LineStyle = "chls=2",
    Range = range(length(UserRampUp)),
    Data = string:concat("chd=t:", string:join(UserRampUp, ",")),
    string:join([AxisType, Range, Type, Color, Size, LineStyle, Data], "&").

userRampUp()->
    Ur = publisher:fetchRuntimeData(),
    log:info("Rampup ~p", [Ur]),
    [integer_to_list(X * 10) || {_, X} <- Ur].

range(Size)->
    XRange = string:concat("0,0,",integer_to_list(Size)),
    YRange = "1,0,10",
    RRange = "2,0,100",
    string:concat("chxr=", string:join([XRange, YRange, RRange],"|")).

    