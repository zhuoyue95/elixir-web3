defmodule Web3.Ethereum.Util do
  def binary_to_hex(binary) do
    "0x" <> Base.encode16(binary, case: :lower)
  end

  def hex_to_binary("0x" <> hex) do
    :binary.decode_hex(hex)
  end

  def int_to_hex(n) do
    "0x" <> Integer.to_string(n, 16)
  end

  def hex_to_int("0x" <> hex) do
    String.to_integer(hex, 16)
  end

  def to_hex_if_necessary("0x" <> _ = hex_str), do: hex_str

  def to_hex_if_necessary(binary) when is_binary(binary) do
    binary_to_hex(binary)
  end

  def to_hex_if_necessary(n) when is_integer(n) and n >= 0 do
    int_to_hex(n)
  end

  def scaled_to_base(n, numeric_scale) do
    n
    |> Decimal.new()
    |> Decimal.div("1e#{numeric_scale}")
  end

  def base_to_scaled(k, numeric_scale) do
    k
    |> Decimal.mult("1e#{numeric_scale}")
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer()
  end
end
