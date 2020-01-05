defmodule RabbitmqSandbox.ReliablePublisher do
  use GenServer
  use AMQP

  alias RabbitmqSandbox.Conn

  @queue "pika_queue"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def publish_many do
    for number <- 1..3 do
      message = "hello publisher confirm - #{number}"
      GenServer.cast(__MODULE__, {:publish, message, @queue})
      :timer.sleep(150)
    end

    IO.puts("done!")
  end

  def publish(message, queue) do
    GenServer.cast(__MODULE__, {:publish, message, queue})
  end

  def init(_opts) do
    {:ok, _conn, channel} = Conn.establish()
    Confirm.register_handler(channel, self())
    Basic.return(channel, self())
    Confirm.select(channel)
    Confirm.wait_for_confirms_or_die(channel)

    {:ok, channel}
  end

  def handle_info({:basic_ack, delivery_tag, _multiple}, channel) do
    IO.puts("broker acked msg: #{delivery_tag}")
    {:noreply, channel}
  end

  def handle_info({:basic_nack, delivery_tag, _multiple}, channel) do
    IO.puts("broker N-acked msg: #{delivery_tag}")
    {:noreply, channel}
  end

  def handle_info({:basic_return, payload, meta}, channel) do
    IO.inspect(payload: payload, meta: meta)
    {:noreply, channel}
  end

  def handle_info(info, channel) do
    IO.inspect(info)
    {:noreply, channel}
  end

  def handle_cast({:publish, message, queue}, channel) do
    IO.puts("Sending message: #{message}")
    Basic.publish(channel, "", queue, message, mandatory: true)

    {:noreply, channel}
  end
end
