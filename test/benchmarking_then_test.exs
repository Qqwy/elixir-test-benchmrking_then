defmodule BenchmarkingThenTest do
  use ExUnit.Case
  doctest BenchmarkingThen

  test "greets the world" do
    assert BenchmarkingThen.hello() == :world
  end
end
