defmodule Bonfire.UI.Topics.CategoryLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  # alias Bonfire.UI.Topics.CategoryLive.SubcategoriesLive
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
      &Bonfire.Classify.LiveHandler.mounted/3
    ])
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
      Bonfire.UI.Common.LiveHandlers.handle_params(
        params,
        uri,
        socket,
        __MODULE__,
        &Bonfire.Classify.LiveHandler.do_handle_params/3
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
