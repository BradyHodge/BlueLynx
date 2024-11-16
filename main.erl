-module(main).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-record(state, {clients = [] :: list()}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, #state{clients = []}}.

handle_call({join, Pid}, _From, State = #state{clients = Clients}) ->
    {reply, ok, State#state{clients = [Pid | Clients]}};

handle_call(stop, _From, State) ->
    {stop, normal, ok, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({send_message, Pid, Message}, State = #state{clients = Clients}) ->
    broadcast_message(Clients, Pid, Message),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({'DOWN', _Ref, process, Pid, _Reason}, State = #state{clients = Clients}) ->
    NewClients = lists:delete(Pid, Clients),
    {noreply, State#state{clients = NewClients}};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

broadcast_message(Clients, FromPid, Message) ->
    lists:foreach(
        fun(ToPid) when ToPid /= FromPid ->
            ToPid ! {message, FromPid, Message};
           (_) ->
            ok
        end,
        Clients
    ).