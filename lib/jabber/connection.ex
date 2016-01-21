defmodule Jabber.Connection do

  @behaviour :gen_fsm

  require Logger
  
  @initial_state %{socket: nil, component_pid: nil, parser: nil}

  ## public API
  
  def start(opts) do
    :gen_fsm.start(__MODULE__, opts, [])
  end

  def send(conn_ref, xml) do
    :gen_fsm.send_event(conn_ref, {:send, :exml.to_binary(xml)})
  end

  ## connected state
  
  def connected({:send, data}, %{socket: socket} = state) do
    Logger.debug "SEND: #{inspect data}"
    :ok = :gen_tcp.send(socket, data)
    {:next_state, :connected, state}
  end
  
  ## :gen_fsm API
  
  def init(opts) do
    jid       = Keyword.fetch!(opts, :jid)
    host      = Keyword.fetch!(opts, :host)
    port      = Keyword.fetch!(opts, :port)
    pid       = Keyword.fetch!(opts, :pid)
    state     = @initial_state

    # trap exits
    Process.flag(:trap_exit, true)

    Logger.info "Component #{jid} connecting to #{host}:#{port}."
    
    socket_opts = [{:active, :once}, :binary, {:packet, 0}]
    case :gen_tcp.connect(host, port, socket_opts) do
      {:ok, socket} ->
        {:ok, parser} = :exml_stream.new_parser
        state = %{state | socket: socket, component_pid: pid, parser: parser}
    
        Logger.info "Component #{jid} connected to #{host}:#{port}."
    
        {:ok, :connected, state}
      {:error, reason} ->
        Logger.error "Component #{jid} failed to connect to #{host}:#{port}. reason=#{inspect reason}"
        {:stop, reason}
    end
  end

  def handle_info({:tcp, socket, data}, statename, %{component_pid: pid} = state) do
    Logger.debug "RECV: #{inspect data}"
    {:ok, parser, elements} = :exml_stream.parse(state.parser, data)
    Enum.each(elements, fn element ->
      Kernel.send(pid, element)
    end)
    :inet.setopts(socket, [{:active, :once}])
    {:next_state, statename, %{state | parser: parser}}
  end

  def handle_info({:tcp_closed, _socket}, _statename, state) do
    Logger.info "Connection closed."
    {:stop, :normal, state}
  end

  def handle_info({:EXIT, pid, reason}, statename,
                  %{component_pid: component_pid} = state) when component_pid == pid do
    ## got EXIT from component process so we will terminate as well
    {:stop, reason, statename, state}
  end
  
  def handle_event(_event, _statename, state) do
    {:stop, {:error, :not_implemented}, state}
  end

  def handle_sync_event(_event, _from, _statename, state) do
    {:stop, {:error, :not_implemented}, state}
  end

  def code_change(_oldvsn, statename, state, _extra) do
    {:ok, statename, state}
  end

  def terminate(_reason, _statename, %{socket: socket, parser: parser} = _state) do
    :ok = :gen_tcp.close(socket)
    :ok = :exml_stream.free_parser(parser)
  end

end
