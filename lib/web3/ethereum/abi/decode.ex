defmodule Web3.Ethereum.Abi.Decode do
  alias Web3.Ethereum.Abi.Codec

  # APIs

  def from_hex("0x", _), do: <<>>

  def from_hex("0x" <> hex, codecs) do
    hex
    |> Base.decode16!(case: :lower)
    |> from_bytes(codecs)
  end

  def from_bytes(byte_pack, codecs) do
    read(byte_pack, 0, codecs)
  end

  # Implementations

  @spec read(
          binary(),
          non_neg_integer(),
          Codec.t() | list(Codec.t()) | {:map, keyword(Codec.t())}
        ) :: term()
  def read(byte_pack, scanned_offset, codecs) when is_list(codecs) do
    read_tuple(byte_pack, scanned_offset, codecs)
  end

  def read(byte_pack, scanned_offset, {:map, codecs}) do
    byte_pack
    |> read_tuple(scanned_offset, Keyword.values(codecs))
    |> Enum.zip_with(Keyword.keys(codecs), &{&2, &1})
    |> Map.new()
  end

  def read(byte_pack, scanned_offset, codec) do
    if Codec.is_dynamic(codec) do
      position = peak_32_bytes(byte_pack, scanned_offset)
      length = peak_32_bytes(byte_pack, position)
      read_dynamic(byte_pack, position + 32, length, codec)
    else
      read_static(byte_pack, scanned_offset, codec)
    end
  end

  @spec read_dynamic(binary, non_neg_integer, non_neg_integer, Codec.t()) :: term
  def read_dynamic(byte_pack, position, length, :string) do
    :binary.part(byte_pack, position, length)
  end

  def read_dynamic(byte_pack, position, length, :bytes) do
    :binary.part(byte_pack, position, length)
  end

  def read_dynamic(byte_pack, position, length, {:array, sub_codec}) do
    read_array(byte_pack, position, length, sub_codec)
  end

  def read_array(byte_pack, position, length, codec, fetched \\ [])

  def read_array(_, _, 0, _, fetched), do: Enum.reverse(fetched)

  def read_array(byte_pack, position, length, codec, fetched) do
    data = read(byte_pack, position, codec)
    read_array(byte_pack, position + 32, length - 1, codec, [data | fetched])
  end

  def read_tuple(byte_pack, position, codecs, fetched \\ [])

  def read_tuple(_, _, [], fetched), do: Enum.reverse(fetched)

  def read_tuple(byte_pack, position, [codec | codecs], fetched) do
    data = read(byte_pack, position, codec)
    read_tuple(byte_pack, position + 32, codecs, [data | fetched])
  end

  @spec read_static(binary, non_neg_integer, :address | :uint) :: binary | non_neg_integer
  def read_static(byte_pack, position, :address) do
    :binary.part(byte_pack, position + 12, 20)
  end

  def read_static(byte_pack, position, :uint) do
    :binary.part(byte_pack, position, 32)
    |> :binary.decode_unsigned()
  end

  def read_static(byte_pack, position, :int) do
    <<x::integer-signed-256>> = :binary.part(byte_pack, position, 32)
    x
  end

  def read_static(byte_pack, position, :bool) do
    read_static(byte_pack, position, :uint) == 1
  end

  def read_static(byte_pack, position, {:bytes, n}) when is_integer(n) and n <= 32 do
    :binary.part(byte_pack, position, n)
  end

  @spec peak_32_bytes(binary, non_neg_integer) :: non_neg_integer
  def peak_32_bytes(byte_pack, from) do
    byte_pack
    |> :binary.part(from, 32)
    |> :binary.decode_unsigned()
  end
end
