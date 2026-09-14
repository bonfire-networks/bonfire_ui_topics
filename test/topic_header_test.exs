defmodule Bonfire.UI.Topics.TopicHeaderTest do
  use Bonfire.UI.Topics.ConnCase, async: false
  @moduletag :ui

  setup do
    Process.put(:federating, false)
    Process.put([:bonfire, :feed_live_update_many_preload_mode], :inline)
    account = fake_account!()
    me = fake_user!(account)
    group = fake_group!(me, %{name: "Parent reading group"})

    topic =
      fake_category!(me, group, %{name: "Reading notes", summary: "Passages worth discussing."})

    %{account: account, me: me, group: group, topic: topic}
  end

  test "topic has one heading and a parent link instead of sibling navigation", %{
    account: account,
    me: me,
    group: group,
    topic: topic
  } do
    conn(user: me, account: account)
    |> visit("/+#{topic.character.username}")
    |> wait_async()
    |> assert_has("h1", text: "Reading notes", count: 1)
    |> assert_has("#topic-parent-link", text: "Parent reading group")
    |> assert_has("#topic-parent-banner.bg-primary")
    |> assert_has("#topic-icon")
    |> refute_has("[data-id=group_topics_nav]")
    |> assert_has("[data-id=topic_subheader] [data-id=unfollow][aria-label='Unfollow topic']")
    |> click_link("#topic-parent-link", "Parent reading group")
    |> assert_path("/group/#{group.character.username}")
  end

  test "top-level topics have a safe return link and no edit control for guests", %{me: me} do
    topic = fake_category!(me, nil, %{name: "Standalone topic"})

    Phoenix.ConnTest.build_conn()
    |> visit("/+#{topic.character.username}")
    |> assert_has("#topic-parent-link[href='/groups']", text: "Groups")
    |> assert_has("h1", text: "Standalone topic")
    |> refute_has("[aria-label='Edit topic']")
  end
end
