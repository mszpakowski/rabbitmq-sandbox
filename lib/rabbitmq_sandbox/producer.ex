defmodule RabbitmqSandbox.Producer do
  use GenServer
  use AMQP

  @queue "pika_queue"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def publish do
    GenServer.cast(__MODULE__, :publish)
  end

  def init(_opts) do
    {:ok, conn} = Connection.open()
    {:ok, channel} = Channel.open(conn)
    {:ok, channel}
  end

  def handle_cast(:publish, channel) do
    Basic.publish(channel, "", @queue, "Hello from publisher")
    {:noreply, channel}
  end
end
