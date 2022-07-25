defmodule Bonfire.Classify.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler


  def handle_event("input_category", attrs, socket) do
    send_update(Bonfire.UI.Common.SmartInputLive, # assigns_merge(socket.assigns,
        id: :smart_input,
        create_activity_type: :category,
        # to_boundaries: [Bonfire.Boundaries.preset_boundary_tuple_from_acl(e(socket.assigns, :object_boundary, nil))],
        activity_inception: "reply_to",
        # TODO: use assigns_merge and send_update to the ActivityLive component within smart_input instead, so that `update/2` isn't triggered again
        # activity: activity,
        object: e(socket.assigns, :category, nil)
      )
    {:noreply,
       socket
     }
  end

  def handle_event("new", %{"name" => name} = attrs, socket) do
    current_user = current_user(socket)
    if(is_nil(name) or !current_user) do
      error(attrs)
      {:noreply,
       socket
       |> assign_flash(:error, "Please enter a name...")}
    else
      params = input_to_atoms(attrs)
      debug(attrs, "category to create")

      {:ok, category} =
        Bonfire.Classify.Categories.create(
          current_user,
          %{category: params, parent_category: e(params, :context_id, nil)}
        )

      # TODO: handle errors
      debug(category, "category created")

      id = category.character.username || category.id

      if(id) do
        {:noreply,
         socket
         |> assign_flash(:info, "Category created!")
         # change redirect
         |> redirect_to("/+" <> id)}
      else
        {:noreply,
         socket
         |> redirect_to("/categories/")}
      end
    end
  end
end