defmodule Jabber.Component do

  @callback stream_started(state :: term) :: term
  @callback stream_authenticated(state :: term) :: term
  @callback stanza_received(state :: term, stanza :: term) :: term
  
  defmacro __using__(_opts) do
    quote location: :keep do

      use GenServer
      use Jabber.Xml

      alias Jabber.Stanza
      
      require Logger

      @stream_ns     "jabber:component:accept"
      @initial_state %{conn: nil, conn_pid: nil,
                       jid: nil, stream_id: nil,
                       password: nil, opts: []}

      def start_link(args) do
        GenServer.start_link(__MODULE__, args)
      end

      ## component behaviour callbacks
      
      def stream_started(state) do
        # override this
        state
      end
      
      def stream_authenticated(state) do
        # override this
        state
      end
      
      def stanza_received(state, _stanza) do
        # override this
        state
      end
      
      ## GenServer API

      def init(args) do
        jid      = Keyword.fetch!(args, :jid)
        password = Keyword.fetch!(args, :password)

        opts     = Keyword.get(args, :opts, [])
        conn     = Keyword.get(args, :conn, Jabber.Connection)

        Logger.debug "Jabber.Component starting using args #{inspect args}."
        
        # trap exits
        Process.flag(:trap_exit, true)
        
        # start connection and link to it
        {:ok, conn_pid} = conn.start([{:pid, self} | args])
        true = Process.link(conn_pid)
        
        state = %{@initial_state | jid: jid, conn: conn, conn_pid: conn_pid,
                  password: password, opts: opts}
        
        state = state
        |> start_stream(jid)
        |> wait_for_stream
        |> do_handshake

        {:ok, state}
      end
      
      def handle_info(xmlel() = xml, state) do
        stanza = Stanza.new(xml)
        state = stanza_received(state, stanza)
        {:noreply, state}
      end

      def handle_cast({:send, stanza}, %{conn: conn, conn_pid: conn_pid} = state) do
        :ok = conn.send(conn_pid, Stanza.to_xml(stanza))
        {:noreply, state}
      end
      
      def terminate(_reason, %{conn: conn, conn_pid: conn_pid} = state) do
        stream_xml = Stanza.stream_end
        :ok = conn.send(conn_pid, stream_xml)
      end

      ## private API
      
      defp start_stream(%{conn: conn, conn_pid: conn_pid} = state, jid) do
        stream_xml = Stanza.stream_start(jid, @stream_ns)
        :ok = conn.send(conn_pid, stream_xml)
        state
      end
      
      defp do_handshake(%{conn: conn, conn_pid: conn_pid, password: password} = state) do
        content = :crypto.hash(:sha, "#{state.stream_id}#{password}")
        |> Base.encode16
        |> String.downcase
        
        cdata = xmlcdata(content: content)
        handshake_xml = xmlel(name: "handshake", children: [cdata])

        :ok = conn.send(conn_pid, handshake_xml)
        case recv() do
          {:ok, xmlel(name: "handshake")} ->
            stream_authenticated(state)
          {:ok, xmlel(name: "stream:error") = error} ->
            {:error, error}
        end
      end

      defp wait_for_stream(state) do
        receive do
          xmlstreamstart(attrs: attrs) ->
            {"id", stream_id} = List.keyfind(attrs, "id", 0)
            state = %{state | stream_id: stream_id}
            stream_started(state)
          _ ->
            wait_for_stream(state)
        end
      end
      
      defp recv() do
        receive do
          xmlel() = element ->
            {:ok, element}
          xmlel(name: "stream:error") = element ->
            {:error, element}
          _ ->
            recv()
        end
      end
      
      defp recv(name) when is_binary(name) do
        receive do
          xmlel(name: ^name) = element ->
            {:ok, element}
          xmlel(name: "stream:error") = element ->
            {:error, element}
          _ ->
            recv(name)
        end
      end
      
      defoverridable [stream_started: 1, stream_authenticated: 1, stanza_received: 2]
    end
  end
end
