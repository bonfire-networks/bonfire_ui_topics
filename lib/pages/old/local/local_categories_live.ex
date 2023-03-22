defmodule Bonfire.UI.Topics.LocalCategoriesLive do
  use Bonfire.UI.Common.Web, :stateful_component

  alias Bonfire.Me.Users

  declare_nav_link(l("Local topics"),
    href: "/topics/local",
    icon: "material-symbols:edit-location-alt-rounded"
  )

  def update(assigns, socket) do
    limit = Bonfire.Common.Config.get(:default_pagination_limit, 10)

    {:ok, categories} =
      Bonfire.Classify.GraphQL.CategoryResolver.categories_toplevel(
        %{limit: limit},
        %{context: %{current_user: current_user(socket)}}
      )

    {:ok,
     assign(
       socket,
       categories: e(categories, :edges, []),
       page_info: e(categories, :page_info, []),
       page: "topics",
       page_title: l("Topics"),
       selected_tab: "all",
       feed_title: l("Published in all known topics"),
       limit: limit,
       create_object_type: :category,
       smart_input_opts: %{prompt: l("Create a topic")},
       loading: false,
       smart_input: nil
     )}
  end

  def do_handle_event("topics:load_more", attrs, socket) do
    # debug(attrs)
    limit = e(socket.assigns, :limit, 10)

    {:ok, categories} =
      Bonfire.Classify.GraphQL.CategoryResolver.categories_toplevel(
        %{limit: limit, after: [e(attrs, "after", nil)]},
        %{context: %{current_user: current_user(socket)}}
      )

    # |> debug()

    {:noreply,
     assign(
       socket,
       categories: e(socket.assigns, :categories, []) ++ e(categories, :edges, []),
       page_info: e(categories, :page_info, [])
     )}
  end

  def do_handle_event("topics_followed:load_more", attrs, socket) do
    limit = e(socket.assigns, :limit, 10)

    categories =
      Bonfire.Social.Follows.list_my_followed(current_user_required!(socket),
        limit: limit,
        after: e(attrs, "after", nil),
        type: Bonfire.Classify.Category
      )

    page =
      categories
      |> e(:edges, [])
      |> Enum.map(&e(&1, :edge, :object, nil))

    # |> debug("TESTTTT")

    {:noreply,
     assign(
       socket,
       categories: e(socket.assigns, :categories, []) ++ page,
       page_info: e(categories, :page_info, [])
     )}
  end

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
          __MODULE__,
          &do_handle_event/3
        )
end
