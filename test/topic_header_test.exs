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
    topic =
      fake_category!(me, nil, %{name: "Standalone notes", summary: "Passages worth discussing."})

    conn(user: me, account: account)
    |> visit("/+#{topic.character.username}")
    |> wait_async()
    |> assert_has("h1", text: "Standalone notes", count: 1)
    |> assert_has("[data-id=topic_subheader][data-variant=full]")
    # (the band with no banner was always `bg-primary`; it is now in the topic's swatch, `topic_hero_band`, tested in `topic_appearance_test.exs`)
    # |> assert_has("#topic-parent-banner.bg-primary")
    |> assert_has("#topic-parent-banner[data-role=topic_hero_band][class*='topic-']")
    |> assert_has("#topic-icon")
    # |> assert_has("#topic-description", text: "Passages worth discussing.")
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

  describe "the header's description" do
    test "a top-level topic shows its description under its name and address", %{
      account: account,
      me: me
    } do
      topic =
        fake_category!(me, nil, %{
          name: "Standalone notes",
          type: :topic,
          summary: "Passages worth discussing."
        })

      address = Bonfire.Me.Characters.display_username(topic, true, nil, "")

      conn(user: me, account: account)
      |> visit("/+#{topic.character.username}")
      |> assert_has("[data-id=topic_subheader] h1", text: "Standalone notes")
      # the visible text may break before the host (`<wbr>`), so the handle and the host are checked apart
      |> assert_has("[data-id=topic_subheader] [data-role=group-address]",
        text: "Standalone_notes"
      )
      |> assert_has("[data-id=topic_subheader] [data-role=group-address]",
        text: "@#{List.last(String.split(address, "@"))}"
      )
      |> assert_has(
        "[data-id=topic_subheader] [data-role=group-address-copy][phx-hook=Copy][data-clipboard-text='!#{address}']"
      )
      |> assert_has(
        "[data-id=topic_subheader] [data-role=group-address-copy][phx-hook=Copy][data-clipboard-text='@#{address}']"
      )
      # old: the address, with its `+`, was the copy target
      # |> assert_has("[data-id=topic_subheader] [data-role=group-address][data-clipboard-text='#{address}']")
      |> assert_has("[data-id=topic_subheader] [data-role=group-topic-summary]",
        text: "Passages worth discussing."
      )
    end

    test "a topic with no description shows none", %{account: account, me: me} do
      topic = fake_category!(me, nil, %{name: "Standalone notes", type: :topic})

      conn(user: me, account: account)
      |> visit("/+#{topic.character.username}")
      |> assert_has("[data-id=topic_subheader] [data-role=group-address]")
      |> refute_has("[data-role=group-topic-summary]")
    end
  end

  # the topic's actions are the ones in a group's selected chip (`Bonfire.UI.Groups.TopicInGroupFrameTest`); follow and the bell are already buttons in this header, so the menu leaves them out
  describe "the header's actions menu" do
    @actions "[data-id=topic_subheader] [data-role=topic-actions]"

    setup %{me: me} do
      topic = fake_category!(me, nil, %{name: "Standalone notes", type: :topic})
      %{topic: topic}
    end

    test "has Copy link and the header keeps its follow button, but the menu has no follow", %{
      account: account,
      me: me,
      topic: topic
    } do
      conn(user: me, account: account)
      |> visit("/+#{topic.character.username}")
      |> assert_has("[data-id=topic_subheader] [data-id=unfollow][aria-label='Unfollow topic']")
      |> assert_has("#{@actions} a[phx-hook=Copy]", text: "Copy link")
      |> refute_has("#{@actions} [data-id=unfollow]")
      |> refute_has("#{@actions} [data-id=follow]")
      |> refute_has("#{@actions} [data-role=bell]")
      # a topic made here has no outbox to fetch
      |> refute_has("#{@actions} [phx-click='Bonfire.Me.Users:fetch_outbox']")
    end

    test "has Copy link for a guest too", %{topic: topic} do
      Phoenix.ConnTest.build_conn()
      |> visit("/+#{topic.character.username}")
      |> assert_has("#{@actions} a[phx-hook=Copy]", text: "Copy link")
    end

    test "has Topic settings for the creator, in place of a separate gear; not for another member",
         %{account: account, me: me, topic: topic} do
      conn(user: me, account: account)
      |> visit("/+#{topic.character.username}")
      |> assert_has("#{@actions} a[phx-hook=Copy]", text: "Copy link")
      |> assert_has("#{@actions} [aria-label='Edit topic']", text: "Topic settings")
      # one way to the settings, not two
      |> assert_has("[data-id=topic_subheader] [aria-label='Edit topic']", count: 1)

      other = fake_user!(account)

      conn(user: other, account: account)
      |> visit("/+#{topic.character.username}")
      |> assert_has("#{@actions} a[phx-hook=Copy]", text: "Copy link")
      |> refute_has("[data-id=topic_subheader] [aria-label='Edit topic']")
    end
  end

  # uploads are resized with vips, which CI doesn't have
  describe "the header's banner" do
    import Bonfire.Files.Simulation

    defp with_banner!(user, category) do
      {:ok, banner} = fake_upload(image_file(), Bonfire.Files.BannerUploader, user)

      {:ok, category} =
        Bonfire.Classify.Categories.update(user, category, %{
          "profile" => %{"image" => banner, "image_id" => banner.id}
        })

      category
    end

    @tag Bonfire.Common.RuntimeConfig.skip_in_ci()
    test "a top-level topic shows its own banner", %{account: account, me: me} do
      topic = fake_category!(me, nil, %{name: "Standalone notes", type: :topic})
      # the positive first: a topic with no banner has none drawn
      conn(user: me, account: account)
      |> visit("/+#{topic.character.username}")
      |> assert_has("#topic-parent-banner")
      |> refute_has("#topic-parent-banner img")

      banner_url = Bonfire.Common.Media.banner_url(with_banner!(me, topic), fallback: false)
      assert is_binary(banner_url)

      conn(user: me, account: account)
      |> visit("/+#{topic.character.username}")
      |> assert_has("#topic-parent-banner img[src='#{banner_url}']")
    end

    @tag Bonfire.Common.RuntimeConfig.skip_in_ci()
    test "a topic with a parent shows the parent's banner", %{account: account, me: me} do
      group = fake_group!(me, %{name: "Parent reading group"})
      topic = fake_category!(me, group, %{name: "Reading notes", type: :topic})
      group_banner_url = Bonfire.Common.Media.banner_url(with_banner!(me, group), fallback: false)
      assert is_binary(group_banner_url)

      # the tab route isn't redirected into the group's frame, so the topic's own header shows
      conn(user: me, account: account)
      |> visit("/topic/#{topic.id}/followers")
      |> assert_has("#topic-parent-banner img[src='#{group_banner_url}']")
    end
  end

  describe "the group's tile in the link back to it" do
    @link "#topic-parent-link"

    test "shows the group's picked icon in its colour, a plain group its letter", %{
      account: account,
      me: me
    } do
      picked = fake_group!(me, %{name: "Picked reading group"})
      {:ok, _} = Bonfire.Classify.Appearance.set_icon(picked, "ph:baby-fill", current_user: me)
      {:ok, _} = Bonfire.Classify.Appearance.set_colour(picked, "teal", current_user: me)
      picked_topic = fake_category!(me, picked, %{name: "Picked notes", type: :topic})

      plain = fake_group!(me, %{name: "Plain reading group"})
      plain_topic = fake_category!(me, plain, %{name: "Plain notes", type: :topic})

      conn(user: me, account: account)
      |> visit("/topic/#{picked_topic.id}/followers")
      |> assert_has("#{@link} [data-role=group_tile][data-icon='ph:baby-fill'].topic-teal")

      conn(user: me, account: account)
      |> visit("/topic/#{plain_topic.id}/followers")
      |> assert_has("#{@link} [data-role=group_tile]", text: "P")
      |> refute_has("#{@link} [data-role=group_tile][data-icon]")
    end

    @tag Bonfire.Common.RuntimeConfig.skip_in_ci()
    test "shows the group's uploaded image over its picked icon", %{account: account, me: me} do
      group = fake_group!(me, %{name: "Parent reading group"})
      {:ok, _} = Bonfire.Classify.Appearance.set_icon(group, "ph:baby-fill", current_user: me)
      topic = fake_category!(me, group, %{name: "Reading notes", type: :topic})
      media = Bonfire.Social.Fake.upload_media(:images, me)

      {:ok, with_image} =
        Bonfire.Classify.Categories.update(me, group, %{profile: %{icon_id: media.id}})

      conn(user: me, account: account)
      |> visit("/topic/#{topic.id}/followers")
      |> assert_has("#{@link} img[src='#{Bonfire.Common.Media.avatar_url(with_image)}']")
      |> refute_has("#{@link} [data-role=group_tile]")
    end
  end
end
