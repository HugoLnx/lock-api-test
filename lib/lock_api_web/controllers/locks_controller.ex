defmodule LockApiWeb.LocksController do
  use LockApiWeb, :controller

  @max_locks 2
  @tolerance %{milliseconds: 30_000, max_locks: 5}

  def get_lock(conn, %{"id" => user_id} = opts) do
    lock_opts = %{tolerance: @tolerance}
    lock_opts = if Map.has_key?(opts, "lock_id"),
    do: lock_opts |> Map.put(:lock_id, opts["lock_id"]),
    else: lock_opts
    SimultaneousAccessLock.get_lock(user_id, @max_locks, lock_opts)
    |> case do
      {:ok, lock_id} -> send_resp(conn, 200, lock_id)
      {:error, _} -> send_resp(conn, 403, "")
    end
  end

  def renew_lock(conn, %{"id" => user_id, "lock_id" => lock_id}) do
    SimultaneousAccessLock.renew_lock(user_id, lock_id, %{max_locks: @max_locks, tolerance: @tolerance})
    |> case do
      {:ok, lock_id} -> send_resp(conn, 200, lock_id)
      {:error, _} -> send_resp(conn, 403, "")
    end
  end
end
