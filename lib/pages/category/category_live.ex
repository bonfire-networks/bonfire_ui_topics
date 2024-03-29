defmodule Bonfire.UI.Topics.CategoryLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  # alias Bonfire.UI.Topics.CategoryLive.SubcategoriesLive
  alias Bonfire.Classify.Web.CommunityLive.CommunityCollectionsLive
  alias Bonfire.Classify.Web.CollectionLive.CollectionResourcesLive

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, session, socket) do
    with {:ok, socket} <-
           undead_mount(socket, fn ->
             Bonfire.Classify.LiveHandler.mounted(params, session, socket)
           end) do
      {:ok,
       assign(
         socket,
         page: "topic",
         showing_within: :topic
         #  nav_items: Bonfire.Common.ExtensionModule.default_nav()
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

  def handle_params(params, uri, socket),
    do:
      Bonfire.Classify.LiveHandler.handle_params(
        params,
        uri,
        socket
      )
end
