defmodule Utilities.Binary do
  import Bitwise

  def read_u16([head | tail]) when is_integer(head) do
    bor(
      bsl(head, 8),
      hd(tail)
    )
  end

  def read_u16(data) when is_binary(data) do
    data |> :binary.decode_unsigned()
  end
end
