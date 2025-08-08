require 'rspec'
require 'webmock/rspec'
require 'tempfile'
require 'json'
require 'solana-ruby'

# Common test utilities
module TestHelpers
  # Generate a test keypair for testing
  def generate_test_keypair
    Solana::Keypair.generate
  end

  # Create a temporary file for testing
  def create_temp_file(prefix = 'test', suffix = '.json')
    Tempfile.new([prefix, suffix])
  end

  # Mock a successful JSON-RPC response
  def mock_successful_response(result_data = {})
    {
      jsonrpc: '2.0',
      id: 1,
      result: result_data
    }.to_json
  end

  # Mock an error JSON-RPC response
  def mock_error_response(code = -1, message = 'Test error')
    {
      jsonrpc: '2.0',
      id: 1,
      error: { code: code, message: message }
    }.to_json
  end

  # Stub a Solana RPC request
  def stub_solana_request(method, params = [], response_data = {})
    stub_request(:post, Solana::Utils::MAINNET::HTTP)
      .with(
        body: {
          jsonrpc: '2.0',
          method: method,
          id: 1,
          params: params
        }.to_json
      )
      .to_return(
        status: 200,
        body: mock_successful_response(response_data)
      )
  end

  # Stub a Solana RPC error
  def stub_solana_error(method, params = [], error_code = -1, error_message = 'Test error')
    stub_request(:post, Solana::Utils::MAINNET::HTTP)
      .with(
        body: {
          jsonrpc: '2.0',
          method: method,
          id: 1,
          params: params
        }.to_json
      )
      .to_return(
        status: 200,
        body: mock_error_response(error_code, error_message)
      )
  end

  # Stub a network error
  def stub_network_error(endpoint = Solana::Utils::MAINNET::HTTP)
    stub_request(:post, endpoint)
      .to_return(status: 500, body: 'Internal Server Error')
  end

  # Generate test data for different scenarios
  def generate_test_account_data(lamports = 1000000, owner = nil)
    {
      lamports: lamports,
      owner: owner || Solana::Utils::SYSTEM_PROGRAM_ID,
      executable: false,
      rentEpoch: 0
    }
  end

  def generate_test_block_data(slot = 12345)
    {
      blockhash: 'test_blockhash',
      parentSlot: slot - 1,
      transactions: [],
      rewards: [],
      blockTime: Time.now.to_i
    }
  end

  def generate_test_transaction_data(signature = 'test_signature')
    {
      signature: signature,
      slot: 12345,
      blockTime: Time.now.to_i,
      meta: {
        err: nil,
        fee: 5000,
        preBalances: [1000000],
        postBalances: [995000]
      },
      transaction: {
        message: {
          accountKeys: ['11111111111111111111111111111111'],
          instructions: [],
          recentBlockhash: 'test_blockhash'
        },
        signatures: [signature]
      }
    }
  end

  # Helper for testing encoding/decoding round trips
  def test_encoding_round_trip(data, encoder_method, decoder_method)
    encoded = Solana::Utils.send(encoder_method, data)
    decoded = Solana::Utils.send(decoder_method, encoded)
    expect(decoded).to eq(data)
  end

  # Helper for testing keypair operations
  def test_keypair_operations
    keypair = generate_test_keypair
    
    # Test basic properties
    expect(keypair.public_key).to be_a(String)
    expect(keypair.secret_key).to be_a(String)
    expect(keypair.public_key.bytesize).to eq(32)
    expect(keypair.secret_key.bytesize).to eq(64)
    
    # Test encoding
    expect(keypair.public_key_base58).to be_a(String)
    expect(keypair.secret_key_base58).to be_a(String)
    
    keypair
  end

  # Helper for testing file operations
  def test_file_operations(keypair)
    temp_file = create_temp_file
    
    begin
      # Test save
      keypair.save_to_json(temp_file.path)
      expect(File.exist?(temp_file.path)).to be true
      
      # Test load
      loaded_keypair = Solana::Keypair.load_from_json(temp_file.path)
      expect(loaded_keypair.public_key).to eq(keypair.public_key)
      expect(loaded_keypair.secret_key).to eq(keypair.secret_key)
      
      loaded_keypair
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  # Helper for testing client operations
  def test_client_operations(client, pubkey)
    # Test basic account info
    stub_solana_request('getAccountInfo', [pubkey, {}], { value: generate_test_account_data })
    result = client.get_account_info(pubkey)
    expect(result['result']['value']['lamports']).to eq(1000000)
    
    # Test balance
    stub_solana_request('getBalance', [pubkey, {}], { value: 1000000 })
    result = client.get_balance(pubkey)
    expect(result['result']['value']).to eq(1000000)
    
    # Test airdrop
    stub_solana_request('requestAirdrop', [pubkey, 1000000, {}], { value: 'test_signature' })
    result = client.request_airdrop(pubkey, 1000000)
    expect(result['result']['value']).to eq('test_signature')
  end

  # Helper for testing error scenarios
  def test_error_scenarios
    # Test invalid secret key
    expect { Solana::Keypair.new('invalid') }.to raise_error('Bad secret key size')
    
    # Test invalid encoding
    expect { Solana::Utils.base58_decode('invalid!@#') }.to raise_error(ArgumentError)
    
    # Test network error
    stub_network_error
    expect { Solana::Client.new.get_account_info('test') }.to raise_error(RuntimeError, 'Request failed')
  end
end

# Configure RSpec
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Enable the new expectation syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure WebMock
  config.before(:each) do
    # Disable real HTTP requests by default
    WebMock.disable_net_connect!
  end

  config.after(:each) do
    # Re-enable real HTTP requests after each test
    WebMock.allow_net_connect!
  end

  # Include common test utilities
  config.include TestHelpers
end

# Custom matchers for common assertions
RSpec::Matchers.define :be_valid_base58 do
  match do |actual|
    begin
      Solana::Utils.base58_decode(actual)
      true
    rescue ArgumentError
      false
    end
  end

  failure_message do |actual|
    "expected #{actual} to be a valid Base58 string"
  end
end

RSpec::Matchers.define :be_valid_base64 do
  match do |actual|
    begin
      Solana::Utils.base64_decode(actual)
      true
    rescue ArgumentError
      false
    end
  end

  failure_message do |actual|
    "expected #{actual} to be a valid Base64 string"
  end
end

RSpec::Matchers.define :be_valid_keypair do
  match do |actual|
    actual.is_a?(Solana::Keypair) &&
    actual.public_key.bytesize == 32 &&
    actual.secret_key.bytesize == 64
  end

  failure_message do |actual|
    "expected #{actual} to be a valid Solana::Keypair"
  end
end

# Load all spec files
Dir[File.expand_path('../spec/**/*_spec.rb', __FILE__)].sort.each { |f| require f }

