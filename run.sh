#Uncomment these lines and set the ERL_CALL variable to spawn a new erlang shell to run tests from
#ERL_CALL=$ERL_HOME/lib/erl_interface/bin/i686-pc-linux-gnu/erl_call
#$ERL_CALL -sname worker -s
#$ERL_CALL -sname worker -a 'code add_path ["./ebin"]'
#$ERL_CALL -sname worker -a 'inets start'

echo ""
echo "Spawning $1 processes within $2 seconds."
erl -eval "perferl:run($1,$2, 'web_requests.perferl')" -sname main -noshell -pa ./ebin

