defmodule Bonfire.Classify.Web.CategoryLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  alias Bonfire.Classify.Web.CategoryLive.SubcategoriesLive
  alias Bonfire.Classify.Web.CommunityLive.CommunityCollectionsLive
  alias Bonfire.Classify.Web.CollectionLive.CollectionResourcesLive

  alias Bonfire.UI.Me.LivePlugs

  def mount(params, session, socket) do
    live_plug(params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      # LivePlugs.LoadCurrentUserCircles,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ])
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

    # TODO: query with boundaries
    {:ok, category} = Bonfire.Classify.Categories.get(id, [:default_incl_deleted])

    if category.id == Bonfire.Classify.Web.LabelsLive.label_id() do
      {:ok,
       socket
       |> redirect_to(~p"/labels")}
    else
      category =
        category
        |> repo().maybe_preload([
          :creator,
          parent_category: [
            :profile,
            :character,
            parent_category: [:profile, :character]
          ]
        ])

      # TODO: query children with boundaries
      {:ok, subcategories} =
        Bonfire.Classify.GraphQL.CategoryResolver.category_children(
          %{id: ulid!(category)},
          %{limit: 15},
          %{context: %{current_user: current_user(socket)}}
        )
        |> debug("subcategories")

      name = e(category, :profile, :name, l("Untitled topic"))
      object_boundary = Bonfire.Boundaries.Controlleds.get_preset_on_object(category)

      {:ok,
       assign(
         socket,
         page: "topics",
         object_type: nil,
         feed: nil,
         without_sidebar: true,
         selected_tab: :timeline,
         tab_id: nil,
         #  custom_page_header:
         #    {Bonfire.Classify.Web.CategoryHeaderLive,
         #     category: category, object_boundary: object_boundary},
         smart_input_opts: [text: "+#{e(category, :character, :username, nil)} "],
         category: category,
         canonical_url: canonical_url(category),
         name: name,
         page_title: l("Topic"),
         interaction_type: l("follow"),
         subcategories: subcategories.edges,
         current_context: category,
         reply_to_id: category,
         object_boundary: object_boundary,
         #  create_object_type: :category,
         context_id: ulid(category),
         sidebar_widgets: [
           users: [
             secondary: nil
           ],
           guests: [
             secondary: nil
           ]
         ]
       )}
    end
  end

  def tab(selected_tab) do
    case maybe_to_atom(selected_tab) do
      tab when is_atom(tab) -> tab
      _ -> :timeline
    end

    # |> debug
  end

  def do_handle_params(%{"tab" => tab} = params, _url, socket)
      when tab in ["posts", "boosts", "timeline"] do
    Bonfire.Social.Feeds.LiveHandler.user_feed_assign_or_load_async(
      tab,
      e(socket.assigns, :category, nil),
      params,
      socket
    )
  end

  def do_handle_params(%{"tab" => tab, "tab_id" => tab_id}, _url, socket) do
    # debug(id)
    {:noreply,
     assign(socket,
       selected_tab: tab,
       tab_id: tab_id
     )}
  end

  def do_handle_params(%{"tab_id" => "suggestions" = tab_id} = params, _url, socket) do
    {:noreply,
     assign(
       socket,
       Bonfire.Social.Feeds.LiveHandler.load_user_feed_assigns(
         "submitted",
         e(socket.assigns, :category, :character, :notifications_id, nil),
         Map.put(
           params,
           :exclude_feed_ids,
           e(socket.assigns, :category, :character, :outbox_id, nil)
         ),
         socket
       )
     )}
  end

  # def do_handle_params(%{"tab" => "settings", "tab_id" => "submitted"} = params, _url, socket) do
  #   # Bonfire.Social.Feeds.LiveHandler.user_feed_assign_or_load_async("timeline", {tab, e(socket.assigns, :category, :character, :notifications_id, nil) |> debug("notifications_id")}, params, socket) # FIXME
  #   debug("QUIQUIQUI")
  #   {:noreply,
  #    assign(
  #      socket,
  #      Bonfire.Social.Feeds.LiveHandler.load_user_feed_assigns(
  #        tab,
  #        e(socket.assigns, :category, :character, :notifications_id, nil),
  #        Map.put(
  #          params,
  #          :exclude_feed_ids,
  #          e(socket.assigns, :category, :character, :outbox_id, nil)
  #        ),
  #        socket
  #      )
  #    )}
  # end

  def do_handle_params(%{"tab" => tab} = params, _url, socket)
      when tab in ["followers"] do
    {:noreply,
     assign(
       socket,
       Bonfire.Social.Feeds.LiveHandler.load_user_feed_assigns(
         tab,
         e(socket.assigns, :category, nil),
         params,
         socket
       )
     )}
  end

  def do_handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply,
     assign(socket,
       selected_tab: tab
     )}

    # nothing defined
  end

  def do_handle_params(params, _url, socket) do
    # default tab
    do_handle_params(
      Map.merge(params || %{}, %{"tab" => "timeline"}),
      nil,
      socket
    )
  end

  def handle_params(params, uri, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_params(
        params,
        uri,
        socket,
        __MODULE__,
        &do_handle_params/3
      )

  def handle_event(
        action,
        attrs,
        socket
      ),
      do:
        Bonfire.UI.Common.LiveHandlers.handle_event(
          action,
          attrs,
          socket,
          __MODULE__
          # &do_handle_event/3
        )

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
end
