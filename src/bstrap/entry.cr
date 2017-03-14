require "json"

# A descriptor of an environment variable in an app's environment
# (see `AppEnv`).
class Bstrap::Entry
  JSON.mapping(
    description: {type: String, default: ""},
    required: {type: Bool, default: true},
    generator: String?,
    value: String?
  )

  @description = ""
  @required = true
  @generator : String?

  def initialize(@value : String)
  end

  # Merge another `Entry` into this one.
  def merge(entry : Entry)
    @value = entry.value
    @required = entry.required
    self
  end
end
