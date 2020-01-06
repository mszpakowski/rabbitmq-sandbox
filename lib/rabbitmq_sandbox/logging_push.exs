defmodule RabbitmqSandbox.LoggingPush do
  alias RabbitmqSandbox.Conn

  def run(exchange, routing) do
    body = "published to '#{exchange}' with routing_key '#{routing}'"

    {:ok, _conn, channel} = Conn.establish()

    AMQP.Basic.publish(channel, exchange, routing, body)
  end
end

[exchange, routing | _] = System.argv()
RabbitmqSandbox.LoggingPush.run(exchange, routing)
