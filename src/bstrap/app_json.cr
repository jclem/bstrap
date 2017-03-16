require "json"

module Bstrap::AppJSON
  extend self

  class InvalidAppJSON < Exception
  end

  alias JSONHash = Hash(String, JSON::Type)
  alias Parsed = Hash(String, String | JSONHash)

  # Parses the app.json file at *path* and merges in the given environment.
  def parse_app_json_env(path : String, env = "development") : Parsed
    raw_json = File.read(path)

    if app_json = JSON.parse(raw_json).as_h?
      env_hash = parse_env(app_json)
      add_extra_env(env_hash, app_json, env)
    else
      raise InvalidAppJSON.new("app.json file must be an object")
    end
  end

  private def add_extra_env(env_hash : Parsed, app_json : JSONHash, extra_env : String) : Parsed
    return env_hash unless envs = app_json.fetch("environments", nil).as?(Hash)
    return env_hash unless extra_env = envs.fetch(extra_env, nil).as?(Hash)

    extra_env.reduce(env_hash) do |env_hash, (key, value)|
      if value.is_a?(String)
        env_hash[key] = value
      else
        raise InvalidAppJSON.new(
          %(Env vars in "environments" must be strings))
      end

      env_hash
    end
  end

  private def parse_env(app_json : JSONHash) : Parsed
    parsed = {} of String => String | JSONHash

    case env = app_json.fetch("env", nil)
    when Hash
      env.reduce(parsed) do |parsed, (key, value)|
        case value
        when String
          parsed[key] = value
        when JSONHash
          parsed[key] = value
        else
          raise InvalidAppJSON.new(
            %(app.json "env" vars must be a string or object))
        end

        parsed
      end
    when nil
      parsed
    else
      raise InvalidAppJSON.new(%(app.json "env" must be an object))
    end
  end
end
