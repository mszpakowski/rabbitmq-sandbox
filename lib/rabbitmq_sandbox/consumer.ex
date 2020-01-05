defmodule RabbitmqSandbox.Consumer do
  use GenServer
  use AMQP

  @queue "pika_queue"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, conn} = Connection.open()
    {:ok, channel} = Channel.open(conn)
    {:ok, _consumer_tag} = Basic.consume(channel, @queue)
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
end
