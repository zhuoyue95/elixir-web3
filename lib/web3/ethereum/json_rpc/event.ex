defmodule Web3.Ethereum.JsonRPC.Event do
  defstruct [
    :name,
    :topics,
    :address,
    :data,
    :block_number,
    :block_hash,
    :tx_hash,
    :tx_index,
    :log_index,
    :is_removed
  ]

  @type t :: %__MODULE__{
          name: atom(),
          topics: list(binary()),
          address: binary(),
          data: term(),
          block_number: non_neg_integer(),
          block_hash: binary(),
          tx_hash: binary(),
          tx_index: non_neg_integer(),
          log_index: non_neg_integer(),
          is_removed: boolean()
        }

  alias Web3.Ethereum.Util
  alias Web3.Ethereum.Abi.Decode

  def from_raw(log) do
    %__MODULE__{
      topics: Enum.map(log["topics"], &Util.hex_to_binary/1),
      address: Util.hex_to_binary(log["address"]),
      data: log["data"],
      block_number: Util.hex_to_int(log["blockNumber"]),
      block_hash: Util.hex_to_binary(log["blockHash"]),
      tx_hash: Util.hex_to_binary(log["transactionHash"]),
      tx_index: Util.hex_to_int(log["transactionIndex"]),
      log_index: Util.hex_to_int(log["logIndex"]),
      is_removed: log["removed"]
    }
  end

  def put_name(event, name) do
    Map.put(event, :name, name)
  end

  def decode_data(undecoded_event, {:map, []}) do
    Map.put(undecoded_event, :data, %{})
  end

  def decode_data(undecoded_event, codecs) do
    Map.update!(undecoded_event, :data, &Decode.from_hex(&1, codecs))
  end

  def decode_indexed(indexed_topics, codecs) do
    indexed_topics
    |> Enum.zip_with(codecs, fn topic, {key, codec} ->
      {key, Decode.from_bytes(topic, codec)}
    end)
    |> Map.new()
  end
end
