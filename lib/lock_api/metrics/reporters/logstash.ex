defmodule LockApi.Metrics.Reporters.Logstash do
  use Alchemetrics.CustomReporter
  alias LockApi.Wrappers.Udp
  alias LockApi.Metrics.MetricData
  require Logger

  def init(options) do
    case Udp.open do
      {:ok, sock} ->
        Logger.info "Logstash Reporter initialized"
        {:ok, %{socket: sock, hostname: options[:hostname], port: options[:port]}}
      {:error, _error_message} = error ->
        Logger.error "#{inspect error}"
        error
    end
  end

  def report(metric_name, datapoint, value, options) do
    metric_name
    |> MetricData.build(datapoint, value, options[:metadata])
    |> Poison.encode!
    |> send_metric(options)
  end

  defp send_metric(data, options) do
    {sock, host, port} = extract_options(options)

    Udp.send(sock, host, port, data)
    |> case do
      :ok -> nil
      {:error, reason} -> Logger.error "Error while sending metric: #{reason}"
    end
  end

  defp extract_options(opts) do
    hostname = String.to_charlist(opts[:hostname])
    {opts[:socket], hostname, opts[:port]}
  end
end

defmodule LockApi.Wrappers.Udp do
  def open, do: :gen_udp.open(0)

  def send(sock, hostname, port, data) do
    :gen_udp.send(sock, hostname, port, data)
  end
end

defmodule LockApi.Metrics.MetricData do
  import Map

  def build(metric_name, data_point, value, metadata) do
    initial_map()
    |> put(:name, metric_name)
    |> put(:value, value)
    |> put(:data_point, data_point |> format_data_point)
    |> merge(metadata |> Enum.into(%{}))
  end

  defp initial_map, do: %{
    "client": Application.get_env(:lock_api, :app_name, "lock_api"),
    "owner": Application.get_env(:lock_api, :owner, "lock_api"),
    "timestamp": :os.system_time(:milli_seconds),
    "ip": get_node_ip(),
    "hostname": :inet.gethostname |> elem(1) |> to_string
  }

  defp format_data_point(data_point) when is_number(data_point), do: Integer.to_string(data_point)
  defp format_data_point(data_point), do: data_point

  defp get_node_ip do
    :inet.getif
    |> elem(1)
    |> List.first
    |> elem(0)
    |> Tuple.to_list
    |> Enum.join(".")
  end
end
