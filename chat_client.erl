-module(chat_client).
-export([start/1]).

start(ServerPid) ->
    case gen_server:call(ServerPid, {join, self()}) of
        ok ->
            io:format("Joined chat server!~n"),
            loop(ServerPid);
        {error, Reason} ->
            io:format("Failed to join chat server: ~p~n", [Reason])
    end.

loop(ServerPid) ->
    receive
        {message, FromPid, Message} ->
            io:format("Message from ~p: ~p~n", [FromPid, Message]),
            loop(ServerPid);
        {send, Message} ->
            gen_server:cast(ServerPid, {send_message, self(), Message}),
            loop(ServerPid);
        stop ->
            io:format("Leaving chat server~n"),
            ok;
        _Other ->
            loop(ServerPid)
    end.