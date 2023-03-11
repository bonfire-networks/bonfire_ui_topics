defmodule Bonfire.UI.Topics.SettingsLive do
  use Bonfire.UI.Common.Web, :stateless_component
  import Bonfire.UI.Me.Integration

  prop selected_tab, :any, default: nil
  prop tab_id, :any, default: nil
  prop category, :any, required: true
  prop permalink, :any, required: true
  prop object_boundary, :any, default: nil

  def tab(selected_tab) do
    case maybe_to_atom(selected_tab) do
      tab when is_atom(tab) -> tab
      _ -> :timeline
    end
    |> debug(selected_tab)
  end
end
