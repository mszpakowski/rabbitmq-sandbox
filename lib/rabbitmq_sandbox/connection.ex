defmodule RabbitmqSandbox.Conn do
  use AMQP

  def establish(opts \\ []) do
    {:ok, conn} = Connection.open(opts)
    {:ok, channel} = Channel.open(conn)
    {:ok, conn, channel}
  end
end
