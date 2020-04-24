defmodule KinextLiveview.Repo do
  use Ecto.Repo,
    otp_app: :kinext_liveview,
    adapter: Ecto.Adapters.Postgres
end
