# Testing Documentation for Solana-Ruby

This document describes the testing setup and how to run tests for the Solana-Ruby library.

## Overview

The Solana-Ruby library includes comprehensive unit tests covering all major components:

- **Client Tests** (`spec/client_spec.rb`): HTTP and WebSocket client functionality
- **Keypair Tests** (`spec/keypair_spec.rb`): Cryptographic keypair operations
- **Utils Tests** (`spec/utils_spec.rb`): Encoding/decoding utilities
- **Version Tests** (`spec/version_spec.rb`): Version management
- **Integration Tests** (`spec/integration_spec.rb`): End-to-end scenarios

## Test Structure

### Test Files

1. **`spec/client_spec.rb`**
   - HTTP request/response handling
   - WebSocket subscription methods
   - Error handling for network failures
   - JSON-RPC method coverage
   - Block and callback handling

2. **`spec/keypair_spec.rb`**
   - Keypair generation and initialization
   - Cryptographic operations (Ed25519)
   - File save/load operations
   - Base58 encoding/decoding
   - Error handling for invalid keys

3. **`spec/utils_spec.rb`**
   - Base58 encoding/decoding
   - Base64 encoding/decoding
   - Network endpoint constants
   - Instruction type constants
   - Edge cases and performance

4. **`spec/version_spec.rb`**
   - Version string validation
   - Semantic versioning compliance
   - Immutability checks
   - Accessibility from all components

5. **`spec/integration_spec.rb`**
   - Component interaction testing
   - End-to-end workflows
   - Error scenario handling
   - Multi-component operations

### Test Helpers

**`spec/spec_helper.rb`** provides:
- RSpec configuration
- WebMock setup for HTTP mocking
- Common test utilities
- Custom matchers
- Test data generators

## Running Tests

### Prerequisites

1. **Install Ruby** (version 3.0 or higher)
2. **Install Bundler**: `gem install bundler`
3. **Install libsodium** (required for cryptographic operations):

#### Windows (Pre-built Binary - Recommended)
```bash
# Download pre-built libsodium for Windows
Invoke-WebRequest -Uri "https://github.com/jedisct1/libsodium/releases/download/1.0.19-RELEASE/libsodium-1.0.19-msvc.zip" -OutFile "libsodium.zip"

# Extract the archive
Expand-Archive -Path "libsodium.zip" -DestinationPath "." -Force

# Copy the DLL to your project directory (or system PATH)
Copy-Item "libsodium\x64\Release\v143\dynamic\libsodium.dll" "sodium.dll" -Force
```

#### Windows (Using Package Managers)
```bash
# Using Chocolatey (if available)
choco install libsodium

# Using vcpkg
vcpkg install libsodium

# Using MSYS2
pacman -S mingw-w64-x86_64-libsodium
```

#### macOS
```bash
# Using Homebrew
brew install libsodium

# Using MacPorts
sudo port install libsodium
```

#### Linux (Ubuntu/Debian)
```bash
# Using apt
sudo apt-get update
sudo apt-get install libsodium-dev

# Using snap
sudo snap install libsodium
```

#### Linux (Red Hat/CentOS/Fedora)
```bash
# Using yum/dnf
sudo yum install libsodium-devel
# or
sudo dnf install libsodium-devel
```

#### Building from Source (All Platforms)
```bash
# Download and build libsodium from source
wget https://github.com/jedisct1/libsodium/releases/download/1.0.19-RELEASE/libsodium-1.0.19.tar.gz
tar -xzf libsodium-1.0.19.tar.gz
cd libsodium-1.0.19
./configure
make && make check
sudo make install
```

4. **Install dependencies**: `bundle install`

#### Verifying libsodium Installation

To verify that libsodium is properly installed, run:

```ruby
# Test libsodium availability
ruby -e "require 'rbnacl'; puts 'libsodium is working!'"
```

If you see "libsodium is working!" then the installation was successful.

#### Troubleshooting libsodium

**Common Issues:**

1. **"cannot load such file -- rbnacl/libsodium" (Windows)**
   - Ensure `sodium.dll` is in your project directory or system PATH
   - Try placing the DLL in `C:\Windows\System32\` (requires admin)

2. **"LoadError: Could not open library" (Linux/macOS)**
   - Run `sudo ldconfig` to refresh library cache
   - Check that libsodium is in `/usr/local/lib` or `/usr/lib`

3. **"Failed to load libsodium" (All Platforms)**
   - Verify the architecture matches (x64 vs x86)
   - Ensure you have the correct version for your platform

**Platform-Specific Notes:**
- **Windows**: The pre-built binary approach is most reliable
- **macOS**: Homebrew installation typically works best
- **Linux**: Package manager installation is recommended
- **All Platforms**: Building from source provides maximum compatibility

### Running All Tests

```bash
# Using Bundler (recommended)
bundle exec rspec

# Using RSpec directly
rspec

# Using the test runner script
ruby run_tests.rb
```

### Running Specific Test Files

```bash
# Run only client tests
bundle exec rspec spec/client_spec.rb

# Run only keypair tests
bundle exec rspec spec/keypair_spec.rb

# Run only utils tests
bundle exec rspec spec/utils_spec.rb

