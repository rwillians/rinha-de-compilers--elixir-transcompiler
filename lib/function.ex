defimpl String.Chars, for: Function do
  def to_string(_), do: "<#closure>"
end
