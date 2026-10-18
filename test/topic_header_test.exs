defmodule Bonfire.UI.Topics.TopicHeaderTest do
  use Bonfire.UI.Topics.ConnCase, async: false
  @moduletag :ui

  setup do
    Process.put(:federating, false)
    Process.put([:bonfire, :feed_live_update_many_preload_mode], :inline)
    account = fake_account!()
    me = fake_user!(account)
    %{account: account, me: me}
  end

  # a topic in a group opens in the group's frame (`Bonfire.UI.Groups.TopicInGroupFrameTest`); the full header is for top-level topics
  test "a top-level topic has one heading, its banner and icon, and follow", %{
    account: account,
    me: me
  } do
    topic = fake_category!(me, nil, %{name: "Standalone notes", summary: "Passages worth discussing."})

    conn(user: me, account: account)
    |> visit("/+#{topic.character.username}")
    |> wait_async()
    |> assert_has("h1", text: "Standalone notes", count: 1)
    |> assert_has("[data-id=topic_subheader][data-variant=full]")
    |> assert_has("#topic-parent-banner.bg-primary")
    |> assert_has("#topic-icon")
    |> assert_has("#topic-description", text: "Passages worth discussing.")
    |> refute_has("[data-id=group_topics]")
    |> assert_has("[data-id=topic_subheader] [data-id=unfollow][aria-label='Unfollow topic']")
  end

  test "top-level topics have a safe return link and no edit control for guests", %{me: me} do
    topic = fake_category!(me, nil, %{name: "Standalone topic"})

    Phoenix.ConnTest.build_conn()
    |> visit("/+#{topic.character.username}")
    |> assert_has("#topic-parent-link[href='/groups']", text: "Groups")
    |> assert_has("h1", text: "Standalone topic")
    |> refute_has("[aria-label='Edit topic']")
  end

  # the tab routes aren't redirected into the group frame, so the topic's own page still links back to its group
  test "a topic in a group, on a tab route, links back to its group", %{account: account, me: me} do
    group = fake_group!(me, %{name: "Parent reading group"})
    topic = fake_category!(me, group, %{name: "Reading notes"})

    conn(user: me, account: account)
    |> visit("/topic/#{topic.id}/followers")
    |> click_link("#topic-parent-link", "Parent reading group")
    |> assert_path("/group/#{group.character.username}")
  end
end
