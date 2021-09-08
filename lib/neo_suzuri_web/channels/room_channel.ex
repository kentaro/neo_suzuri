defmodule NeoSuzuriWeb.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join(topic, payload, socket) do
    Logger.info("topic: #{topic}, payload: #{inspect(payload)}")
    {:ok, socket}
  end

  def handle_in("request_image" = topic, %{"error" => true} = payload, socket) do
    Logger.info("topic: #{topic}, payload: #{inspect(payload)}")
    {:reply, {:error, %{reason: "error flag for `request_image` request is true"}}, socket}
  end

  def handle_in("request_image" = topic, payload, socket) do
    Logger.info("topic: #{topic}, payload: #{inspect(payload)}")
    image_url =  GenServer.call(NeoSuzuri.Worker, :request_image)
    {:reply, {:ok, %{image_url: image_url}}, socket}
  end
end
