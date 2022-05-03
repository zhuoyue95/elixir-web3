defmodule Web3.Ethereum.Abi.Codec do
  @type t ::
          :address
          | :uint
          | :int
          | :bool
          | {:fixed, pos_integer(), pos_integer()}
          | {:ufixed, pos_integer(), pos_integer()}
          | :fixed
          | :ufixed
          | {:bytes, pos_integer()}
          | :function
          | {:array, non_neg_integer(), t()}
          | :bytes
          | :string
          | {:array, t()}
          | {:tuple, list(t())}

  def is_dynamic(:bytes), do: true
  def is_dynamic(:string), do: true
  def is_dynamic({:array, _codec}), do: true

  def is_dynamic({:array, _size, codec}) do
    is_dynamic(codec)
  end

  def is_dynamic({:tuple, codecs}) do
    Enum.any?(codecs, &is_dynamic/1)
  end

  def is_dynamic(_), do: false
end
