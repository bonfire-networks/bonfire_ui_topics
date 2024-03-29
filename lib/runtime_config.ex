defmodule Bonfire.UI.Topics.RuntimeConfig do
  use Bonfire.Common.Localise

  @behaviour Bonfire.Common.ConfigModule
  def config_module, do: true

  @doc """
  NOTE: you can override this default config in your app's `runtime.exs`, by placing similarly-named config keys below the `Bonfire.Common.Config.LoadExtensionsConfig.load_configs()` line
  """
  def config do
    import Config

    # config :bonfire_ui_topics,
    #   modularity: :disabled

    config :bonfire, :ui,
      topic: [
        sections: [
          nil: Bonfire.UI.Social.ProfileTimelineLive,
          settings: Bonfire.UI.Topics.SettingsLive,
          followers: Bonfire.UI.Social.Graph.ProfileFollowsLive,
          follow: Bonfire.UI.Me.RemoteInteractionFormLive
        ],
        navigation: [
          nil: l("Timeline"),
          followers: l("Followers")
        ],
        network: [],
        settings: [
          sections: [
            nil: Bonfire.UI.Topics.Settings.GeneralLive,
            membership: Bonfire.UI.Topics.Settings.MembersLive,
            moderation: Bonfire.UI.Topics.Settings.ModerationLive
          ],
          navigation: [
            nil: l("General"),
            # membership: l("Members"),
            moderation: l("Moderation")
          ]
        ]
      ]
  end
end
