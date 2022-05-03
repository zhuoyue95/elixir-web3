defmodule Web3.Ethereum.Abi.Encode do
  @moduledoc """

  """

  # APIs

  def function_call(encodings, func_sig) do
    function(func_sig) <> encode(encodings)
  end

  def function_call(func_sig, args, encoders) do
    args
    |> Enum.zip_with(encoders, fn arg, encoder ->
      apply(__MODULE__, encoder, [arg])
    end)
    |> function_call(func_sig)
  end

  def encode(encodings) do
    do_encode(encodings, 32 * length(encodings))
  end

  def do_encode(encodings, tail_pointer, heads \\ [], tails \\ [])

  def do_encode([], _, heads, tails) do
    (tails ++ heads)
    |> Enum.reverse()
    |> Enum.join()
  end

  def do_encode([x | xs], tail_pointer, heads, tails) do
    case x do
      {nil, encoded} ->
        do_encode(xs, tail_pointer, [encoded | heads], tails)

      {tail_size, encoded} ->
        do_encode(
          xs,
          tail_pointer + tail_size,
          [<<tail_pointer::integer-unsigned-256>> | heads],
          [encoded | tails]
        )
    end
  end

  # Encoders

  def function(func_sig) do
    <<digest::binary-size(4), _::binary>> = ExKeccak.hash_256(func_sig)
    digest
  end

  def event(event_sig) do
    ExKeccak.hash_256(event_sig)
  end

  def address(addr) do
    {nil, <<0::size(96), addr::binary>>}
  end

  def uint(n) do
    {nil, <<n::integer-unsigned-256>>}
  end

  def int(n) do
    {nil, <<n::integer-signed-256>>}
  end

  def binary(x) do
    size = byte_size(x)
    padding_size = Integer.mod(-size, 32)
    encoded = <<size::integer-unsigned-256, x::binary, 0::size(padding_size)-unit(8)>>

    {32 + size + padding_size, encoded}
  end

  def string(x), do: binary(x)

  def static_binary(x) do
    padding_size = 32 - byte_size(x)
    {nil, <<x::binary, 0::size(padding_size)-unit(8)>>}
  end

  # Potentially problematic
  def tuple(encodings) do
    is_dynamic = Enum.any?(encodings, &(elem(&1, 0) != nil))
    encoded = encode(encodings)
    {(is_dynamic || nil) && byte_size(encoded), encoded}
  end

  # Private Helpers

  def len(_data, codec)
      when codec in [:uint, :int, :address, :bool] do
    32
  end

  def right_pad_32(x) do
    padding_size = Integer.mod(-byte_size(x), 32)
    <<x::binary, 0::size(padding_size)-unit(8)>>
  end
end
