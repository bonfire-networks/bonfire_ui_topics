defmodule Bonfire.UI.Topic.WidgetAboutLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop title, :string, default: "About this topic"
  prop about, :string, default: ""
  prop date, :string, default: "Today"
  prop icon, :string, default: nil
  prop group, :string, default: nil
  prop group_link, :string, default: nil

end
