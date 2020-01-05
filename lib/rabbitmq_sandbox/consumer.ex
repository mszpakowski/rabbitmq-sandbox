defmodule RabbitmqSandbox.Consumer do
  use GenServer
  use AMQP

  alias RabbitmqSandbox.Conn

  def start_link(queue, consumer_tag \\ "") do
    GenServer.start_link(__MODULE__, {queue, consumer_tag}, name: __MODULE__)
  end

  def close_channel() do
    GenServer.cast(__MODULE__, :close_channel)
  end

  def init({queue, consumer_tag}) do
    {:ok, _conn, channel} = Conn.establish()
    {:ok, _consumer_tag} = Basic.consume(channel, queue, nil, consumer_tag: consumer_tag)
    {:ok, channel}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, channel) do
    IO.inspect(payload)

    Basic.ack(channel, tag)

    {:noreply, channel}
  end

  def handle_cast(:close_channel, channel) do
    Channel.close(channel)

    {:noreply, channel}
  end
end
