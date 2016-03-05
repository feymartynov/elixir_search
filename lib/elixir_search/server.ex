defmodule ElixirSearch.Server do
  import Plug.Conn

  @providers [
    ElixirSearch.Provider.Reddit,
    ElixirSearch.Provider.Faroo]

  def start_link(options \\ []) do
    Plug.Adapters.Cowboy.http(__MODULE__, options)
  end

  def init(options), do: options

  def call(conn, _opts) do
    conn
      |> fetch_query_params
      |> put_resp_content_type("text/plain")
      |> send_chunked(200)
      |> search
  end

  defp search(conn) do
    {:ok, pid} = Task.Supervisor.start_link()

    tasks = for provider <- @providers do
      Task.Supervisor.async_nolink(pid, fn ->
        results = %{results: provider.search(conn.params["q"])}
        {:ok, _} = chunk(conn, Poison.encode!(results) <> "\n")
      end)
    end

    for task <- tasks, do: Task.await(task)
    conn
  end
end
