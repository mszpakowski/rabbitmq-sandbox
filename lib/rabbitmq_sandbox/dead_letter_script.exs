defmodule RabbitmqSandbox.DeadLetterScript do
  use AMQP

  alias RabbitmqSandbox.Conn

  def run() do
    {:ok, _conn, channel} = Conn.establish()

    publish(channel)
  end

  defp publish(channel, counter \\ 0) do
    counter = counter + 1
    body = "dead valley message - #{counter}"
    Basic.publish(channel, "", "dead_letter", body)

    "sent to dead letter!, press q to quit or any key to send more messages"
    |> IO.gets()
    |> String.trim_trailing()
    |> case do
      "q" ->
        :ok

      _ ->
        publish(channel, counter)
    end
  end
end

RabbitmqSandbox.DeadLetterScript.run()
