defmodule Bonfire.UI.Topics.RuntimeConfig do
  use Bonfire.Common.Localise

  @behaviour Bonfire.Common.ConfigModule
  def config_module, do: true

  @doc """
  NOTE: you can override this default config in your app's `runtime.exs`, by placing similarly-named config keys below the `Bonfire.Common.Config.LoadExtensionsConfig.load_configs()` line
  """
  def config do
    import Config

    config :bonfire_ui_topics,
      disabled: false

    config :bonfire, :ui,
      topic: [
        sections: [
          timeline: Bonfire.UI.Social.ProfileTimelineLive,
          settings: Bonfire.UI.Topics.SettingsLive
        ],
        navigation: [
          timeline: "Timeline"
        ],
        network: [],
        settings: [
          sections: [
            general: Bonfire.UI.Topics.Settings.GeneralLive
          ],
          navigation: [
            general: "General"
          ]
        ]
      ]
  end
end
