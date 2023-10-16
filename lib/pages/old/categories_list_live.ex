defmodule Bonfire.UI.Topics.CategorieListLive do
  use Bonfire.UI.Common.Web, :live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, _session, socket) do
    {:ok, assign(socket, page: 1)}
  end

  def render(assigns) do
    ~H"""
    <.live_component
      module={Bonfire.Classify.Web.InstanceLive.InstanceCategoriesLive}
      id={:categories}
      categories={[]}
      after={[]}
      before={[]}
      page={1}
      has_next_page={false}
      pagination_target="#instance-categories"
      current_user={current_user(assigns)}
    />

    <.live_component
      module={Bonfire.Classify.Web.My.NewCategoryLive}
      id={:new_category}
      toggle_category={true}
      current_user={current_user(assigns)}
    />
    """
  end
end
