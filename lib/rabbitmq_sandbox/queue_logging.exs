defmodule RabbitmqSandbox.QueueLogging do
  use AMQP

  alias RabbitmqSandbox.Conn

  def run() do
    all_exchanges = get_exchange_names()

    {:ok, _conn, channel} = Conn.establish()

    log_queue = "logging_queue"

    Queue.declare(channel, log_queue, durable: true)

    for name <- all_exchanges do
      if name != "", do: Queue.bind(channel, log_queue, name, routing_key: "#")
    end

    IO.puts("start consuming")

    Basic.consume(channel, log_queue, nil, no_ack: true)

    start_consuming()
  end

  defp get_exchange_names() do
    %{body: body} =
      HTTPoison.get!(
        "http://localhost:15672/api/exchanges",
        [],
        hackney: [basic_auth: {"guest", "guest"}]
      )

    body
    |> Jason.decode!()
    |> Enum.reduce([], fn exchange, acc ->
      case exchange["vhost"] do
        "/" -> [exchange["name"] | acc]
        _other -> acc
      end
    end)
  end

  defp start_consuming() do
    receive do
      {:basic_deliver, payload, _method} ->
        IO.puts("logged: \n \"#{payload}\"")
        start_consuming()
    end
  end
end

RabbitmqSandbox.QueueLogging.run()
