defmodule Bonfire.UI.Topics.TopicAccessGateLive do
  @moduledoc "Explains restricted topic access without presenting following as a way to unlock it."
  use Bonfire.UI.Common.Web, :stateless_component

  prop category, :map, required: true
  prop permalink, :string, required: true
  prop group_return_to, :string, default: "/groups"

  # the parent group's membership options, resolved in `Bonfire.Classify.LiveHandler`; `parent` is nil when the visitor may not see it
  prop parent, :any, default: nil
  prop parent_member, :boolean, default: false
  prop membership, :string, default: nil

  def render(assigns) do
    assigns
    |> assign(:can_join?, not assigns.parent_member and assigns.membership != "invite_only")
    |> render_sface()
  end
end
