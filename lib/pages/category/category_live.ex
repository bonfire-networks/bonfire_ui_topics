defmodule Bonfire.UI.Topics.CategoryLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, session, socket) do
    with {:ok, socket} <-
           undead_mount(socket, fn ->
             # a topic in a group redirects to its page in the group frame, except on the routes that frame has no equivalent of: `/interact/follow` and `/topic/:id/:tab`
             Bonfire.Classify.LiveHandler.mounted(params, session, socket,
               redirect_topics_into_group:
                 is_nil(e(assigns(socket), :live_action, nil)) and is_nil(params["tab"])
             )
           end) do
      {:ok,
       assign(
         socket,
         page: "topic",
         showing_within: :topic,
         no_header: true
       )}
    end
  end

  def tab(selected_tab) do
    case maybe_to_atom(selected_tab) do
      tab when is_atom(tab) -> tab
      _ -> :timeline
    end
  end

  def handle_params(params, uri, socket),
    do:
      Bonfire.Classify.LiveHandler.handle_params(
        params,
        uri,
        socket
      )
end
