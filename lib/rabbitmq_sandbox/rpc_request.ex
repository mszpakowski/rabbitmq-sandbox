defmodule RabbitmqSandbox.RpcRequest do
  use GenServer
  use AMQP

  alias RabbitmqSandbox.Conn

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def publish do
    GenServer.cast(__MODULE__, :publish)
  end

  def publish_extended(message) do
    GenServer.cast(__MODULE__, {:publish_extended, message})
  end

  def init(_opts) do
    {:ok, _conn, channel} = Conn.establish()

    {:ok, %{queue: reply_to}} =
      Queue.declare(channel, "", exclusive: true, arguments: [{"x-expires", :signedint, 30000}])

    IO.inspect(reply_to, label: "queue name")

    {:ok, _consumer_tag} = Basic.consume(channel, reply_to)
    {:ok, {channel, reply_to}}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, {channel, _reply_to} = state) do
    IO.inspect(payload)

    Basic.ack(channel, tag)

    {:noreply, state}
  end

  def handle_cast(:publish, {channel, reply_to} = state) do
    Basic.publish(
      channel,
      "amq.direct",
      "request",
      "our request waits on #{reply_to}",
      reply_to: reply_to
    )

    {:noreply, state}
  end
end
