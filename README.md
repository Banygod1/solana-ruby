
# Solana-Ruby

Solana-Ruby is a Ruby SDK for interacting with the Solana blockchain. It allows you to easily make requests to the Solana network from your Ruby applications.

## TODO
- ✅ Add more unit testing (Completed - see [TESTING.md](TESTING.md))
- Implement basic transactions in the library (this should be done for 2025)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solana-ruby', '~> 0.1.1'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install solana-ruby
```

## Usage

### Initialize the Client

```ruby
require 'solana-ruby'

client = Solana::Client.new
```

## Documentation

You can find the full documentation [here](https://fabricerenard12.github.io/solana-ruby).

## Testing

The project includes comprehensive unit tests covering all major components. See [TESTING.md](TESTING.md) for detailed information about running tests and test coverage.

### Quick Test Run

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/client_spec.rb
bundle exec rspec spec/keypair_spec.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fabricerenard12/solana-ruby.

Please ensure all tests pass before submitting pull requests.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
