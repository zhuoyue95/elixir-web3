defmodule Web3.Ethereum.JsonRPC.Request do
  @type t :: %{
          id: pos_integer(),
          method: String.t(),
          params: list(map() | String.t()),
          decoder: Web3.Ethereum.Abi.Codec.t()
        }

  @type call_req :: %{
          from: binary() | nil,
          to: binary(),
          gas: non_neg_integer() | nil,
          gas_price: non_neg_integer() | nil,
          value: non_neg_integer() | nil,
          data: binary() | nil
        }
end
