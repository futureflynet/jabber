defmodule JabberStanzaTest do
  use ExUnit.Case
  use Jabber.Xml

  require Record
  
  alias Jabber.Stanza.Message
  alias Jabber.Stanza.Presence
  alias Jabber.Stanza.Iq
  alias Jabber.Stanza

  test "message to xml" do
    msg_xml = %Message{id: "test_id", to: "to@test.host",
                       from: "from@test.host", body: "hello"}
    |> Stanza.to_xml

    assert Record.is_record(msg_xml, :xmlel)
    
    attrs = xmlel(msg_xml, :attrs)
    {"id", "test_id"}          = List.keyfind(attrs, "id", 0)
    {"to", "to@test.host"}     = List.keyfind(attrs, "to", 0)
    {"from", "from@test.host"} = List.keyfind(attrs, "from", 0)
    {"type", "chat"}           = List.keyfind(attrs, "type", 0)
  end

  test "message from xml" do
    msg_xml = xmlel(name: "message",
                    attrs: [{"to", "to@test.host"},
                            {"from", "from@test.host"},
                            {"type", "chat"}],
                    children: [xmlel(name: "body", children: [xmlcdata(content: "content")])])
    msg = Stanza.new(msg_xml)

    assert msg.id   == nil
    assert msg.to   == "to@test.host"
    assert msg.from == "from@test.host"
    assert msg.type == "chat"
    assert msg.body == "content"
  end

  test "iq to xml" do
    iq_xml = %Iq{id: "test_id", to: "to@test.host", from: "from@test.host", type: "get"}
    |> Stanza.to_xml
    
    assert Record.is_record(iq_xml, :xmlel)
    assert xmlel(iq_xml, :name) == "iq"

    attrs = xmlel(iq_xml, :attrs)
    {"id", "test_id"}          = List.keyfind(attrs, "id", 0)
    {"to", "to@test.host"}     = List.keyfind(attrs, "to", 0)
    {"from", "from@test.host"} = List.keyfind(attrs, "from", 0)
    {"type", "get"}            = List.keyfind(attrs, "type", 0)
  end

  test "iq from xml" do
    iq_xml = xmlel(name: "iq",
                   attrs: [{"id", "test_id"},
                           {"to", "to@test.host"},
                           {"from", "from@test.host"},
                           {"type", "get"}],
                   children: [xmlel(name: "vCard", attrs: [{"xmlns", "vcard-temp"}])])
    iq = Stanza.new(iq_xml)

    assert iq.id       == "test_id"
    assert iq.to       == "to@test.host"
    assert iq.from     == "from@test.host"
    assert iq.type     == "get"
    assert iq.children != []
  end

  test "iq to result" do
    iq = %Iq{id: "test_id", to: "to@test.host",
             from: "from@test.host", type: "set",
             children: [xmlel(name: "vCard", attrs: [{"xmlns", "vcard-temp"}])]}
    result_iq = Iq.to_result(iq, xmlel(name: "FN", children: [xmlcdata(content: "name")]))

    assert result_iq.to       == "from@test.host"
    assert result_iq.from     == "to@test.host"
    assert result_iq.type     == "result"
    assert result_iq.id       == "test_id"
    assert result_iq.children != []
  end
  
  test "presence to xml" do
    presence_xml = %Presence{} |> Stanza.to_xml
    assert Record.is_record(presence_xml, :xmlel)
    assert xmlel(presence_xml, :name) == "presence"
  end
  
end
