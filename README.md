# bstrap

An initializer for development environments, `bstrap` reads environment
variables from [app.json][app_json] files, combines them with variables from
dotenv files (a file with newline-separated KEY=value pairs), and outputs
new dotenv files. Along the way, it can prompt the user for missing values.

## Installation

### OS X

Install via homebrew:

```
brew tap jclem/bstrap
brew install bstrap
```

### Linux

[Download the latest release][release] and put it in your PATH.

## Usage

For usage instructions, enter `bstrap --help` into your terminal.

## Contributing

1. Fork it ( https://github.com/jclem/bstrap/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jclem](https://github.com/jclem) Jonathan Clem - creator, maintainer

[app_json]: https://devcenter.heroku.com/articles/app-json-schema
[release]: https://github.com/jclem/bstrap/releases/latest
