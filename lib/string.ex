defimpl String.Chars, for: Tuple do
  def to_string({a, b}), do: "(#{a}, #{b})"
end
