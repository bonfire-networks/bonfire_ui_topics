defmodule Bonfire.UI.Topic.WidgetAboutLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop title, :string, default: "About this topic"
  prop about, :string, default: ""
  prop date, :string, default: "Today"
  prop icon, :string, default: nil
  prop parent, :string, default: nil
  prop parent_link, :string, default: nil
  prop boundary_preset, :any, default: nil
end
