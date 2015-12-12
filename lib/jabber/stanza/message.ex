defmodule Jabber.Stanza.Message do

  use Jabber.Xml
  
  defstruct(id: nil, to: nil, from: nil, type: "chat", body: "",
            extra_attrs: [], extra_children: [])
end
