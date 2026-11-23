defmodule Bonfire.UI.Topics.TopicAppearanceTest do
  @moduledoc "A topic's colour and icon, picked in its settings (`Bonfire.Classify.Web.AppearanceLive`): saved as the topic's own, reset to what it inherits, and only for someone who may configure it."
  use Bonfire.UI.Topics.ConnCase, async: false
  @moduletag :ui

  use Bonfire.Common.Utils
  alias Bonfire.Classify.Appearance
  alias Bonfire.Classify.Categories

  setup do
    account = fake_account!()
    creator = fake_user!(account)

    group =
      Bonfire.Classify.Simulate.fake_group!(creator, %{
        name: "Life drawing",
        membership: "open",
        visibility: "global"
      })

    topic =
      Bonfire.Classify.Simulate.fake_category!(creator, group, %{
        name: "Figure studies",
        type: :topic
      })

    {:ok,
     conn: conn(user: creator, account: account), group: group, topic: topic, creator: creator}
  end

  defp open_topic_settings(conn, group, topic) do
    conn
    |> visit(Bonfire.Classify.Web.GroupNavigation.topic_path(group, topic))
    |> click_button(
      "[data-id=group_topics] #edit_topic_modal_#{uid(topic)} [data-role=open_modal]",
      "Topic settings"
    )
  end

  defp reload(category) do
    {:ok, category} = Categories.get(id(category), [:default, skip_boundary_check: true])
    Appearance.preload(category)
  end

  test "the owner picks a colour and an icon, and resets the colour to the group's", %{
    conn: conn,
    group: group,
    topic: topic,
    creator: creator
  } do
    {:ok, _} = Appearance.set_colour(group, "red", current_user: creator)

    session =
      conn
      |> open_topic_settings(group, topic)
      |> assert_has("[data-role=appearance_picker]")
      # it shows what the topic has now: the group's red, inherited
      |> refute_has("[data-swatch][aria-pressed=true]")
      |> click_button("[data-swatch=violet]", "violet")
      |> assert_has("[data-swatch=violet][aria-pressed=true]")
      |> assert_has("[data-role=appearance_picker] [role=status]", text: "Saved")
      |> click_button("[data-icon='ph:music-notes-fill']", "music notes")
      |> assert_has("[data-icon='ph:music-notes-fill'][aria-pressed=true]")

    assert Appearance.own_colour(reload(topic)) == "violet"
    assert Appearance.colour(reload(topic)) == "violet"
    assert Appearance.icon(reload(topic)) == "ph:music-notes-fill"

    session
    |> click_button("[data-role=reset_colour]", "Reset")
    |> refute_has("[data-swatch][aria-pressed=true]")
    |> click_button("[data-role=reset_icon]", "Reset")
    |> refute_has("[data-icon][aria-pressed=true]")

    assert Appearance.own_colour(reload(topic)) == nil
    # back to the group's
    assert Appearance.colour(reload(topic)) == "red"
    assert Appearance.icon(reload(topic)) == nil
  end

  test "a topic with no banner has a band in its colour on its page, its parent's if it has none",
       %{
         conn: conn,
         group: group,
         creator: creator
       } do
    solo = Bonfire.Classify.Simulate.fake_category!(creator, nil, %{name: "Solo", type: :topic})
    {:ok, _} = Appearance.set_colour(solo, "violet", current_user: creator)

    conn
    |> visit("/+#{solo.character.username}")
    |> assert_has("[data-role=topic_hero_band].topic-violet")
    |> refute_has("#topic-parent-banner.bg-primary")

    # a top-level topic under a topic that has a colour
    child = Bonfire.Classify.Simulate.fake_category!(creator, solo, %{name: "Duo", type: :topic})

    conn
    |> visit("/+#{child.character.username}")
    |> assert_has("[data-role=topic_hero_band].topic-violet")

    _ = group
  end

  test "the big header shows the picked icon with no uploaded image, the hash with neither", %{
    conn: conn,
    creator: creator
  } do
    solo = Bonfire.Classify.Simulate.fake_category!(creator, nil, %{name: "Iconic", type: :topic})

    # neither: the hash
    conn
    |> visit("/+#{solo.character.username}")
    |> assert_has("#topic-icon [iconify='ph:hash']")

    {:ok, _} = Appearance.set_icon(solo, "ph:music-notes-fill", current_user: creator)

    conn
    |> visit("/+#{solo.character.username}")
    |> assert_has("#topic-icon [iconify='ph:music-notes-fill']")
    |> refute_has("#topic-icon [iconify='ph:hash']")
  end

  # uploads are resized with vips, which CI doesn't have
  @tag Bonfire.Common.RuntimeConfig.skip_in_ci()
  test "the big header shows the uploaded image, not the picked icon", %{
    conn: conn,
    creator: creator
  } do
    solo =
      Bonfire.Classify.Simulate.fake_category!(creator, nil, %{name: "Pictured", type: :topic})

    {:ok, _} = Appearance.set_icon(solo, "ph:music-notes-fill", current_user: creator)

    # the same topic with no image shows the icon
    conn
    |> visit("/+#{solo.character.username}")
    |> assert_has("#topic-icon [iconify='ph:music-notes-fill']")

    {:ok, avatar} =
      Bonfire.Files.Simulation.fake_upload(
        Bonfire.Files.Simulation.image_file(),
        Bonfire.Files.IconUploader,
        creator
      )

    {:ok, _} =
      Categories.update(creator, solo, %{"profile" => %{"icon" => avatar, "icon_id" => avatar.id}})

    conn
    |> visit("/+#{solo.character.username}")
    |> assert_has("#topic-icon img")
    |> refute_has("#topic-icon [iconify]")
  end

  # controls to the band test: the same page in the opposite states
  test "a top-level topic with no colour set has the band in its hashed swatch, not a set one", %{
    conn: conn,
    creator: creator
  } do
    plain = Bonfire.Classify.Simulate.fake_category!(creator, nil, %{name: "Plain", type: :topic})
    hashed = Bonfire.Common.Swatches.from_seed(id(plain))

    conn
    |> visit("/+#{plain.character.username}")
    |> assert_has("[data-role=topic_hero_band].topic-#{hashed}")
    |> refute_has("[data-role=topic_hero_band].topic-violet")
  end

  # uploads are resized with vips, which CI doesn't have
  @tag Bonfire.Common.RuntimeConfig.skip_in_ci()
  test "a topic with a banner has no band", %{conn: conn, creator: creator} do
    solo =
      Bonfire.Classify.Simulate.fake_category!(creator, nil, %{name: "Bannered", type: :topic})

    {:ok, _} = Appearance.set_colour(solo, "violet", current_user: creator)

    # the positive first: with no banner it has the band
    conn
    |> visit("/+#{solo.character.username}")
    |> assert_has("[data-role=topic_hero_band].topic-violet")

    {:ok, banner} =
      Bonfire.Files.Simulation.fake_upload(
        Bonfire.Files.Simulation.image_file(),
        Bonfire.Files.BannerUploader,
        creator
      )

    {:ok, _} =
      Categories.update(creator, solo, %{
        "profile" => %{"image" => banner, "image_id" => banner.id}
      })

    conn
    |> visit("/+#{solo.character.username}")
    |> assert_has("#topic-parent-banner img")
    |> refute_has("[data-role=topic_hero_band]")
  end

  test "the owner's same two events are saved (control: the stranger's below is refused)", %{
    conn: conn,
    group: group,
    topic: topic
  } do
    conn
    |> visit(Bonfire.Classify.Web.GroupNavigation.topic_path(group, topic))
    |> PhoenixTest.unwrap(fn view ->
      Phoenix.LiveViewTest.render_hook(view, "Bonfire.Classify:set_colour", %{
        "id" => id(topic),
        "swatch" => "red"
      })

      Phoenix.LiveViewTest.render_hook(view, "Bonfire.Classify:set_icon", %{
        "id" => id(topic),
        "icon" => "ph:music-notes-fill"
      })
    end)

    assert Appearance.own_colour(reload(topic)) == "red"
    assert Appearance.icon(reload(topic)) == "ph:music-notes-fill"
  end

  test "someone who may not configure the topic gets no picker, and a save they send is refused",
       %{
         group: group,
         topic: topic
       } do
    account = fake_account!()
    stranger = fake_user!(account)
    conn = conn(user: stranger, account: account)

    conn
    |> visit(Bonfire.Classify.Web.GroupNavigation.topic_path(group, topic))
    |> refute_has("#edit_topic_modal_#{uid(topic)}")
    |> refute_has("[data-role=appearance_picker]")
    |> PhoenixTest.unwrap(fn view ->
      Phoenix.LiveViewTest.render_hook(view, "Bonfire.Classify:set_colour", %{
        "id" => id(topic),
        "swatch" => "red"
      })

      Phoenix.LiveViewTest.render_hook(view, "Bonfire.Classify:set_icon", %{
        "id" => id(topic),
        "icon" => "ph:music-notes-fill"
      })
    end)

    assert Appearance.own_colour(reload(topic)) == nil
    assert Appearance.icon(reload(topic)) == nil
  end

  test "an instance admin who did not create the topic picks its colour, as they edit its other settings",
       %{
         group: group
       } do
    # a topic made with no creator, as the instance's own are (a reserved topic that was brought back)
    {:ok, topic} =
      Categories.get_or_create_topic(%{name: "Auto made", username: "auto_made_topic"}, nil)

    account = fake_account!()
    admin = Bonfire.UI.Common.Testing.Helpers.fake_admin!(account)

    conn(user: admin, account: account)
    |> visit("/+auto_made_topic")
    |> click_button("#edit_topic_modal_#{uid(topic)} [data-role=open_modal]", "Topic settings")
    |> assert_has("[data-role=appearance_picker]")
    |> click_button("[data-swatch=violet]", "violet")
    |> assert_has("[data-role=appearance_picker] [role=status]", text: "Saved")
    |> refute_has("[data-role=appearance_picker] [role=alert]")

    assert Appearance.own_colour(reload(topic)) == "violet"
    _ = group
  end
end
