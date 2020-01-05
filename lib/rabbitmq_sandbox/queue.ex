defmodule RabbitmqSandbox.Queue do
  use AMQP

  alias RabbitmqSandbox.Conn

  def declare(type) do
    {:ok, conn, channel} = Conn.establish()
    do_declare(type, channel)

    Connection.close(conn)
  end

  defp do_declare(:simple, channel) do
    Queue.declare(channel, "simple_bind", durable: true)
    IO.puts("implicit binding is done --> check the management UI")
  end

  defp do_declare(:direct, channel) do
    Queue.declare(channel, "direct_bind", durable: true)
    Queue.bind(channel, "direct_bind", "amq.direct", routing_key: "demonstrate")
    IO.puts("bound queue 'direct_bind' to exchange 'amq.direct'")
  end

  defp do_declare(:auto_delete, channel) do
    Queue.declare(channel, "auto_delete", durable: true, auto_delete: true)
    IO.puts("declared auto_delete queue")
  end

  defp do_declare(:non_durable, channel) do
    Queue.declare(channel, "non_durable", durable: false)
    IO.puts("declared non_durable queue")
  end

  defp do_declare(:expiring, channel) do
    Queue.declare(channel, "expiring_queue",
      durable: true,
      arguments: [{"x-expires", :signedint, 7500}]
    )

    Queue.bind(channel, "expiring_queue", "amq.direct", routing_key: "ttl")

    IO.puts("declared expiring_queue")
  end
end
