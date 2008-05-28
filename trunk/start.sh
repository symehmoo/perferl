#Yet to be implemented!!!!!


#ERL_CALL=$ERL_HOME/lib/erl_interface/bin/i686-pc-linux-gnu/erl_call
#
#$ERL_CALL -sname perferl -s
#$ERL_CALL -sname perferl -a 'code add_path ["/home/srk/dev/erlang/perferl/lib/yaws/ebin"]'
#$ERL_CALL -sname perferl -a 'code add_path ["/home/srk/dev/erlang/perferl/lib/erlyweb-0.6.2/ebin"]'
#
#$ERL_CALL -sname perferl -a 'yaws start_embedded ["/home/srk/dev/erlang/perferl/www",
#		[{servername, "srk"},
#  		 {listen, {0,0,0,0}},
#		 {port, 9080},
#		 {appmods, [{"/perferl", erlyweb}]},
#		 {opaque, [{"appname","perferl"}]}],
#        [{auth_log, true},
#         {logdir, "/home/srk/dev/erlang/perferl/log"},
#		 {copy_errlog, false}]]'
#$ERL_CALL -sname perferl -a 'erlyweb compile ["/home/srk/dev/erlang/perferl"]'
#
#$ERL_CALL -sname worker -s
#$ERL_CALL -sname worker -a 'code add_path ["/home/srk/dev/erlang/perferl/ebin"]'
#$ERL_CALL -sname worker -a 'inets start'
#
#
#echo "Started perferl"

