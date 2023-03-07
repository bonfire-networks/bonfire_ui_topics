defmodule Bonfire.UI.Topics.Settings.ModerationLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop selected_tab, :any, default: nil
  prop feed, :any, required: true
end
