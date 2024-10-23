defmodule SqliteVec.Int8 do
  @moduledoc """
  A vector struct for int8 vectors.
  Vectors are stored as binaries.
  """

  defstruct [:data]

  @doc """
  Creates a new vector from a list, tensor, or vector
  """
  def new(list) when is_list(list) do
    bin = for v <- list, into: <<>>, do: <<v::signed-integer-8>>
    from_binary(<<bin::binary>>)
  end

  def new(%SqliteVec.Int8{} = vector) do
    vector
  end

  if Code.ensure_loaded?(Nx) do
    def new(tensor) when is_struct(tensor, Nx.Tensor) do
      if Nx.rank(tensor) != 1 do
        raise ArgumentError, "expected rank to be 1"
      end

      bin = tensor |> Nx.as_type(:s8) |> Nx.to_binary()
      from_binary(<<bin::binary>>)
    end
  end

  @doc """
  Creates a new vector from its binary representation
  """
  def from_binary(binary) when is_binary(binary) do
    %SqliteVec.Int8{data: binary}
  end

  @doc """
  Converts the vector to its binary representation
  """
  def to_binary(vector) when is_struct(vector, SqliteVec.Int8) do
    vector.data
  end

  @doc """
  Converts the vector to a list
  """
  def to_list(vector) when is_struct(vector, SqliteVec.Int8) do
    <<bin::binary>> = vector.data

    for <<v::signed-integer-8 <- bin>>, do: v
  end

  if Code.ensure_loaded?(Nx) do
    @doc """
    Converts the vector to a tensor
    """
    def to_tensor(vector) when is_struct(vector, SqliteVec.Int8) do
      <<bin::binary>> = vector.data
      Nx.from_binary(bin, :s8)
    end
  end
end

defimpl Inspect, for: SqliteVec.Int8 do
  import Inspect.Algebra

  def inspect(vector, opts) do
    concat(["vec_int8('", Inspect.List.inspect(SqliteVec.Int8.to_list(vector), opts), "')"])
  end
end