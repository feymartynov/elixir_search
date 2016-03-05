defmodule ElixirSearch.Provider.Reddit do
  def search(query) do
    url = "https://www.reddit.com/r/news/search.json?q=#{query}"
    {:ok, status, _, client} = :hackney.request(:get, url)
    if status != 200, do: raise "Reddit returned #{status} status code"

    {:ok, body} = :hackney.body(client)
    data = Poison.Parser.parse!(body)

    for item <- data["data"]["children"] do
      %{provider: "reddit", title: item["data"]["title"]}
    end
  end
end
