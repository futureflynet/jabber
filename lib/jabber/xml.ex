defmodule Jabber.Xml do

  defmacro __using__(_opts) do
    quote do
      import unquote __MODULE__
      
      require Record
      import Record, only: [defrecordp: 2, extract: 2]
      
      defrecordp :xmlel, extract(:xmlel, from_lib: "exml/include/exml.hrl")
      defrecordp :xmlcdata, extract(:xmlcdata, from_lib: "exml/include/exml.hrl")
      defrecordp :xmlstreamstart, extract(:xmlstreamstart, from_lib: "exml/include/exml_stream.hrl")
      defrecordp :xmlstreamend, extract(:xmlstreamend, from_lib: "exml/include/exml_stream.hrl")

      def get_attr(element, name, default \\ nil) do
        :exml_query.attr(element, name, default)
      end

      def get_child(element, name, default \\ nil) do
        :exml_query.subelement(element, name, default)
      end

      def get_cdata(element) do
        :exml_query.cdata(element)
      end
      
    end
  end
end
