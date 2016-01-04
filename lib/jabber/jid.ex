defmodule Jabber.Jid do

  defstruct id: nil, domain: nil, resource: nil

  def new(nil), do: nil
  def new(jid_str) do
    {id, rest}         = id_from_string(jid_str)
    {domain, resource} = domain_resource_from_string(rest)

    %Jabber.Jid{id: id, domain: domain, resource: resource}
  end

  ## internal API
  
  defp id_from_string(jid_str) do
    case String.split(jid_str, "@", parts: 2) do
      [id, rest] ->
        {id, rest}
      _ ->
        {nil, jid_str}
    end
  end
  
  defp domain_resource_from_string(str) do
    case String.split(str, "/", parts: 2) do
      [domain, resource] ->
        {domain, resource}
      _ ->
        {str, nil}
    end
  end
  
end

defimpl String.Chars, for: Jabber.Jid do
  
  def to_string(jid) do
    jid_str = "#{jid.id}@#{jid.domain}"
    
    if jid.resource != nil do
      jid_str <> "/#{jid.resource}"
    else
      jid_str
    end
  end
  
end
