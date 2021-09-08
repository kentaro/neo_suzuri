defmodule NeoSuzuriWeb.PageController do
  use NeoSuzuriWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
