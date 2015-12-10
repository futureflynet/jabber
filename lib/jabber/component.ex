defmodule Jabber.Component do

  @callback stream_started(state :: term) :: {:ok, term}
  @callback stanza_received(state :: term, stanza :: term) :: {:ok, term}
  
  defmacro __using__(_opts) do
    quote do
      use GenServer
      use Jabber.Xml

      alias Jabber.Connection
      alias Jabber.Stanza
      
      require Logger

      @stream_ns     "jabber:component:accept"
      @initial_state %{conn_pid: nil, stream_id: nil}

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts)
      end
      
      def init(opts) do
        jid      = Keyword.fetch!(opts, :jid)
        password = Keyword.fetch!(opts, :password)
        
        # start connection and link to it
        {:ok, conn_pid} = Connection.start([{:pid, self} | opts])
        true = Process.link(conn_pid)

        state = %{@initial_state | conn_pid: conn_pid}
        
        state
        |> start_stream(jid)
        |> handshake(password)
        
        {:ok, state, 0}
      end

      def stream_started(state) do
        # override this
        {:ok, state}
      end
      
      def stanza_received(state, _stanza) do
        # override this
        {:ok, state}
      end

      ## GenServer API

      def handle_info(:timeout, state) do
        # component has started
        {:ok, state} = stream_started(state)
        {:noreply, state}
      end
      
      def handle_info(xmlel() = xml, state) do
        stanza = Stanza.new(xml)
        state = stanza_received(state, stanza)
        {:noreply, state}
      end

      ## private API
      
      defp start_stream(state, jid) do
        stream_xml = Stanza.stream(jid, @stream_ns)
        :ok = Connection.send(state.conn_pid, stream_xml)
        
        wait_for_stream(state)
      end
      
      defp handshake(state, password) do
        content = :crypto.hash(:sha, "#{state.stream_id}#{password}")
        |> Base.encode16
        |> String.downcase
        
        cdata = xmlcdata(content: content)
        handshake_xml = xmlel(name: "handshake", children: [cdata])

        :ok = Connection.send(state.conn_pid, handshake_xml)
        {:ok, _} = recv("handshake")
        
        state
      end

      defp wait_for_stream(state) do
        receive do
          xmlstreamstart(attrs: attrs) ->
            {"id", stream_id} = List.keyfind(attrs, "id", 0)
            %{state | stream_id: stream_id}
          _ ->
            wait_for_stream(state)
        end
      end
      
      defp recv(name) do
        receive do
          xmlel(name: ^name) = element ->
            {:ok, element}
          _ ->
            recv(name)
        end
      end
      
      defoverridable [stream_started: 1, stanza_received: 2]
    end
  end
end
