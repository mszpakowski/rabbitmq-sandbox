defmodule RabbitmqSandbox.Producer do
  use GenServer
  use AMQP

  alias RabbitmqSandbox.Conn

  @queue "pika_queue"

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
    {:ok, channel}
  end

  def handle_cast(:publish, channel) do
    Basic.publish(channel, "", @queue, "Hello from publisher")

    {:noreply, channel}
  end

  def handle_cast({:publish_extended, message}, channel) do
    Basic.publish(channel, "amq.direct", "ttl", message,
      content_type: "text/plain",
      delivery_mode: 2,
      expiration: "5000",
      persistent: true
    )

    IO.puts("published... enter next message")

    {:noreply, channel}
  end
end
