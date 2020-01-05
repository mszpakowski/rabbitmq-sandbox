defmodule RabbitmqSandbox.ReliableConsumer do
  use GenServer
  use AMQP

  alias RabbitmqSandbox.Conn

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get() do
    GenServer.cast(__MODULE__, :get)
  end

  def init(_opts) do
    {:ok, _conn, channel} = Conn.establish()
    {:ok, channel}
  end

  # def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
  #   {:noreply, channel}
  # end

  # def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, channel) do
  #   IO.inspect(payload)

  #   Basic.ack(channel, tag)

  #   {:noreply, channel}
  # end

  def handle_cast(:get, channel) do
    case Basic.get(channel, "pika_queue") do
      {:ok, payload, meta} ->
        consume(channel, payload, meta)

      _ ->
        nil
    end

    {:noreply, channel}
  end

  defp consume(channel, payload, %{delivery_tag: tag}) do
    if String.contains?(payload, "reject") do
      Basic.nack(channel, tag)
      IO.puts("N-acked the message")
    else
      Basic.ack(channel, tag)
      IO.puts("acked the message: #{payload}")
    end
  end
end
