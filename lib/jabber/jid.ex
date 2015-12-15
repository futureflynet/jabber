defmodule Jabber.Jid do

  defstruct id: nil, domain: nil, resource: nil
  
  def new(jid_str) do
    [id, rest]         = String.split(jid_str, "@")
    [domain, resource] = String.split(rest, "/")

    %Jabber.Jid{id: id, domain: domain, resource: resource}
  end
  
end

defimpl String.Chars, for: Jabber.Jid do

  def to_string(jid) do
    "#{jid.id}@#{jid.domain}/#{jid.resource}"
  end
  
end
