defmodule Bonfire.UI.Topics.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler

  def handle_event("new", %{} = attrs, socket) do
    Bonfire.Classify.LiveHandler.new(:topic, attrs, socket)
  end

  def handle_event("autocomplete", %{"input" => input}, socket) do
    # TODO?
  end

  def handle_event("edit", attrs, socket) do
    # TODO?
  end
end
