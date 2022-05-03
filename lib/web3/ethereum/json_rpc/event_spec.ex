defmodule Web3.Ethereum.JsonRPC.EventSpec do
  @enforce_keys [:name, :signature, :topics_codecs, :data_codecs]
  defstruct [:name, :signature, :topics_codecs, :data_codecs]

  @type t :: %__MODULE__{
          name: atom(),
          signature: String.t(),
          topics_codecs: keyword(Codec.t()),
          data_codecs: keyword(Codec.t())
        }

  alias Web3.Ethereum.Abi.Encode

  def new(name, signature, topics_codecs \\ [], data_codecs) do
    %__MODULE__{
      name: name,
      signature: signature,
      topics_codecs: topics_codecs,
      data_codecs: data_codecs
    }
  end

  def topic_hex(%__MODULE__{signature: sig}) do
    Encode.event(sig)
  end

  def to_codecs_map(events) do
    Map.new(events, fn e ->
      {Encode.event(e.signature), {e.name, e.topics_codecs, e.data_codecs}}
    end)
  end

  def match_codecs(topic0, codecs_map) do
    Map.fetch!(codecs_map, topic0)
  end
end
