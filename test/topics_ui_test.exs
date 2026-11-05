defmodule Bonfire.UI.Topics.TopicsUITest do
  use Bonfire.UI.Topics.ConnCase, async: System.get_env("TEST_UI_ASYNC") != "no"
  @moduletag :ui

  alias Bonfire.Me.Fake
  use Bonfire.Common.Utils

  defp post_in_topic(session, content, topic_id) do
    session
    |> PhoenixTest.unwrap(fn view ->
      view
      |> Phoenix.LiveViewTest.element("#inline_composer_placeholder_open")
      |> Phoenix.LiveViewTest.render_click()

      submit_composer(view, content, %{"context_id" => topic_id, "to_circles" => [topic_id]})
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
    |> assert_has_or_open_browser("[data-role=discussion_preview_actions]")
  end

  test "mentioning a topic in a post shows the tag link in the rendered post" do
    account = fake_account!()
    me = fake_user!(account)
    topic = fake_category!(me)

    conn = conn(user: me, account: account)

    # Use /dashboard rather than "/" — the latter redirects via HomeLive's
    # pre_mount and PhoenixTest occasionally lands us back on the login form
    # before the redirect is followed.
    conn
    |> visit("/dashboard")
    |> wait_async()
    |> PhoenixTest.unwrap(fn view ->
      view
      |> Phoenix.LiveViewTest.element("#main_smart_input_button")
      |> Phoenix.LiveViewTest.render_click()

      submit_composer(view, "+#{topic.character.username} this is very on topic", %{
        "boundary" => "mentions"
      })
    end)

    conn
    |> visit("/@#{e(me, :character, :username, nil)}")
    |> wait_async()
    |> assert_has_or_open_browser("a", text: topic.character.username)
  end

  test "topic feed excludes activities from sibling topics in the same group" do
    account = fake_account!()
    me = fake_user!(account)

    group = fake_group!(me)
    topic_a = fake_category!(me, group, %{name: "Alpha topic"})
    topic_b = fake_category!(me, group, %{name: "Beta topic"})

    fake_post_in_topic!(me, topic_a, "<p>Post about alpha</p>")
    fake_post_in_topic!(me, topic_b, "<p>Post about beta</p>")

    conn = conn(user: me, account: account)

    conn
    |> visit("/+#{topic_a.character.username}")
    |> wait_async()
    |> assert_has_or_open_browser("article", text: "Post about alpha")
    |> refute_has_or_open_browser("article", text: "Post about beta")

    conn
    |> visit("/+#{topic_b.character.username}")
    |> wait_async()
    |> assert_has_or_open_browser("article", text: "Post about beta")
    |> refute_has_or_open_browser("article", text: "Post about alpha")
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

  # a topic made in a group marked sensitive starts marked, which the form shows ticked and its author can untick
  describe "the new-topic form" do
    @new_topic "[data-id=group_hero] [data-id=group_topics] [data-role=group-topics-new] #new_topic_chips [data-role=open_modal]"

    setup do
      account = fake_account!()
      creator = fake_user!(account)

      group =
        Bonfire.Classify.Simulate.fake_group!(creator, %{
          name: "Life drawing",
          membership: "open",
          visibility: "global"
        })

      {:ok, conn: conn(user: creator, account: account), creator: creator, group: group}
    end

    defp topic_named(group, user, name) do
      Bonfire.Classify.Categories.list_tree(
        [:default, parent_category: id(group), tree_max_depth: 1, preload: :profile],
        current_user: user
      )
      |> e(:edges, [])
      |> Enum.find(&(e(&1, :profile, :name, nil) == name))
    end

    defp sensitive_topic?(group, user, name) do
      topic = topic_named(group, user, name)
      assert topic, "the topic was not created"

      {:ok, topic} =
        Bonfire.Classify.Categories.get(id(topic), [:default, skip_boundary_check: true])

      Bonfire.Classify.Categories.sensitive?(topic)
    end

    test "in a group not marked sensitive opens with Mark as sensitive unticked", %{
      conn: conn,
      group: group
    } do
      conn
      |> visit("/group/#{group.character.username}")
      |> click_button(@new_topic, "New topic")
      |> assert_has("#new_topic_form #new_topic_sensitive[type=checkbox]")
      |> refute_has("#new_topic_form #new_topic_sensitive[checked]")
    end

    test "in a group marked sensitive opens with Mark as sensitive ticked", %{
      conn: conn,
      creator: creator,
      group: group
    } do
      assert {:ok, _} = Bonfire.Social.Objects.set_sensitivity(group, true)

      conn
      |> visit("/group/#{group.character.username}")
      |> click_button(@new_topic, "New topic")
      |> assert_has("#new_topic_form #new_topic_sensitive[checked]")
      |> fill_in("Topic name", with: "Figure studies")
      |> click_button("[data-role=new_topic_submit]", "Create")
      |> assert_has("[data-id=group_topics] [data-role=group-topic-current]",
        text: "Figure studies"
      )

      assert sensitive_topic?(group, creator, "Figure studies") == true
    end

    test "submitted unticked in a group marked sensitive makes an unmarked topic", %{
      conn: conn,
      creator: creator,
      group: group
    } do
      assert {:ok, _} = Bonfire.Social.Objects.set_sensitivity(group, true)

      conn
      |> visit("/group/#{group.character.username}")
      |> click_button(@new_topic, "New topic")
      |> fill_in("Topic name", with: "Materials")
      |> uncheck("Mark as sensitive")
      |> click_button("[data-role=new_topic_submit]", "Create")
      |> assert_has("[data-id=group_topics] [data-role=group-topic-current]", text: "Materials")

      assert sensitive_topic?(group, creator, "Materials") == false
    end
  end
end
