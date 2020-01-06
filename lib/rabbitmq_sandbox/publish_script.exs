defmodule RabbitmqSandbox.PublishScript do
  use AMQP

  alias RabbitmqSandbox.Conn

  def run() do
    {:ok, _conn, channel} = Conn.establish()

    body = "from tracing published!"

    Basic.publish(channel, "amq.direct", "pika_queue", body)

    IO.gets("press ctrl+c to stop or any key to continue publishing")
    run()
  end
end

RabbitmqSandbox.PublishScript.run()
