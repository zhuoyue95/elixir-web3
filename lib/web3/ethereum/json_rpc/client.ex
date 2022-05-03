defmodule Web3.Ethereum.JsonRPC.Client do
  @moduledoc """

  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      unless opts[:endpoint] do
        raise ArgumentError, "missing :endpoint option on use Web3.Ethereum.JsonRPC.Client"
      end

      @endpoint opts[:endpoint]

      use Tesla

      plug Tesla.Middleware.BaseUrl, @endpoint
      plug Tesla.Middleware.JSON
      plug Tesla.Middleware.Timeout, timeout: 15_000

      alias Web3.Ethereum.Util
      alias Web3.Ethereum.Abi.Encode
      alias Web3.Ethereum.Abi.Decode
      alias Web3.Ethereum.JsonRPC.Event
      alias Web3.Ethereum.JsonRPC.EventSpec

      def send_call(req) do
        payload = %{
          jsonrpc: "2.0",
          method: req.method,
          params: req.params,
          id: 1
        }

        with {:ok, result} <- rpc_call(payload) do
          {:ok, decode_result(result, req.method, req.expect)}
        end
      end

      def send_calls(reqs) do
        payload =
          Enum.with_index(reqs, fn req, index ->
            %{
              jsonrpc: "2.0",
              method: req.method,
              params: req.params,
              id: index + 1
            }
          end)

        with {:ok, results} <- rpc_call(payload) do
          {:ok, Enum.zip_with(results, reqs, &decode_result(&1, &2.method, &2.expect))}
        end
      end

      # JSON RPC APIs

      def latest_block_number() do
        payload = %{
          jsonrpc: "2.0",
          method: "eth_blockNumber",
          params: [],
          id: 1
        }

        with {:ok, result} <- rpc_call(payload) do
          {:ok, Util.hex_to_int(result)}
        end
      end

      def get_block_by_number(block_number) do
        payload = %{
          jsonrpc: "2.0",
          method: "eth_getBlockByNumber",
          params: [Util.int_to_hex(block_number), false],
          id: 1
        }

        with {:ok, result} <- rpc_call(payload) do
          {:ok, result}
        end
      end

      # Low level

      def rpc_call(payload) do
        with {:ok, response} <- post("/", payload) do
          handle_response(response)
        end
      end

      defp handle_response(response) do
        case response do
          %Tesla.Env{status: 200, body: %{"result" => result}} ->
            {:ok, result}

          %Tesla.Env{status: 200, body: results} when is_list(results) ->
            {:ok, Enum.map(results, & &1["result"])}

          %Tesla.Env{
            status: 200,
            body: %{"error" => %{"code" => error_code, "message" => error_message}}
          } ->
            {:error, :json_rpc, error_code, error_message}

          %Tesla.Env{status: 200, body: body} ->
            {:error, :bad_body, body}

          %Tesla.Env{status: status_code, body: _body} ->
            {:error, :bad_http_status, status_code}
        end
      end

      # Result decoding

      def decode_result(result, _, nil), do: result

      def decode_result(result, _, func) when is_function(func) do
        result
        |> Util.hex_to_binary()
        |> func.()
      end

      def decode_result(result, "eth_call", codecs) do
        Decode.from_hex(result, codecs)
      end

      def decode_result(result, "eth_getLogs", codecs_map) do
        result
        |> Enum.map(&decode_log(&1, codecs_map))
        |> Enum.reject(& &1.is_removed)
        |> Enum.sort_by(&{&1.block_number, &1.log_index}, :asc)
      end

      defp decode_log(log, codecs_map) do
        %{topics: [topic0 | indexed_topics], data: data} = undecoded_event = Event.from_raw(log)

        {name, topics_codecs, data_codecs} = EventSpec.match_codecs(topic0, codecs_map)

        decoded_indexed = Event.decode_indexed(indexed_topics, topics_codecs)

        undecoded_event
        |> Event.put_name(name)
        |> Event.decode_data({:map, data_codecs})
        |> Map.update!(:data, &Map.merge(&1, decoded_indexed))
      end
    end
  end
end
