defmodule Bonfire.UI.Topics.TopicHeroLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop category, :map, required: true
  prop permalink, :string, required: true
  prop object_boundary, :any, default: nil
  prop boundary_preset, :any, default: nil
  prop subcategories, :list, default: nil
  prop select_category_id, :any, default: nil
  prop user, :map, default: nil
end
