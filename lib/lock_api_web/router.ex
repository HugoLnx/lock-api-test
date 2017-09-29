defmodule LockApiWeb.Router do
  use LockApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LockApiWeb do
    pipe_through :api
    post "/users/:id/locks/:lock_id", LocksController, :get_lock
    post "/users/:id/locks", LocksController, :get_lock
    put "/users/:id/locks/:lock_id", LocksController, :renew_lock
  end
end
