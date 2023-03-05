defmodule Bonfire.UI.Topics.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler

  def handle_event("new", %{} = attrs, socket) do
    attrs
    |> Map.put("to_boundaries", {:clone, e(attrs, :context_id, nil)})
    |> Bonfire.Classify.LiveHandler.new(:topic, ..., socket)
  end

  def handle_event("autocomplete", %{"input" => input}, socket) do
    # TODO?
  end

  def handle_event("edit", attrs, socket) do
    # TODO?
  end
end