# Run only integration tests
bundle exec rspec spec/integration_spec.rb
```

### Running Specific Test Groups

```bash
# Run only HTTP method tests
bundle exec rspec spec/client_spec.rb -e "HTTP methods"

# Run only keypair generation tests
bundle exec rspec spec/keypair_spec.rb -e "generate"

# Run only encoding tests
bundle exec rspec spec/utils_spec.rb -e "base58_encode"
```

### Test Output Options

```bash
# Detailed output with documentation format
bundle exec rspec --format documentation

# Progress format (dots)
bundle exec rspec --format progress

# JSON output for CI/CD
bundle exec rspec --format json --out results.json

# HTML report
bundle exec rspec --format html --out test_report.html
```

## Test Coverage

### Client Class Coverage

- ✅ HTTP request methods (all 50+ RPC methods)
- ✅ WebSocket subscription methods
- ✅ Error handling and response parsing
- ✅ Block callback support
- ✅ Different network endpoints (mainnet, testnet, devnet)
- ✅ JSON-RPC protocol compliance

### Keypair Class Coverage

- ✅ Ed25519 keypair generation
- ✅ Secret key validation and error handling
- ✅ File save/load operations with JSON
- ✅ Base58 encoding/decoding
- ✅ Cryptographic signature verification
- ✅ Key consistency across save/load cycles

### Utils Module Coverage

- ✅ Base58 encoding/decoding with round-trip validation
- ✅ Base64 encoding/decoding with round-trip validation
- ✅ Network endpoint constants
- ✅ Instruction type constants
- ✅ Edge cases (empty strings, large data, Unicode)
- ✅ Performance testing

### Integration Coverage

- ✅ Client-Keypair interaction
- ✅ Utils-Keypair encoding/decoding
- ✅ Client-Utils endpoint usage
- ✅ End-to-end workflows
- ✅ Error scenario handling
- ✅ Multi-component operations

## Mocking and Stubbing

The tests use **WebMock** to mock HTTP requests, ensuring:
- No real network calls during testing
- Predictable test behavior
- Fast test execution
- Isolated test environments

### Example Mocking

```ruby
# Mock successful response
stub_request(:post, Solana::Utils::MAINNET::HTTP)
  .to_return(status: 200, body: mock_successful_response)

# Mock error response
stub_request(:post, Solana::Utils::MAINNET::HTTP)
  .to_return(status: 500, body: 'Internal Server Error')
```

## Custom Matchers

The test suite includes custom RSpec matchers:

- `be_valid_base58`: Validates Base58 strings
- `be_valid_base64`: Validates Base64 strings
- `be_valid_keypair`: Validates Solana keypairs

## Test Utilities

### Helper Methods

- `generate_test_keypair()`: Creates test keypairs
- `create_temp_file()`: Creates temporary files
- `mock_successful_response()`: Creates mock responses
- `stub_solana_request()`: Stubs RPC requests
- `test_encoding_round_trip()`: Tests encoding/decoding

### Test Data Generators

- `generate_test_account_data()`: Account information
- `generate_test_block_data()`: Block information
- `generate_test_transaction_data()`: Transaction data

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.0
      - run: bundle install
      - run: bundle exec rspec
```

### Travis CI Example

```yaml
language: ruby
rvm:
  - 3.0
  - 3.1
  - 3.2
before_install:
  - gem install bundler
install:
  - bundle install
script:
  - bundle exec rspec
```

## Test Maintenance

### Adding New Tests

1. **Unit Tests**: Add to appropriate `*_spec.rb` file
2. **Integration Tests**: Add to `integration_spec.rb`
3. **Helper Methods**: Add to `spec_helper.rb` TestHelpers module

### Test Guidelines

- Use descriptive test names
- Test both success and failure scenarios
- Mock external dependencies
- Test edge cases and error conditions
- Keep tests isolated and independent
- Use appropriate assertions and matchers

### Running Tests in Development

```bash
# Watch for changes and run tests automatically
bundle exec rspec --watch

# Run tests with coverage reporting
bundle exec rspec --format documentation --coverage

# Run tests with verbose output
bundle exec rspec --format documentation --backtrace
```

## Troubleshooting

### Common Issues

1. **Missing Dependencies**: Run `bundle install`
2. **Ruby Version**: Ensure Ruby 3.0+ is installed
3. **Network Issues**: Tests use WebMock, no real network calls
4. **Permission Issues**: Ensure write access to temp directories

### Debugging Tests

```bash
# Run with debug output
bundle exec rspec --format documentation --backtrace

# Run single test with debug
bundle exec rspec spec/client_spec.rb:25 --format documentation

# Run with pry debugging
bundle exec rspec --require pry
```

## Performance

- **Test Execution**: ~2-5 seconds for full suite
- **Memory Usage**: Minimal, tests use mocks
- **Network**: No real network calls during testing
- **Dependencies**: Lightweight, focused on testing essentials

## Future Enhancements

- [ ] Add performance benchmarks
- [ ] Add property-based testing
- [ ] Add mutation testing
- [ ] Add coverage reporting
- [ ] Add automated test generation
- [ ] Add stress testing for large data sets
