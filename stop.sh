ERL_CALL=$ERL_HOME/lib/erl_interface/bin/i686-pc-linux-gnu/erl_call

$ERL_CALL -sname perferl -q
$ERL_CALL -sname worker -q
echo "Perferl terminated"


