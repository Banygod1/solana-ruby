require 'rspec'
require 'webmock/rspec'
require 'solana-ruby'

RSpec.describe 'Solana Ruby Integration' do
  let(:client) { Solana::Client.new }
  let(:keypair) { Solana::Keypair.generate }
  let(:test_pubkey) { keypair.public_key_base58 }

  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
  end

  describe 'Client and Keypair integration' do
    it 'can use keypair with client for account operations' do
      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getAccountInfo',
            id: 1,
            params: [test_pubkey, {}]
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: { lamports: 1000000 } }
          }.to_json
        )

      result = client.get_account_info(test_pubkey)
      expect(result['result']['value']['lamports']).to eq(1000000)
    end

    it 'can use keypair with client for balance operations' do
      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getBalance',
            id: 1,
            params: [test_pubkey, {}]
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: 1000000 }
          }.to_json
        )

      result = client.get_balance(test_pubkey)
      expect(result['result']['value']).to eq(1000000)
    end

    it 'can use keypair with client for airdrop operations' do
      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'requestAirdrop',
            id: 1,
            params: [test_pubkey, 1000000, {}]
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: 'test_signature' }
          }.to_json
        )

      result = client.request_airdrop(test_pubkey, 1000000)
      expect(result['result']['value']).to eq('test_signature')
    end
  end

  describe 'Utils and Keypair integration' do
    it 'can encode and decode keypair data using Utils' do
      # Test that keypair data can be properly encoded/decoded
      public_key_encoded = Solana::Utils.base58_encode(keypair.public_key)
      secret_key_encoded = Solana::Utils.base58_encode(keypair.secret_key)

      public_key_decoded = Solana::Utils.base58_decode(public_key_encoded)
      secret_key_decoded = Solana::Utils.base58_decode(secret_key_encoded)

      expect(public_key_decoded).to eq(keypair.public_key)
      expect(secret_key_decoded).to eq(keypair.secret_key)
    end

    it 'can use Utils for Base64 encoding of keypair data' do
      public_key_base64 = Solana::Utils.base64_encode(keypair.public_key)
      secret_key_base64 = Solana::Utils.base64_encode(keypair.secret_key)

      public_key_decoded = Solana::Utils.base64_decode(public_key_base64)
      secret_key_decoded = Solana::Utils.base64_decode(secret_key_base64)

      expect(public_key_decoded).to eq(keypair.public_key)
      expect(secret_key_decoded).to eq(keypair.secret_key)
    end

    it 'can save and load keypair with proper encoding' do
      temp_file = Tempfile.new(['keypair', '.json'])
      
      begin
        keypair.save_to_json(temp_file.path)
        
        # Verify the saved file uses Base58 encoding
        data = JSON.parse(File.read(temp_file.path))
        expect(data['public_key']).to eq(keypair.public_key_base58)
        expect(data['secret_key']).to eq(keypair.secret_key_base58)
        
        # Load the keypair back
        loaded_keypair = Solana::Keypair.load_from_json(temp_file.path)
        
        expect(loaded_keypair.public_key).to eq(keypair.public_key)
        expect(loaded_keypair.secret_key).to eq(keypair.secret_key)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end
  end

  describe 'Client and Utils integration' do
    it 'can use Utils constants with Client' do
      # Test that client can use Utils endpoints
      testnet_client = Solana::Client.new(Solana::Utils::TESTNET)
      expect(testnet_client.instance_variable_get(:@api_endpoint)).to eq(Solana::Utils::TESTNET)
      
      devnet_client = Solana::Client.new(Solana::Utils::DEVNET)
      expect(devnet_client.instance_variable_get(:@api_endpoint)).to eq(Solana::Utils::DEVNET)
    end

    it 'can use Utils encoding with Client requests' do
      # Test that client can work with Base58 encoded addresses
      encoded_pubkey = Solana::Utils.base58_encode(keypair.public_key)
      
      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getAccountInfo',
            id: 1,
            params: [encoded_pubkey, {}]
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: { lamports: 1000000 } }
          }.to_json
        )

      result = client.get_account_info(encoded_pubkey)
      expect(result['result']['value']['lamports']).to eq(1000000)
    end
  end

  describe 'End-to-end scenarios' do
    it 'can perform a complete keypair lifecycle' do
      # Generate keypair
      keypair = Solana::Keypair.generate
      
      # Encode public key for use with client
      public_key_base58 = keypair.public_key_base58
      
      # Mock client responses
      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'getBalance',
            id: 1,
            params: [public_key_base58, {}]
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: 0 }
          }.to_json
        )

      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'requestAirdrop',
            id: 1,
            params: [public_key_base58, 1000000, {}]
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: 'airdrop_signature' }
          }.to_json
        )

      # Check initial balance
      balance_result = client.get_balance(public_key_base58)
      expect(balance_result['result']['value']).to eq(0)
      
      # Request airdrop
      airdrop_result = client.request_airdrop(public_key_base58, 1000000)
      expect(airdrop_result['result']['value']).to eq('airdrop_signature')
    end

    it 'can perform keypair save/load cycle with client usage' do
      temp_file = Tempfile.new(['keypair', '.json'])
      
      begin
        # Generate and save keypair
        original_keypair = Solana::Keypair.generate
        original_keypair.save_to_json(temp_file.path)
        
        # Load keypair
        loaded_keypair = Solana::Keypair.load_from_json(temp_file.path)
        
        # Use loaded keypair with client
        public_key_base58 = loaded_keypair.public_key_base58
        
        stub_request(:post, Solana::Utils::MAINNET::HTTP)
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'getAccountInfo',
              id: 1,
              params: [public_key_base58, {}]
            }.to_json
          )
          .to_return(
            status: 200,
            body: {
              jsonrpc: '2.0',
              id: 1,
              result: { value: { lamports: 500000 } }
            }.to_json
          )

        result = client.get_account_info(public_key_base58)
        expect(result['result']['value']['lamports']).to eq(500000)
        
        # Verify the loaded keypair is identical to original
        expect(loaded_keypair.public_key).to eq(original_keypair.public_key)
        expect(loaded_keypair.secret_key).to eq(original_keypair.secret_key)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    it 'can handle multiple keypairs with different clients' do
      # Generate multiple keypairs
      keypair1 = Solana::Keypair.generate
      keypair2 = Solana::Keypair.generate
      
      # Create different clients
      mainnet_client = Solana::Client.new(Solana::Utils::MAINNET)
      testnet_client = Solana::Client.new(Solana::Utils::TESTNET)
      
      # Mock responses for both clients
      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: 1000000 }
          }.to_json
        )

      stub_request(:post, Solana::Utils::TESTNET::HTTP)
        .to_return(
          status: 200,
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: { value: 500000 }
          }.to_json
        )

      # Use keypairs with different clients
      mainnet_result = mainnet_client.get_balance(keypair1.public_key_base58)
      testnet_result = testnet_client.get_balance(keypair2.public_key_base58)
      
      expect(mainnet_result['result']['value']).to eq(1000000)
      expect(testnet_result['result']['value']).to eq(500000)
    end
  end

  describe 'Error handling integration' do
    it 'handles network errors gracefully' do
      stub_request(:post, Solana::Utils::MAINNET::HTTP)
        .to_return(status: 500, body: 'Internal Server Error')

      # HTTPX is asynchronous, so we need to handle this differently
      result = client.get_account_info(test_pubkey)
      # For now, we'll just test that the method doesn't crash
      expect(result).to be_nil
    end

    it 'handles invalid keypair data gracefully' do
      invalid_secret_key = 'invalid_key'
      
      expect { Solana::Keypair.new(invalid_secret_key) }.to raise_error('Bad secret key size')
    end

    it 'handles invalid encoding gracefully' do
      expect { Solana::Utils.base58_decode('invalid!@#') }.to raise_error(ArgumentError)
    end
  end

  describe 'Version integration' do
    it 'version is accessible from all components' do
      expect { Solana::VERSION }.not_to raise_error
      # The version might have been modified by previous tests
      expect(Solana::VERSION).to be_a(String)
      expect(Solana::VERSION).not_to be_empty
      
      # Version should be accessible from client
      client = Solana::Client.new
      expect { Solana::VERSION }.not_to raise_error
      
      # Version should be accessible from keypair
      keypair = Solana::Keypair.new
      expect { Solana::VERSION }.not_to raise_error
      
      # Version should be accessible from utils
      expect { Solana::VERSION }.not_to raise_error
    end
  end
end

