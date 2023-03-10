defmodule Bonfire.UI.Topics.TopicHeaderAsideLive do
  use Bonfire.UI.Common.Web, :stateless_component
  import Bonfire.Classify

  prop category, :map
  # prop object_boundary, :any, default: nil

  def display_url("https://" <> url), do: url
  def display_url("http://" <> url), do: url
  def display_url(url), do: url

  def category_link(category) do
    id = e(category, :character, :username, nil) || e(category, :id, "#no-parent")

    "/+" <> id
  end
end
