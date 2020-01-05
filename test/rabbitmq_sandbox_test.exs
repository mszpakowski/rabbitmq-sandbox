defmodule RabbitmqSandboxTest do
  use ExUnit.Case
  doctest RabbitmqSandbox

  test "greets the world" do
    assert RabbitmqSandbox.hello() == :world
  end
end
