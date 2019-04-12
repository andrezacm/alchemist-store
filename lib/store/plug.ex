errors = [
  {Ecto.CastError, 400},
  {Ecto.Query.CastError, 400},
  {Ecto.NoResultsError, 404},
  {Ecto.StaleEntryError, 409},
  {Ecto.InvalidChangesetError, 422}
]

for {exception, status_code} <- errors do
  defimpl Plug.Exception, for: exception do
    def status(_), do: unquote(status_code)
  end
end
