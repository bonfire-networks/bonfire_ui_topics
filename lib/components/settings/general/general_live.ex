defmodule Bonfire.UI.Topics.Settings.GeneralLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop selected_tab, :any, default: nil
  prop topic, :any, required: true
end
