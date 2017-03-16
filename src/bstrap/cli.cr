require "./*"
require "json"
require "option_parser"

# The Bstrap CLI utility reads app.json and .env files, merges them, and writes
# the resulting environment back to a .env file.
#
# ```text
# $ bstrap --help
# Usage: bstrap [arguments]
#     -a PATH, --appjson=PATH          Specify app.json file
#     -f PATH, --envfile=PATH          Specify .env file (will be written to unless an output path is given)
#     -o PATH, --output=PATH           The path to which the new environment will be written
#     -e ENV, --env=ENV                Specify the environment to merge from the app.json
#     -P, --noprompt                   Do not prompt for values
#     -h, --help                       Show this help
# ```
class Bstrap::CLI
  @app_env = AppEnv.new

  # Run the Bstrap CLI utility.
  def run : Nil
    app_path = "./app.json"
    env_path = "./.env"
    out_path = nil
    current_env = "development"
    prompt = true

    OptionParser.parse! do |parser|
      parser.banner = "Usage: bstrap [arguments]"

      parser.on("-a PATH", "--appjson=PATH", "Specify app.json file") do |path|
        app_path = path
      end

      parser.on("-f PATH", "--envfile=PATH", "Specify .env file (will be written to unless an output path is given)") do |path|
        env_path = path
      end

      parser.on("-o PATH", "--output=PATH", "The path to which the new environment will be written") do |path|
        out_path = path
      end

      parser.on("-e ENV", "--env=ENV", "Specify the environment to merge from the app.json") do |environment|
        current_env = environment
      end

      parser.on("-P", "--noprompt", "Do not prompt for values") do
        prompt = false
      end

      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit 0
      end
    end

    out_path = env_path unless out_path

    @app_env = parse_app_json_env(app_path, current_env)
    env = parse_envfile_env(env_path)

    @app_env.merge!(env)

    @app_env.each do |(key, value)|
      prompt_value(key, value) if prompt
    end

    begin
      File.write(out_path.as(String), @app_env.to_envfile)
    rescue Errno
      puts "Could not write to \"#{out_path}\""
      exit 1
    end
  end

  private def parse_app_json_env(path : String, current_env : String)
    AppEnv.new(AppJSON.parse_app_json_env(path, current_env))
  rescue ex : AppEnv::InvalidEntry
    puts ex
    exit 1
  rescue ex : AppJSON::InvalidAppJSON
    puts %(Invalid app.json file at "#{path}": #{ex.message})
    exit 1
  rescue Errno
    puts %(Unable to read app.json file at "#{path}")
    exit 1
  end

  private def parse_envfile_env(path : String)
    AppEnv.new(Dotenv.parse_dotenv(path))
  rescue Errno
    AppEnv.new
  rescue Dotenv::InvalidLineException
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
      replace = gets

      case replace
      when "Y"
        print "\nNew value: "
        entry.value = gets
      when "q"
        puts "\nQuitting"
        exit 1
      end
    else
      print "Value: "
      entry.value = gets
    end
  end
end
