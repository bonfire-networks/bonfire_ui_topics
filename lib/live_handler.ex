defmodule Bonfire.UI.Topics.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler

  def handle_event("new", %{} = attrs, socket) do
    attrs
    |> Map.put("to_boundaries", {:clone, e(attrs, :context_id, nil)})
    |> Bonfire.Classify.LiveHandler.new(:topic, ..., socket)
  end

  def handle_event("autocomplete", %{"input" => input}, _socket) do
    # TODO?
  end

  def handle_event("edit", _attrs, _socket) do
    # TODO?
  end
end
