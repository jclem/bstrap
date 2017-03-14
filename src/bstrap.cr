require "./bstrap/*"
require "json"
require "option_parser"

# The Bstrap CLI utility reads app.json and .env files, merges them, and writes
# the resulting environment back to a .env file.
#
# ```text
# $ bstrap --help
# Usage: bstrap [arguments]
#     -a PATH, --appjson=PATH          Specify app.json file
#     -e PATH, --envfile=PATH          Specify .env file
#     -h, --help                       Show this help
# ```
class Bstrap::CLI
  @app_env = AppEnv.new

  # Run the Bstrap CLI utility.
  def run
    app_path = "./app.json"
    env_path = "./.env"
    out_path = nil

    OptionParser.parse! do |parser|
      parser.banner = "Usage: bstrap [arguments]"

      parser.on("-a PATH", "--appjson=PATH", "Specify app.json file") do |path|
        app_path = path
      end

      parser.on("-e PATH", "--envfile=PATH", "Specify .env file (will be written to unless an output path is given)") do |path|
        env_path = path
      end

      parser.on("-o PATH", "--output=PATH", "The path to which the new environment will be written") do |path|
        out_path = path
      end

      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit 0
      end
    end

    out_path = env_path unless out_path

    parse_app_env(app_path)
    env = parse_envfile_env(env_path)

    @app_env.merge!(env)

    @app_env.each do |(key, value)|
      prompt_value(key, value)
    end

    begin
      File.write(out_path, @app_env.to_envfile)
    rescue Errno
      puts "Could not write to \"#{out_path}\""
      exit 1
    end
  end

  private def parse_app_env(path : String)
    raw_json = File.read(path)
    app_json = JSON.parse(raw_json).as_h?

    if app_json
      env = app_json.fetch("env", nil)

      if env.is_a? Hash
        env.each do |key, value|
          case value
          when String
            @app_env[key] = value
          when Hash
            @app_env.put_entry(key, Entry.from_json(value.to_json))
          end
        end
      end

      environments = app_json.fetch("environments", nil)

      if environments.is_a? Hash
        dev = environments.fetch("development")

        if dev.is_a? Hash
          dev.each do |key, value|
            @app_env[key] = value.to_s
          end
        end
      end
    end
  rescue Errno
    puts "Could not read file \"#{path}\""
    exit 1
  rescue JSON::ParseException
    puts "Could not parse JSON in file \"#{path}\""
    exit 1
  end

  private def parse_envfile_env(path : String)
    app_env = AppEnv.new

    File.read_lines(path).reduce(app_env) do |app_env, line|
      key, value = line.split("=", limit: 2)
      app_env.put_entry(key, Entry.new(value))
      app_env
    end
  rescue Errno
    AppEnv.new
  rescue IndexError # Line was not in key=value format; could not destructure
    puts "Invalid line in \"#{path}\""
    exit 1
  end

  private def prompt_value(key : String, entry : Entry)
    puts "\n\n#{key}"
    puts "=" * key.size

    puts "#{entry.description}\n" if entry.description

    if entry.value
      puts "Current value: #{entry.value}"
      print "Replace current value? (Y/n/q) "
      replace = STDIN.raw(&.read_char)

      case replace
      when 'Y'
        print "\nNew value: "
        entry.value = gets
      when 'q'
        puts "\nQuitting"
        exit 1
      end
    else
      print "Value: "
      entry.value = gets
    end
  end
end

Bstrap::CLI.new.run
