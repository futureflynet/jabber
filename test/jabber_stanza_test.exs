defmodule JabberStanzaTest do
  use ExUnit.Case
  use Jabber.Xml

  require Record
  
  alias Jabber.Stanza.Message
  alias Jabber.Stanza.Presence
  alias Jabber.Stanza.Iq
  alias Jabber.Stanza
  alias Jabber.Jid

  test "message to xml" do
    msg_xml = %Message{id: "test_id", to: Jid.new("to@test.host"),
                       from: Jid.new("from@test.host"), body: "hello"}
    |> Stanza.to_xml

    assert Record.is_record(msg_xml, :xmlel)
    
    attrs = xmlel(msg_xml, :attrs)
    
    {"id", "test_id"}          = List.keyfind(attrs, "id", 0)
    {"to", "to@test.host"}     = List.keyfind(attrs, "to", 0)
    {"from", "from@test.host"} = List.keyfind(attrs, "from", 0)
    {"type", "normal"}         = List.keyfind(attrs, "type", 0)
  end

  test "message from xml" do
    msg_xml = xmlel(name: "message",
                    attrs: [{"to", "to@test.host"},
                            {"from", "from@test.host"},
                            {"type", "chat"}],
                    children: [xmlel(name: "body", children: [xmlcdata(content: "content")])])
    msg = Stanza.new(msg_xml)

    assert msg.id   == nil
    assert msg.to   == Jid.new "to@test.host"
    assert msg.from == Jid.new "from@test.host"
    assert msg.type == "chat"
    assert msg.body == "content"
  end
  
  test "message from xml not type" do
    msg_xml = xmlel(name: "message",
                    attrs: [{"to", "to@test.host"},
                            {"from", "from@test.host"}],
                    children: [xmlel(name: "body", children: [xmlcdata(content: "content")])])
    msg = Stanza.new(msg_xml)

    assert msg.id   == nil
    assert msg.to   == Jid.new "to@test.host"
    assert msg.from == Jid.new "from@test.host"
    assert msg.type == "normal"
    assert msg.body == "content"
  end

  test "message attributes" do
    msg = %Message{attrs: [{"to", "to@test.host"}]}
    msg_xml = Stanza.to_xml(msg)
    assert msg_xml == xmlel(name: "message", attrs: [{"type", "normal"}])
    
    msg = %Message{to: "to@test.host", from: "from@test.host", id: "test_id",
                   attrs: [{"to", "to"}, {"from", "from"}, {"id", "id"}]}
    msg_xml = Stanza.to_xml(msg)
    assert msg_xml == {:xmlel, "message",
                       [{"from", "from@test.host"}, {"id", "test_id"},
                        {"to", "to@test.host"}, {"type", "normal"}], []}
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
    assert iq.to       == Jid.new "to@test.host"
    assert iq.from     == Jid.new "from@test.host"
    assert iq.type     == "get"
    assert iq.children != []
  end

  test "iq to result" do
    iq = %Iq{id: "test_id", to: Jid.new("to@test.host"),
             from: Jid.new("from@test.host"), type: "set",
             children: [xmlel(name: "vCard", attrs: [{"xmlns", "vcard-temp"}])]}
    result_iq = Iq.to_result(iq, xmlel(name: "FN", children: [xmlcdata(content: "name")]))

    assert result_iq.to       == Jid.new "from@test.host"
    assert result_iq.from     == Jid.new "to@test.host"
    assert result_iq.type     == "result"
    assert result_iq.id       == "test_id"
    assert result_iq.children != []
  end
  
  test "presence to xml" do
    # initial presence
    presence_xml = %Presence{} |> Stanza.to_xml
    assert Record.is_record(presence_xml, :xmlel)
    {:xmlel, "presence", [], []} = presence_xml

    presence_xml = %Presence{type: "subscribe"} |> Stanza.to_xml
    assert Record.is_record(presence_xml, :xmlel)
    {"type", "subscribe"} = List.keyfind(xmlel(presence_xml, :attrs), "type", 0)
  end

  test "presence from xml" do
    presence_xml = xmlel(name: "presence", attrs: [{"type", "probe"}])
    presence = Stanza.new(presence_xml)

    assert presence.type == "probe"
  end
  
end
