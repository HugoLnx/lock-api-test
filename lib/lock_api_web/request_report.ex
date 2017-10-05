defmodule LockApi.RequestReport do
  def measure_and_report(controller_module, action_name, started_at) do
      metadata = build_metadata(controller_module, action_name)
      metadata
      |> build_name
      |> report_request_metrics(measure_duration(started_at), metadata)
  end
  
  defp measure_duration(nil), do: 0
  defp measure_duration(started_at) do 
    :erlang.monotonic_time(:micro_seconds) - started_at
  end

  defp build_metadata(controller_module, action_name), do: %{
    type: "controller",
    controller: format_controller_name(controller_module),
    action: action_name
  }

  defp format_controller_name(controller) do
    controller
    |> Macro.underscore
    |> String.split("/")
    |> List.last
  end

  defp build_name(%{controller: controller, action: action}), do: "#{controller}/#{action}"
  
  @alchemetrics Application.get_env(:severino, :alchemetrics, Alchemetrics)
  defp report_request_metrics(metric_name, duration, metadata), do: %{
    count: @alchemetrics.count(metric_name, %{metadata: metadata}),
    duration: @alchemetrics.report(metric_name, duration, %{metrics: [:p99, :p95, :avg, :min, :max], metadata: metadata})
  }
end

defmodule LockApiWeb.RequestTrackerBegin do
  import Plug.Conn
 
  def init(opts), do: opts

  def call(conn, _options) do
    request_started_at = :erlang.monotonic_time(:micro_seconds)
    assign conn, :request_start_time, request_started_at
  end
end

defmodule LockApiWeb.RequestTrackerEnd do
  @behaviour Plug
  import Phoenix.Controller
  alias LockApi.RequestReport

  def init(opts), do: opts

  def call(conn, _options) do
    Plug.Conn.register_before_send conn, fn conn ->
      RequestReport.measure_and_report controller_module(conn), action_name(conn), started_at(conn)
      conn
    end
  end

  defp started_at(conn), do: conn.assigns[:request_start_time]
end
