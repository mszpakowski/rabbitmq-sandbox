defmodule RabbitmqSandbox.Conn do
  use AMQP

  def establish() do
    {:ok, conn} = Connection.open()
    {:ok, channel} = Channel.open(conn)
    {:ok, conn, channel}
  end
end
