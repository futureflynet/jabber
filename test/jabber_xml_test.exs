defmodule JabberXmlTest do
  use ExUnit.Case

  use Jabber.Xml
  
  test "get attr" do
    xml = xmlel(name: "test", attrs: [{"key", "value"}])
    assert "value" == get_attr(xml, "key")
  end

  test "get child" do
    xml = xmlel(name: "test", children: [xmlel(name: "child")])
    assert xmlel(name: "child") == get_child(xml, "child")
  end

  test "get cdata" do
    xml = xmlel(name: "test", children: [xmlcdata(content: "data")])
    assert "data" == get_cdata(xml)
  end
  
end
