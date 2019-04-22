defmodule Store.RabbitLoggerTest do
  use ExUnit.Case, async: true
  alias Store.RabbitLogger

  setup do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, "test_queue")

    on_exit(fn -> :ok = AMQP.Connection.close(connection) end)
    {:ok, connection: connection, channel: channel, queue: "test_queue", exchange: ""}
  end

  test "publish messages to rabbit", meta do
    params = {:publish, "message"}

    assert {:noreply, _state} = RabbitLogger.handle_cast(params, meta)

    {:ok, payload, meta} = AMQP.Basic.get(meta[:channel], meta[:queue])

    assert payload == "message"
  end
end
