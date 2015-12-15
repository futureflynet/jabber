defmodule JabberJidTest do
  use ExUnit.Case

  alias Jabber.Jid
  
  test "parse jid from string" do
    jid = Jid.new("test@domain/resource")
    assert %Jid{id: "test", domain: "domain", resource: "resource"} == jid
  end

  test "parse bare jid from string" do
    jid = Jid.new("test@domain")
    assert %Jid{id: "test", domain: "domain"} == jid
  end

  test "jid to string" do
    jid_str = %Jid{id: "test", domain: "domain", resource: "resource"} |> to_string
    assert jid_str == "test@domain/resource"
  end
  
end
