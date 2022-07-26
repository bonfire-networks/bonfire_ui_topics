defmodule Bonfire.Classify.Web.CategoryLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  alias Bonfire.Classify.Web.CategoryLive.SubcategoriesLive
  alias Bonfire.Classify.Web.CommunityLive.CommunityCollectionsLive
  alias Bonfire.Classify.Web.CollectionLive.CollectionResourcesLive

  alias Bonfire.UI.Me.LivePlugs

  def mount(params, session, socket) do
    live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      # LivePlugs.LoadCurrentUserCircles,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ]
  end

  defp mounted(params, _session, socket) do

    top_level_category = System.get_env("TOP_LEVEL_CATEGORY", "")

    id =
      if !is_nil(params["id"]) and params["id"] != "" do
        params["id"]
      else
        if !is_nil(params["username"]) and params["username"] != "" do
          params["username"]
        else
          top_level_category
        end
      end

    {:ok, category} =
      Bonfire.Classify.Categories.get(id, [:default_incl_deleted]) # TODO: query with boundaries
        |> repo().maybe_preload([
          parent_category: [:profile, :character, parent_category: [:profile, :character]]
      ])

    {:ok, subcategories} =
      Bonfire.Classify.GraphQL.CategoryResolver.category_children(
        %{id: ulid!(category)},
        %{limit: 15},
        %{context: %{current_user: current_user(socket)}}
      )

    # debug(category)

    {:ok,
     socket
     |> assign(
      page: "topics",
      object_type: nil,
      feed: [],
      selected_tab: :timeline,
      smart_input_text: "+#{e(category, :character, :username, nil)} ",
      category: category,
      subcategories: subcategories.edges,
      page_title: e(category, :profile, :name, l "Untitled topic"),
      current_context: category,
      object_boundary: Bonfire.Boundaries.Controlleds.get_preset_on_object(category) |> debug("object_boundary"),

      sidebar_widgets: [
        users: [
          main: [],
          secondary: [
            {Bonfire.Classify.Web.WidgetSubtopicsLive, [widget_title: l("Sub-topics of %{topic}", topic: e(category, :character, :username, nil)), subcategories: subcategories.edges]},
            {Bonfire.UI.Common.WidgetFeedbackLive, []}
          ]
        ]
      ]
    )}

  end

  def tab(selected_tab) do
    case maybe_to_atom(selected_tab) do
      tab when is_atom(tab) -> tab
      _ -> :timeline
    end
    # |> debug
  end

  def do_handle_params(%{"tab" => tab} = params, _url, socket) when tab in ["posts", "boosts", "timeline"] do
    Bonfire.Social.Feeds.LiveHandler.user_feed_assign_or_load_async(tab, e(socket.assigns, :category, nil), params, socket)
  end

  def do_handle_params(%{"tab" => "submitted" = tab} = params, _url, socket) do
    # Bonfire.Social.Feeds.LiveHandler.user_feed_assign_or_load_async("timeline", {tab, e(socket.assigns, :category, :character, :notifications_id, nil) |> debug("notifications_id")}, params, socket) # FIXME
    {:noreply,
        assign(socket,
        Bonfire.Social.Feeds.LiveHandler.load_user_feed_assigns(tab, e(socket.assigns, :category, :character, :notifications_id, nil) |> debug("notifications_id"), params, socket)
    )}
  end

  def do_handle_params(%{"tab" => tab} = params, _url, socket) when tab in ["followers"] do
    {:noreply,
      assign(socket,
        Bonfire.Social.Feeds.LiveHandler.load_user_feed_assigns(tab, e(socket.assigns, :category, nil), params, socket)
      )}
  end

  def do_handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, socket
      |> assign(selected_tab: tab)
    } # nothing defined
  end

  def do_handle_params(params, _url, socket) do
    # default tab
    do_handle_params(Map.merge(params || %{}, %{"tab" => "timeline"}), nil, socket)
  end

  def handle_params(params, uri, socket) do
    # poor man's hook I guess
    with {_, socket} <- Bonfire.UI.Common.LiveHandlers.handle_params(params, uri, socket) do
      undead_params(socket, fn ->
        do_handle_params(params, uri, socket)
      end)
    end
  end

  def handle_event(action, attrs, socket), do: Bonfire.UI.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)

end
