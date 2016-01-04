defmodule Jabber.Stanza.Presence do

  use Jabber.Xml
  
  defstruct(to: nil, from: nil, type: nil, attrs: [], children: [])
  
end
