defmodule Bonfire.UI.Topics.TopicHeroLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop category, :map, required: true
  prop permalink, :string, required: true
  prop object_boundary, :any, default: nil
  prop boundary_preset, :any, default: nil
  @doc "The parent group, for its banner; `nil` for a top-level topic."
  prop user, :any, default: nil

  @doc "Inside a group's frame (`Bonfire.UI.Groups.GroupLive`), under the group's header and topic chips: a bar with no banner or icon."
  prop compact, :boolean, default: false
end
