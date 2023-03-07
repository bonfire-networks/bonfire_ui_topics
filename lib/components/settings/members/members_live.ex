defmodule Bonfire.UI.Topics.Settings.MembersLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop selected_tab, :any, default: nil
  prop users, :list, required: true

end
