-module(log).
-compile(export_all).

%log(debug, FormatStr, Args) ->
%    gen_event:notify(error_logger, {debug_msg, group_leader(), {self(), FormatStr, Args}});

log(info,FormatStr, Args) ->
%    io:format(FormatStr, Args),
    error_logger:info_msg(FormatStr, Args);
log(warning, FormatStr, Args) ->
%    io:format(FormatStr, Args),
    error_logger:warning_msg(FormatStr, Args);
log(error, FormatStr, Args) ->
 %   io:format(FormatStr, Args),
    error_logger:error_msg(FormatStr, Args);
log(Level, FormatStr, Args) ->
    error_logger:error_msg("Unknown logging level ~p  ," ++ FormatStr,[Level|Args]).

info(FormatStr, Args) -> log(info, FormatStr, Args).
warn(FormatStr, Args) -> log(warning, FormatStr, Args).
error(FormatStr, Args) -> log(error, FormatStr, Args).    
