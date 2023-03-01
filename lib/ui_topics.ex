defmodule Bonfire.UI.Topics do
  import Untangle
  alias Bonfire.Common.Utils
  alias Bonfire.Common.Extend
  alias Bonfire.Common
  alias Common.Types



  def is_admin?(user) do
    if is_map(user) and Map.get(user, :instance_admin) do
      Map.get(user.instance_admin, :is_instance_admin)
    else
      # FIXME
      false
    end
  end


end
