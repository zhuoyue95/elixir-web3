defmodule Web3.Ethereum.JsonRPC do
  alias Web3.Ethereum.Util
  alias Web3.Ethereum.JsonRPC.EventSpec

  def read(data, codec, contract_address, default_block \\ "latest")

  def read(data, codec, contract_address, block_number) when is_integer(block_number) do
    read(data, codec, contract_address, Util.int_to_hex(block_number))
  end

  def read(data, codec, contract_address, default_block) do
    %{
      method: "eth_call",
      params: [
        %{
          to: Util.to_hex_if_necessary(contract_address),
          data: Util.binary_to_hex(data)
        },
        default_block
      ],
      expect: codec
    }
  end

  def read_logs(events, from_block, to_block, emitter_address) do
    codecs_map = EventSpec.to_codecs_map(events)

    %{
      method: "eth_getLogs",
      params: [
        %{
          address: Util.to_hex_if_necessary(emitter_address),
          topics: [
            events
            |> Enum.map(&EventSpec.topic_hex/1)
            |> Enum.map(&Util.binary_to_hex/1)
          ],
          fromBlock: Util.int_to_hex(from_block),
          toBlock: Util.int_to_hex(to_block)
        }
      ],
      expect: codecs_map
    }
  end

  def read_storage(slot_index, decode_func, contract_address, default_block \\ "latest") do
    %{
      method: "eth_getStorageAt",
      params: [
        Util.to_hex_if_necessary(contract_address),
        Util.int_to_hex(slot_index),
        default_block
      ],
      expect: decode_func
    }
  end
end
