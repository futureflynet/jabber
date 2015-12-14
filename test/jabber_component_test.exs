defmodule JabberComponentTest do
  use ExUnit.Case
  
  defmodule TestComponent do
    
    use Jabber.Component

    def stream_started(state) do
      {:ok, state}
    end

    def handle_sync_event(:statename, _from, statename, state) do
      {:reply, statename, statename, state}
    end

    def handle_sync_event(:state, _from, statename, state) do
      {:reply, state, statename, state}
    end

    def handle_sync_event(:stop, _from, statename, state) do
      {:stop, :normal, statename, state}
    end
    
  end

  test "component start stream" do
    {:ok, pid} = TestComponent.start_link([jid: "test.localhost", host: "localhost",
                                           password: "secret", conn: Jabber.Connection])
    assert :stream_started == :gen_fsm.sync_send_all_state_event(pid, :statename)
  end
  
end
