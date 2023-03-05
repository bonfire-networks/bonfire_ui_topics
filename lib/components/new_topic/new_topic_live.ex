defmodule Bonfire.UI.Topics.NewTopicLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop parent, :any, default: nil
  prop label, :string, default: nil

  defp title(prefix, parent) when is_binary(parent),
    do: prefix <> " " <> l("in %{parent_category}", parent_category: parent)

  defp title(prefix, _), do: prefix
end
