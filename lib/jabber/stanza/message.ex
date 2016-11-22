defmodule Jabber.Stanza.Message do

  use Jabber.Xml

  alias Jabber.Stanza.Message

  defstruct(id: nil, to: nil, from: nil, type: "normal", body: nil,
            thread: nil, attrs: [], children: [], nick: nil, animationMove: nil, animationTarget: nil)

  def receipt(msg) do
    %Message{to: msg.from, from: msg.to, id: msg.id,
             children: [xmlel(name: "received",
                              attrs: [{"id", msg.id}, {"xmlns", "urn:xmpp:receipts"}])]}
  end

end
