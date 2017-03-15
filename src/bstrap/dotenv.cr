# Parses dotenv-formatted files into a `Hash(String, String)`.
module Bstrap::Dotenv
  extend self

  # An exception raised if there is an invalid line in a dotenv-formatted file.
  class InvalidLineException < Exception
  end

  # Parses a dotenv-formatted file into a `Hash(String, String)`.
  #
  # ```
  # Bstrap::Dotenv.parse_dotenv(".env") # => {"FOO" => "bar"}
  # ```
  def parse_dotenv(path : String) : Hash(String, String)
    File.read_lines(path).reduce({} of String => String) do |hash, line|
      key, value = line.split("=", limit: 2)
      hash[key] = value
      hash
    end
  rescue IndexError # Line was not in key=value format
    raise InvalidLineException.new
  end
end
