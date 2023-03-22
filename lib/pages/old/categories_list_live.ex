defmodule Bonfire.UI.Topics.CategorieListLive do
  use Bonfire.UI.Common.Web, :live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, _session, socket) do
    {:ok, assign(socket, page: 1)}
  end

  def render(assigns) do
    ~L"""

    <%= live_component(
      @socket,
      Bonfire.Classify.Web.InstanceLive.InstanceCategoriesLive,
      # selected_tab: @selected_tab,
      id: :categories,
      categories: [],
      page: 1,
      has_next_page: false,
      after: [],
      before: [],
      pagination_target: "#instance-categories",
      current_user: current_user(assigns)
    ) %>


    <%= live_component(
      @socket,
      Bonfire.Classify.Web.My.NewCategoryLive ,
      # selected_tab: @selected_tab,
      id: :new_category,
      toggle_category: true,
      current_user: current_user(assigns)
    ) %>
    """
  end
end
