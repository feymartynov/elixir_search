defmodule ElixirSearch.Provider.Faroo do
  def search(query) do
    url = "http://www.faroo.com/api?q=#{query}&start=1&length=10&l=en&src=news&f=json"
    headers = [Referer: "http://www.faroo.com/hp/api/api.html"]
    {:ok, status, _, client} = :hackney.request(:get, url, headers)
    if status != 200, do: raise "Faroo returned #{status} status code"

    {:ok, body} = :hackney.body(client)
    data = Poison.Parser.parse!(body)

    for item <- data["results"] do
      %{provider: "faroo", title: item["title"]}
    end
  end
end
