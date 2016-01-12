defmodule Jabber.Stanza.Message do
  
  use Jabber.Xml

  alias Jabber.Stanza.Message
  
  defstruct(id: nil, to: nil, from: nil, type: "chat",
            body: nil, thread: nil, attrs: [], children: [])

  def receipt(msg) do
    %Message{to: msg.from, from: msg.to, id: msg.id,
             children: [xmlel(name: "received",
                              attrs: [{"id", msg.id}, {"xmlns", "urn:xmpp:receipts"}])]}
  end
  
end
