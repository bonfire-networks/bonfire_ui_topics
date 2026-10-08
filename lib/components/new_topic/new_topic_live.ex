defmodule Bonfire.UI.Topics.NewTopicLive do
  use Bonfire.UI.Common.Web, :stateless_component

  @doc "DOM id of the modal opener. Give each instance on a page its own."
  prop id, :string, default: "new_topic"

  prop parent, :any, default: nil
  prop label, :string, default: nil

  @doc "Wrapper around the open button, see `Bonfire.UI.Common.OpenModalLive`."
  prop open_modal_wrapper_class, :css_class, default: nil

  @doc "Classes of the open `<button>` itself."
  prop open_btn_wrapper_class, :css_class, default: "block"

  @doc "Content of the open button. Defaults to a dropdown menu item."
  slot open_btn

  defp title(prefix, parent) when is_binary(parent),
    do: prefix <> " " <> l("in %{parent_category}", parent_category: parent)

  defp title(prefix, _), do: prefix
end
