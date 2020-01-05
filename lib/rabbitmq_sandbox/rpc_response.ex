defmodule RabbitmqSandbox.RpcResponse do
  use GenServer
  use AMQP

  alias RabbitmqSandbox.Conn

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, _conn, channel} = Conn.establish()
    Queue.declare(channel, "request_queue", durable: true)
    Queue.bind(channel, "request_queue", "amq.direct", routing_key: "request")

    {:ok, _consumer_tag} = Basic.consume(channel, "request_queue")
    {:ok, channel}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, reply_to: reply_to}}, channel) do
    IO.puts("now doing the response!")
    Basic.publish(channel, "", reply_to, "response to the request: '#{payload}'")
    Basic.ack(channel, tag)

    {:noreply, channel}
  end
end
