# This configuration file is used for Scout APM.
# See our help docs at http://docs.scoutapm.com/#elixir-agent for more information.
# config/scout_apm.exs
use Mix.Config

config :scout_apm,
  name: "Store",
  key: "QTiqZv6iM6aJ5GMIaymu"

config :phoenix, :template_engines,
  eex: ScoutApm.Instruments.EExEngine,
  exs: ScoutApm.Instruments.ExsEngine
