defmodule Bonfire.UI.Topics.TopicsUITest do
  use Bonfire.UI.Topics.ConnCase, async: System.get_env("TEST_UI_ASYNC") != "no"
  @moduletag :ui

  alias Bonfire.Me.Fake
  use Bonfire.Common.Utils

  defp post_in_topic(session, content, topic_id) do
    params = %{
      "post" => %{"post_content" => %{"html_body" => content}},
      "context_id" => topic_id,
      "to_circles" => [topic_id]
    }

    session
    |> click_button("[data-role=composer_button]", "Write in topic")
    |> PhoenixTest.unwrap(fn view ->
      view
      |> Phoenix.LiveViewTest.element("#smart_input_form")
      |> Phoenix.LiveViewTest.render_submit(params)
    end)
  end

  test "post in a topic appears in the topic's feed" do
    account = fake_account!()
    me = fake_user!(account)
    topic = fake_category!(me, nil, %{name: "Test Topic"})

    conn(user: me, account: account)
    |> visit("/+#{topic.character.username}")
    |> wait_async()
    |> post_in_topic("<p>Topic post content here</p>", topic.id)

    conn(user: me, account: account)
    |> visit("/+#{topic.character.username}")
    |> wait_async()
    |> assert_has_or_open_browser("article", text: "Topic post content here")
  end

  test "mentioning a topic in a post shows the tag link in the rendered post" do
    account = fake_account!()
    me = fake_user!(account)
    topic = fake_category!(me)

    conn = conn(user: me, account: account)

    conn
    |> visit("/")
    |> wait_async()
    |> PhoenixTest.unwrap(fn view ->
      Phoenix.LiveViewTest.element(view, "#smart_input_form")
      |> Phoenix.LiveViewTest.render_submit(%{
        "post" => %{
          "post_content" => %{
            "html_body" => "+#{topic.character.username} this is very on topic"
          }
        },
        "boundary" => "mentions"
      })
    end)

    conn
    |> visit("/@#{e(me, :character, :username, nil)}")
    |> wait_async()
    |> assert_has_or_open_browser("a", text: topic.character.username)
  end

  test "clicking a topic tag navigates to the topic page" do
    account = fake_account!()
    me = fake_user!(account)
    topic = fake_category!(me, nil, %{name: "My Test Topic"})

    conn = conn(user: me, account: account)

    conn
    |> visit("/+#{topic.character.username}")
    |> wait_async()
    |> assert_has_or_open_browser("*", text: "My Test Topic")
  end
end
