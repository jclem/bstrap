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
    hash = {} of String => String

    File.each_line(path) do |line|
      parts = line.split("=", limit: 2)
      raise InvalidLineException.new if parts.size < 2
      hash[parts[0]] = parts[1]
    end

    hash
  end
end
