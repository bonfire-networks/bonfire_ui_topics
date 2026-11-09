defmodule Bonfire.UI.Topics.TopicAboutLive do
  @moduledoc """
  What a topic says about itself: its full federated address (copyable) and its description, when it has one. The same block shows under a group's topic tabs (`Bonfire.UI.Groups.GroupLive`) and in a standalone topic's header (`Bonfire.UI.Topics.TopicHeroLive`).

  Needs `profile` and `character.peered` loaded on the topic, as `Bonfire.Classify.LiveHandler` does for a topic page.
  """
  use Bonfire.UI.Common.Web, :stateless_component

  prop category, :any, required: true

  @doc "Makes the address's DOM id unique when it shows more than once on a page: the `Copy` hook needs one."
  prop id_prefix, :string, default: "group-topic-address"

  @doc "Classes for the address."
  prop address_class, :css_class, default: "block text-sm text-muted"
end
