defmodule JabberStanzaTest do
  use ExUnit.Case
  use Jabber.Xml

  require Record
  
  alias Jabber.Stanza.Message
  alias Jabber.Stanza.Presence
  alias Jabber.Stanza.Iq

  test "stanza to xml" do
    message_xml = %Message{} |> to_xml
    assert Record.is_record(:xmlel, message_xml)
    assert xmlel(message_xml, :name) == "message"

    presence_xml = %Presence{} |> to_xml
    assert Record.is_record(:xmlel, presence_xml)
    assert xmlel(presence_xml, :name) == "presence"
    
    iq_xml = %Message{} |> to_xml
    assert Record.is_record(:xmlel, iq_xml)
    assert xmlel(iq_xml, :name) == "iq"
  end
  
end
