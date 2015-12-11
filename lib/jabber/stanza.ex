defmodule Jabber.Stanza do

  use Jabber.Xml

  defmodule Message do
    defstruct(id: nil, to: nil, from: nil, type: "chat", body: "",
              extra_attrs: [], extra_children: [])
  end

  defmodule Presence do
    defstruct attrs: [], children: []
  end

  defmodule Iq do
    use Jabber.Xml
    
    defstruct(id: nil, to: nil, from: nil, type: nil,
              extra_attrs: [], children: [])
    
    def to_result(%Iq{type: type} = iq, result \\ []) when type == "get" or type == "set" do
      [child] = iq.children
      child = xmlel(child, children: result)
      %Iq{iq | to: iq.from, from: iq.to, type: "result", children: [child]}
    end
  end
  
  def stream(to, xmlns) do
    xmlstreamstart(
      name: "stream:stream",
      attrs: [{"xmlns:stream", "http://etherx.jabber.org/streams"},
              {"xmlns", xmlns}, {"to", to}])
  end

  def new(xmlel(name: "message", attrs: attrs, children: children) = xml) do
    {"id", id}     = List.keyfind(attrs, "id", 0, {"id", nil})
    {"to", to}     = List.keyfind(attrs, "to", 0, {"to", nil})
    {"from", from} = List.keyfind(attrs, "from", 0, {"from", nil})
    {"type", type} = List.keyfind(attrs, "type", 0, {"type", nil})
    
    attrs
    |> List.keydelete("id", 0)
    |> List.keydelete("to", 0)
    |> List.keydelete("from", 0)
    |> List.keydelete("type", 0)
    
    body = get_child(xml, "body") |> get_cdata
    
    %Message{id: id, to: to, from: from, type: type, body: body,
             extra_attrs: attrs, extra_children: children}
  end

  def new(xmlel(name: "presence", attrs: attrs, children: children)) do
    %Presence{attrs: attrs, children: children}
  end

  def new(xmlel(name: "iq", attrs: attrs, children: children)) do
    {"id", id}     = List.keyfind(attrs, "id", 0, {"id", nil})
    {"to", to}     = List.keyfind(attrs, "to", 0, {"to", nil})
    {"from", from} = List.keyfind(attrs, "from", 0, {"from", nil})
    {"type", type} = List.keyfind(attrs, "type", 0, {"type", nil})
    
    attrs
    |> List.keydelete("id", 0)
    |> List.keydelete("to", 0)
    |> List.keydelete("from", 0)
    |> List.keydelete("type", 0)
    
    %Iq{id: id, to: to, from: from, type: type,
        extra_attrs: attrs, children: children}
  end
  
  def to_xml(%Message{} = msg) do
    extra_attrs = Enum.map(msg.extra_attrs, fn (k, v) -> {to_string(k), v} end)
    attrs = [{"to", msg.to}, {"from", msg.from}, {"type", msg.type}] ++ extra_attrs
    if msg.id != nil do
      attrs = [{"id", msg.id} | attrs]
    end
    body = xmlel(name: "body", children: [xmlcdata(content: msg.body)])
    children = [body] ++ msg.extra_children
    xmlel(name: "message", attrs: attrs, children: children)
  end

  def to_xml(%Presence{} = stanza) do
    xmlel(name: "presence", attrs: stanza.attrs, children: stanza.children)
  end

  def to_xml(%Iq{} = iq) do
    extra_attrs = Enum.map(iq.extra_attrs, fn (k, v) -> {to_string(k), v} end)
    attrs = [{"id", iq.id}, {"to", iq.to},
             {"from", iq.from}, {"type", iq.type}] ++ extra_attrs
    xmlel(name: "iq", attrs: attrs, children: iq.children)
  end
  
end
