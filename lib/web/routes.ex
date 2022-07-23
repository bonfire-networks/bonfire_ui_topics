defmodule Bonfire.Classify.Web.Routes do
  defmacro __using__(_) do

    quote do

      # pages anyone can view
      scope "/", Bonfire.Classify.Web do
        pipe_through :browser

        live "/+:username", CategoryLive, as: Bonfire.Classify.Category
        live "/+:username/:tab", CategoryLive, as: Bonfire.Classify.Category
        # note: order matters for Voodoo!
        live "/topics", CategoriesLive, as: Bonfire.Classify.Category
        live "/categories", CategoriesLive

        live "/category/:id", CategoryLive
        live "/category/:id/:tab", CategoryLive

      end

      # pages you need an account to view
      scope "/", Bonfire.Classify.Web do
        pipe_through :browser
        pipe_through :account_required

      end

      # pages you need to view as a user
      scope "/", Bonfire.Classify.Web do
        pipe_through :browser
        pipe_through :user_required


      end

    end
  end
end
