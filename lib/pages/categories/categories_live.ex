defmodule Bonfire.UI.Topics.CategoriesLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  declare_extension("Topics",
    icon: "emojione:books",
    emoji: "📚",
    default_nav: [
      Bonfire.UI.Topics.CategoriesLive,
      Bonfire.UI.Groups.SidebarGroupsLive
      # Bonfire.Classify.Web.LocalCategoriesLive
      # Bonfire.Classify.Web.RemoteCategoriesLive
    ]
  )

  declare_nav_link(l("Explore Topics"), icon: "heroicons-solid:newspaper")

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, _session, socket) do
    {:ok,
     assign(
       socket,
       page: "topics",
       page_title: l("Topics"),
       categories: [],
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       feed: nil,
       #  without_sidebar: true,
       page_info: nil,
       smart_input: nil,
       search_placeholder: nil,
       selected_tab: nil,
       sidebar_widgets: [
         users: [
           secondary: [{Bonfire.Tag.Web.WidgetTagsLive, []}]
         ],
         guests: [
           secondary: nil
         ]
       ]
     )}
  end

  def handle_params(params, uri, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_params(
        Map.put(params, "tab", "discover"),
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
