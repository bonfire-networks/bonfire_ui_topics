defmodule Bonfire.UI.Topics.TopicActionsLive do
  @moduledoc """
  A topic's actions, as the `<li>` items of a `Dropdown`: follow, the bell, Copy link, Get latest activities (a topic hosted elsewhere) and Topic settings. Each shows only to who may use it. Used by the selected topic's chip in a group (`Bonfire.UI.Groups.GroupTopicsNavLive`) and by a standalone topic's header (`Bonfire.UI.Topics.TopicHeroLive`), so the two menus stay the same.
  """
  use Bonfire.UI.Common.Web, :stateless_component

  prop topic, :any, required: true

  @doc "The topic's group, for a Copy link to the topic's page in the group when the topic has no federated id."
  prop group, :any, default: nil

  @doc "Whether to offer follow and the bell. Off where the page already has its own buttons for them."
  prop show_follow, :boolean, default: true

  @doc "Whether to offer Topic settings, see `Bonfire.Classify.ensure_update_allowed/3`. Decided by the page, once; when `nil`, decided here for the signed-in user."
  prop can_edit_topic, :any, default: nil

  def render(assigns) do
    assigns
    |> assign(:can_edit, can_edit?(assigns))
    |> render_sface()
  end

  defp can_edit?(%{can_edit_topic: nil, topic: topic} = assigns) do
    user = current_user(assigns[:__context__])
    not is_nil(user) and Bonfire.Classify.ensure_update_allowed(user, topic) == true
  end

  defp can_edit?(%{can_edit_topic: can_edit}), do: can_edit == true

  @doc "The DOM id of the bell, which the menu's trigger can ask to load when the menu first opens (see `Bonfire.UI.Common.DropdownLive.load_on_first_open/2`)."
  def bell_id(topic), do: "group_topic_bell_#{id(topic)}"

  @doc "The topic's link to copy: its federated id, else its page in the group, else its own page."
  def copy_url(topic, group) do
    Bonfire.Common.URIs.canonical_url(topic) ||
      if(group, do: Bonfire.Classify.Web.GroupNavigation.topic_path(group, topic)) ||
      Bonfire.Common.URIs.path(topic)
  end
end
