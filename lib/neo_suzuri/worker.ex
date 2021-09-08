defmodule NeoSuzuri.Worker do
  use GenServer
  require Logger

  @limit 10
  @suzuri_api_key Application.fetch_env!(:neo_suzuri, :suzuri_api_key)

  @impl GenServer
  def init(images) do
    {:ok, images, {:continue, :init_worker}}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def handle_continue(:init_worker, state) do
    retrieve_images()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:retrieve_images, state) do
    offset = Enum.random(1..1000)
    products =
      Json.get(
        "https://suzuri.jp",
        "/api/v1/products?limit=#{@limit}&offset=#{offset}",
        ["Authorization": "Bearer #{@suzuri_api_key}"]
      )["products"]
      |> Enum.map(fn product ->
        product["sampleImageUrl"]
      end)
      |> Enum.map(fn url ->
        String.replace(url, "323x323", "765x765")
      end)

    {:noreply, state ++ products}
  end

  @impl GenServer
  def handle_call(:request_image, _from, state) do
    [head | tail] = state

    if Enum.count(tail) <= (@limit / 2) do
      retrieve_images()
    end

    {:reply, head, tail}
  end

  defp retrieve_images() do
    Logger.debug("retrieving images...")
    Process.send_after(self(), :retrieve_images, 0)
  end
end
