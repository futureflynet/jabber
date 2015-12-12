defmodule Jabber.Stanza.Iq do

  use Jabber.Xml

  alias Jabber.Stanza.Iq

  defstruct(id: nil, to: nil, from: nil, type: nil,
            extra_attrs: [], children: [])


  def to_result(%Iq{type: type} = iq, result \\ []) when type == "get" or type == "set" do
    [child] = iq.children
    child = xmlel(child, children: result)
    %Iq{iq | to: iq.from, from: iq.to, type: "result", children: [child]}
  end
  
end
