defmodule Bonfire.UI.Topics.Routes do
  @behaviour Bonfire.UI.Common.RoutesModule

  defmacro __using__(_) do
    quote do
      # pages anyone can view
      scope "/", Bonfire.UI.Topics do
        pipe_through(:browser)
        live("/+:username", CategoryLive, as: Bonfire.Classify.Category)
        live("/+:username", CategoryLive, as: :topic)

        live("/+:username/follow", CategoryLive, :follow, as: Bonfire.Classify.Category)

        # note: order matters for Voodoo!

        live("/topics", CategoriesLive, as: Bonfire.Classify.Category)
        live("/topics/:tab", CategoriesLive)

        live("/categories", CategoriesLive)
        live("/categories/:tab", CategoriesLive)

        live("/category/:id", CategoryLive)
        live("/category/:id/:tab", CategoryLive)
      end

      # pages you need an account to view
      scope "/", Bonfire.UI.Topics do
        pipe_through(:browser)
        pipe_through(:account_required)
      end

      # pages you need to view as a user
      scope "/", Bonfire.UI.Topics do
        pipe_through(:browser)
        pipe_through(:user_required)

        live("/+:username/settings", CategoryLive, :settings, as: Bonfire.Classify.Category)
        live("/+:username/submitted", CategoryLive, :submitted, as: Bonfire.Classify.Category)
        live("/+:username/followers", CategoryLive, :followers, as: Bonfire.Classify.Category)
        live("/+:username/:tab", CategoryLive, as: Bonfire.Classify.Category)
        live("/+:username/:tab/:tab_id", CategoryLive, as: Bonfire.Classify.Category)
      end
    end
  end
end
