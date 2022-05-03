defmodule Web3.Ethereum.JsonRPC.Params do
  def eth_call(contract_address) do
    %{to: hex_from_binary(contract_address)}
  end

  def with_sender(token, address) do
    token
    |> Map.put(:from, hex_from_binary(address))
  end

  def with_data(token, data) do
    token
    |> Map.put(:data, hex_from_binary(data))
  end

  defp hex_from_binary(addr) do
    "0x" <> Base.encode16(addr, case: :lower)
  end
end
