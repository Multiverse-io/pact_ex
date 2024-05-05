defmodule PactEx.Git do
  @moduledoc """
  Utilities for interacting with git.
  """
  @spec get_hash!() :: String.t()
  def get_hash! do
    case System.cmd("git", ["rev-parse", "HEAD"]) do
      {output, 0} -> String.trim_trailing(output)
      _ -> raise "Unable to determine the current git commit hash"
    end
  end

  @spec get_branch!() :: String.t()
  def get_branch! do
    case System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"]) do
      {output, 0} -> String.trim_trailing(output)
      _ -> raise "Unable to determine the current git branch"
    end
  end
end
