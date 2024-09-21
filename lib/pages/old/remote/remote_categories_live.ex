defmodule Bonfire.UI.Topics.RemoteCategoriesLive do
  use Bonfire.UI.Common.Web, :stateful_component

  alias Bonfire.Me.Users

  # declare_nav_link(l("Remote topics"),
  #   href: "/topics/remote",
  #   icon: "material-symbols:edit-location-alt-rounded"
  # )

  def update(assigns, socket) do
    limit = Bonfire.Common.Config.get(:default_pagination_limit, 10)

    {:ok, categories} =
      Bonfire.Classify.GraphQL.CategoryResolver.categories_toplevel(
        %{limit: limit},
        %{context: %{current_user: current_user(assigns(socket))}}
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
       loading: false,
       smart_input: nil
     )}
  end

  def handle_event("topics:load_more", attrs, socket) do
    # debug(attrs)
    limit = e(assigns(socket), :limit, 10)

    {:ok, categories} =
      Bonfire.Classify.GraphQL.CategoryResolver.categories_toplevel(
        %{limit: limit, after: [e(attrs, "after", nil)]},
        %{context: %{current_user: current_user(assigns(socket))}}
      )

    # |> debug()

    {:noreply,
     assign(
       socket,
       categories: e(assigns(socket), :categories, []) ++ e(categories, :edges, []),
       page_info: e(categories, :page_info, [])
     )}
  end

  def handle_event("topics_followed:load_more", attrs, socket) do
    limit = e(assigns(socket), :limit, 10)

    categories =
      Bonfire.Social.Graph.Follows.list_my_followed(current_user_required!(socket),
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
       categories: e(assigns(socket), :categories, []) ++ page,
       page_info: e(categories, :page_info, [])
     )}
  end
end
