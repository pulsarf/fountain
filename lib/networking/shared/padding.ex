defmodule Padding do
  def generate_padding() do
    random_length = Enum.random(0..500)

    random_string = :crypto.strong_rand_bytes(random_length) |> Base.encode64() |> binary_part(0, random_length)

    random_string
  end
end
