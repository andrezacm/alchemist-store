defmodule Store.RabbitLogger do
  use GenServer

  # Client API

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      %{queue: "timeline", exchange: "timeline"},
      name: :publisher
    )
  end

  def publish(message) do
    IO.inspect("Logging #{message}")
    GenServer.cast(:publisher, {:publish, message})
  end

  # Server API

  def init(%{queue: queue_name, exchange: exchange_name}) do
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)

    AMQP.Queue.declare(channel, queue_name, [durable: true])
    AMQP.Exchange.declare(channel, exchange_name, :topic, [durable: true])
    AMQP.Queue.bind(channel, queue_name, exchange_name)

    {:ok, %{
      channel: channel,
      connection: connection,
      queue: queue_name,
      exchange: exchange_name
    }}
  end

  def handle_cast({:publish, message}, state) do
    AMQP.Basic.publish(
      state.channel, state.exchange, state.queue, message
    )
    {:noreply, state}
  end

  def terminate(_reason, state) do
    AMQP.Connection.close(state.connection)
  end
end
