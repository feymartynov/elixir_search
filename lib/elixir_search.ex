defmodule ElixirSearch do
  use Application
  
  def start(_type, _args) do
    ElixirSearch.Supervisor.start_link
  end
end
