defmodule Jabber.Stanza do

  use Jabber.Xml

  alias Jabber.Jid
  alias Jabber.Stanza.Iq
  alias Jabber.Stanza.Message
  alias Jabber.Stanza.Presence

  def stream_start(to, xmlns) do
    xmlstreamstart(
      name: "stream:stream",
      attrs: [{"xmlns:stream", "http://etherx.jabber.org/streams"},
              {"xmlns", xmlns}, {"to", to}])
  end

  def stream_end do
    xmlstreamend(name: "stream:stream")
  end

  def new(xmlel(name: "message", attrs: attrs, children: children) = xml) do
    {"id", id}       = List.keyfind(attrs, "id", 0, {"id", nil})
    {"to", to}       = List.keyfind(attrs, "to", 0, {"to", nil})
    {"from", from}   = List.keyfind(attrs, "from", 0, {"from", nil})
    {"type", type}   = List.keyfind(attrs, "type", 0, {"type", "normal"})
    {"updateNotification", notification} = List.keyfind(attrs, "updateNotification", 0, {"updateNotification", ""})

    attrs = List.keydelete(attrs, "id", 0)
    attrs = List.keydelete(attrs, "to", 0)
    attrs = List.keydelete(attrs, "from", 0)
    attrs = List.keydelete(attrs, "type", 0)
    attrs = List.keydelete(attrs, "updateNotification", 0)

    body        = get_child(xml, "body") |> get_cdata
    nick        = get_child(xml, "nick") |> get_cdata
    thread      = get_child(xml, "thread") |> get_cdata
    move        = get_child(xml, "animationMove") |> get_cdata
    target      = get_child(xml, "animationTargetId") |> get_cdata
    target_nick = get_child(xml, "animationTargetNick") |> get_cdata
    width       = get_child(xml, "width") |> get_cdata
    height      = get_child(xml, "height") |> get_cdata
    url         = get_child(xml, "url") |> get_cdata

    %Message{id: id, to: Jid.new(to), from: Jid.new(from), type: type, body: body,
             thread: thread, attrs: attrs, children: children, nick: nick,
             animationMove: move, animationTargetId: target, animationTargetNick: target_nick,
             updateNotification: notification, imageUrl: url, imageWidth: width, imageHeight: height}
  end

  def new(xmlel(name: "presence", attrs: attrs, children: children)) do
    {"to", to}     = List.keyfind(attrs, "to", 0, {"to", nil})
    {"from", from} = List.keyfind(attrs, "from", 0, {"from", nil})
    {"type", type} = List.keyfind(attrs, "type", 0, {"type", nil})

    attrs = List.keydelete(attrs, "to", 0)
    attrs = List.keydelete(attrs, "from", 0)
    attrs = List.keydelete(attrs, "type", 0)

    %Presence{to: Jid.new(to), from: Jid.new(from), type: type,
              attrs: attrs, children: children}
  end

  def new(xmlel(name: "iq", attrs: attrs, children: children)) do
    {"id", id}     = List.keyfind(attrs, "id", 0, {"id", nil})
    {"to", to}     = List.keyfind(attrs, "to", 0, {"to", nil})
    {"from", from} = List.keyfind(attrs, "from", 0, {"from", nil})
    {"type", type} = List.keyfind(attrs, "type", 0, {"type", nil})

    attrs = List.keydelete(attrs, "id", 0)
    attrs = List.keydelete(attrs, "to", 0)
    attrs = List.keydelete(attrs, "from", 0)
    attrs = List.keydelete(attrs, "type", 0)

    %Iq{id: id, to: Jid.new(to), from: Jid.new(from), type: type,
        attrs: attrs, children: children}
  end

  def to_xml(%{to: to, from: from} = stanza) do
    stanza_to_xml(%{stanza | to: to_string(to), from: to_string(from)})
  end
  def to_xml(stanza), do: stanza_to_xml(stanza)

  defp stanza_to_xml(%Message{} = msg) do
    attrs = attrs_to_binary(msg.attrs, %{"id" => msg.id, "to" => msg.to, "from" => msg.from,
                                         "type" => msg.type, "updateNotification" => msg.updateNotification})
    children = msg.children
    |> add_child("body", msg.body)
    |> add_child("thread", msg.thread)
    xmlel(name: "message", attrs: attrs, children: children)
  end

  defp stanza_to_xml(%Presence{} = presence) do
    attrs = attrs_to_binary(presence.attrs, %{"id" => nil, "to" => presence.to, "from" => presence.from, "type" => presence.type})
    xmlel(name: "presence", attrs: attrs, children: presence.children)
  end

  defp stanza_to_xml(%Iq{} = iq) do
    attrs = attrs_to_binary(iq.attrs, %{"id" => iq.id, "to" => iq.to, "from" => iq.from, "type" => iq.type})
    xmlel(name: "iq", attrs: attrs, children: iq.children)
  end

  def has_child?(stanza, name, ns) do
    Enum.member?(stanza.children, xmlel(name: name, attrs: [{"xmlns", ns}]))
  end

  ## private API

  defp attrs_to_binary(attrs, new_attrs) do
    attrs
    |> Enum.into(%{}, fn {k, v} -> {to_string(k), v} end)
    |> Map.merge(new_attrs)
    |> Enum.filter(fn {_k, v} -> v != nil and v != "" end)
  end

  defp add_child(children, _name, nil), do: children
  defp add_child(children, name, content) do
    child_xml = xmlel(name: name, children: [:exml.escape_cdata(content)])
    [child_xml|children]
  end

end
