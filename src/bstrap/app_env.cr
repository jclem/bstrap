require "./entry"

# A representation of the environment that an app needs in order to run as
# defined in both app.json and .env files.
class Bstrap::AppEnv
  include Enumerable({String, Entry})

  @env = {} of String => Entry

  # Returns the value of a given environment variable represented by *key*.
  #
  # ```
  # env = Bstrap::AppEnv.new
  # env["foo"] = "bar"
  # env["foo"] # => "bar"
  # ```
  def [](key : String) : String?
    entry = @env.fetch(key, nil)
    entry.value if entry
  end

  # Sets the value of the environment variable *key* to the string *value*.
  #
  # ```
  # env = Bstrap::AppEnv.new
  # env["foo"] = "bar"
  # env["foo"] # => "bar"
  # ```
  def []=(key : String, value : String) : String
    existing_entry = get_entry(key)

    if existing_entry
      existing_entry.value = value
    else
      @env[key] = Entry.new(value)
    end

    value
  end

  # Gets the raw `Entry` for the given environment variable *key*.
  def get_entry(key : String) : Entry?
    @env.fetch(key, nil)
  end

  # Puts a raw `Entry` into the environment variable *key*.
  #
  # ```
  # env = Bstrap::AppEnv.new
  # env.put_entry("foo", Bstrap::Entry.new("bar"))
  # ```
  def put_entry(key : String, entry : Entry) : Entry
    @env[key] = entry
  end

  # Iterates over the key/entry pairs (as tuples) in the environment.
  def each(&block : {String, Entry} ->)
    @env.each do |(key, entry)|
      yield({key, entry})
    end
  end

  # Merges another `AppEnv` into this one.
  def merge!(env : AppEnv) : AppEnv
    @env.merge!(env.env) do |key, self_entry, other_entry|
      self_entry.merge(other_entry)
    end

    self
  end

  # Returns this environment as an envfile string, which is a newline-separated
  # list of the environment variables as "key=value" pairs.
  def to_envfile : String
    map do |key, entry|
      {key, entry.value}
    end.sort do |(a_key, a_value), (b_key, b_value)|
      a_key <=> b_key
    end.reduce("") do |envfile, (key, value)|
      envfile + "#{key}=#{value}\n"
    end
  end

  # Returns the app environment as a hash.
  def to_h : Hash(String, String?)
    reduce({} of String => String?) do |hash, (key, entry)|
      hash[key] = entry.value
      hash
    end
  end

  protected def env
    @env
  end
end
