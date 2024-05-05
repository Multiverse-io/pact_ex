defmodule PactEx.Matchers do
  @spec like(value :: term()) :: map()
  def like(value) do
    %{
      "pact:matcher:type" => "type",
      "value" => value
    }
  end

  @spec each_like(value :: term()) :: map()
  def each_like(value) do
    %{
      "pact:matcher:type" => "type",
      "value" => [value]
    }
  end

  @spec regex(value :: term(), regex :: Regex.t()) :: map()
  def regex(value, regex) do
    %{
      "pact:matcher:type" => "regex",
      "value" => value,
      "regex" => Regex.source(regex)
    }
  end
end
