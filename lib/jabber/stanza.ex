defmodule Jabber.Stanza do

  use Jabber.Xml

  defmodule Message do
    defstruct attrs: [], children: []
  end

  defmodule Presence do
    defstruct attrs: [], children: []
  end

  defmodule Iq do
    defstruct attrs: [], children: []
  end
  
  def stream(to, xmlns) do
    xmlstreamstart(
      name: "stream:stream",
      attrs: [{"xmlns:stream", "http://etherx.jabber.org/streams"},
              {"xmlns", xmlns}, {"to", to}])
  end

  def new(xmlel(name: "message", attrs: attrs, children: children)) do
    %Message{attrs: attrs, children: children}
  end

  def new(xmlel(name: "presence", attrs: attrs, children: children)) do
    %Presence{attrs: attrs, children: children}
  end

  def new(xmlel(name: "iq", attrs: attrs, children: children)) do
    %Iq{attrs: attrs, children: children}
  end
  
end
