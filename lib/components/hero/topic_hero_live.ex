defmodule Bonfire.UI.Topics.TopicHeroLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop category, :map, required: true
  prop permalink, :string, required: true
  prop object_boundary, :any, default: nil
  prop boundary_preset, :any, default: nil
  prop subcategories, :list, default: nil
  prop selected_category_id, :any, default: nil
  # `user` is the parent group (when rendering a topic nested in a group); it
  # is `nil` for a top-level topic, so keep the type permissive to allow nil.
  prop user, :any, default: nil
end
