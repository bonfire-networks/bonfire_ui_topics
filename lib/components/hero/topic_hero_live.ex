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

  @doc "The icon the topic has picked (`Bonfire.Classify.Appearance.icon/1`), shown when it has no uploaded image."
  def picked_icon(category) do
    category |> Bonfire.Classify.Appearance.preload() |> Bonfire.Classify.Appearance.icon()
  end

  @doc "The CSS class of the swatch the topic's band has when it has no banner: its own colour, its parent's, else one hashed from its id (loading the settings it reads, if the page has not: at most two queries)."
  def band_class(category) do
    category
    |> Bonfire.Classify.Appearance.preload()
    |> Bonfire.Classify.Appearance.colour()
    |> Bonfire.Common.Swatches.class()
  end
end
