defmodule StoreWeb.Plugs.RequestLogger do
  import Plug.Conn

  def init(_), do: nil

  def call(conn, _default) do
    {:ok, log} =
      JSON.encode(%{
        host: conn.host,
        method: conn.method,
        requested_path: conn.request_path,
        req_headers: conn.req_headers,
        query_string: conn.query_string,
        params: conn.params,
        resp_body: conn.resp_body,
        resp_headers: conn.resp_headers,
        status: conn.status
      })

    Plug.Conn.register_before_send(conn, fn conn ->
      Store.RabbitLogger.publish(log)
      conn
    end)
  end
end
