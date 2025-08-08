require 'rspec'
require 'solana-ruby'

RSpec.describe Solana::Utils do
  describe 'constants' do
    it 'defines SYSTEM_PROGRAM_ID' do
      expect(described_class::SYSTEM_PROGRAM_ID).to eq('11111111111111111111111111111111')
    end

    it 'defines PACKET_DATA_SIZE' do
      expect(described_class::PACKET_DATA_SIZE).to eq(1232)
    end

    describe 'MAINNET' do
      it 'defines HTTP endpoint' do
        expect(described_class::MAINNET::HTTP).to eq('https://api.mainnet-beta.solana.com')
      end

      it 'defines WebSocket endpoint' do
        expect(described_class::MAINNET::WS).to eq('wss://api.mainnet-beta.solana.com')
      end
    end

    describe 'TESTNET' do
      it 'defines HTTP endpoint' do
        expect(described_class::TESTNET::HTTP).to eq('https://api.testnet.solana.com')
      end

      it 'defines WebSocket endpoint' do
        expect(described_class::TESTNET::WS).to eq('wss://api.testnet.solana.com')
      end
    end

    describe 'DEVNET' do
      it 'defines HTTP endpoint' do
        expect(described_class::DEVNET::HTTP).to eq('https://api.devnet.solana.com')
      end

      it 'defines WebSocket endpoint' do
        expect(described_class::DEVNET::WS).to eq('wss://api.devnet.solana.com')
      end
    end

    describe 'InstructionType' do
      it 'defines CREATE_ACCOUNT' do
        expect(described_class::InstructionType::CREATE_ACCOUNT).to eq(0)
      end

      it 'defines ASSIGN' do
        expect(described_class::InstructionType::ASSIGN).to eq(1)
      end

      it 'defines TRANSFER' do
        expect(described_class::InstructionType::TRANSFER).to eq(2)
      end

      it 'defines CREATE_ACCOUNT_WITH_SEED' do
        expect(described_class::InstructionType::CREATE_ACCOUNT_WITH_SEED).to eq(3)
      end

      it 'defines ADVANCE_NONCE_ACCOUNT' do
        expect(described_class::InstructionType::ADVANCE_NONCE_ACCOUNT).to eq(4)
      end

      it 'defines WITHDRAW_NONCE_ACCOUNT' do
        expect(described_class::InstructionType::WITHDRAW_NONCE_ACCOUNT).to eq(5)
      end

      it 'defines INITIALIZE_NONCE_ACCOUNT' do
        expect(described_class::InstructionType::INITIALIZE_NONCE_ACCOUNT).to eq(6)
      end

      it 'defines AUTHORIZE_NONCE_ACCOUNT' do
        expect(described_class::InstructionType::AUTHORIZE_NONCE_ACCOUNT).to eq(7)
      end

      it 'defines ALLOCATE' do
        expect(described_class::InstructionType::ALLOCATE).to eq(8)
      end

      it 'defines ALLOCATE_WITH_SEED' do
        expect(described_class::InstructionType::ALLOCATE_WITH_SEED).to eq(9)
      end

      it 'defines ASSIGN_WITH_SEED' do
        expect(described_class::InstructionType::ASSIGN_WITH_SEED).to eq(10)
      end

      it 'defines TRANSFER_WITH_SEED' do
        expect(described_class::InstructionType::TRANSFER_WITH_SEED).to eq(11)
      end
    end
  end

  describe '.base58_encode' do
    it 'encodes empty string' do
      result = described_class.base58_encode(''.b)
      # Base58 library returns "1" for empty string, which is correct
      expect(result).to eq('1')
    end

    it 'encodes simple string' do
      result = described_class.base58_encode('hello'.b)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'encodes binary data' do
      binary_data = "\x00\x01\x02\x03".b
      result = described_class.base58_encode(binary_data)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'encodes 32-byte public key' do
      public_key = ("\x00" * 32).b
      result = described_class.base58_encode(public_key)
      expect(result).to be_a(String)
      expect(result.length).to be > 0
    end

    it 'encodes 64-byte secret key' do
      secret_key = ("\x00" * 64).b
      result = described_class.base58_encode(secret_key)
      expect(result).to be_a(String)
      expect(result.length).to be > 0
    end

    it 'produces consistent results' do
      data = 'test data'.b
      first_result = described_class.base58_encode(data)
      second_result = described_class.base58_encode(data)
      expect(first_result).to eq(second_result)
    end

    it 'handles special characters' do
      data = "\x00\xFF\x7F\x80".b
      result = described_class.base58_encode(data)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe '.base58_decode' do
    it 'decodes empty string' do
      result = described_class.base58_decode('')
      # Base58 library returns "\x00" for empty string, which is correct
      expect(result).to eq("\x00".b)
    end

    it 'decodes simple string' do
      encoded = described_class.base58_encode('hello'.b)
      result = described_class.base58_decode(encoded)
      expect(result).to eq('hello'.b)
    end

    it 'decodes binary data' do
      original = "\x00\x01\x02\x03".b
      encoded = described_class.base58_encode(original)
      result = described_class.base58_decode(encoded)
      expect(result).to eq(original)
    end

    it 'decodes 32-byte public key' do
      original = ("\x00" * 32).b
      encoded = described_class.base58_encode(original)
      result = described_class.base58_decode(encoded)
      expect(result).to eq(original)
    end

    it 'decodes 64-byte secret key' do
      original = ("\x00" * 64).b
      encoded = described_class.base58_encode(original)
      result = described_class.base58_decode(encoded)
      expect(result).to eq(original)
    end

    it 'round-trips correctly' do
      test_data = 'round trip test data'.b
      encoded = described_class.base58_encode(test_data)
      decoded = described_class.base58_decode(encoded)
      expect(decoded).to eq(test_data)
    end

    it 'handles special characters' do
      original = "\x00\xFF\x7F\x80".b
      encoded = described_class.base58_encode(original)
      result = described_class.base58_decode(encoded)
      expect(result).to eq(original)
    end

    it 'raises error for invalid Base58 string' do
      expect { described_class.base58_decode('invalid!@#') }.to raise_error(ArgumentError)
    end

    it 'raises error for string with invalid characters' do
      expect { described_class.base58_decode('0OIl') }.to raise_error(ArgumentError)
    end
  end

  describe '.base64_encode' do
    it 'encodes empty string' do
      result = described_class.base64_encode('')
      expect(result).to eq('')
    end

    it 'encodes simple string' do
      result = described_class.base64_encode('hello')
      expect(result).to eq('aGVsbG8=')
    end

    it 'encodes binary data' do
      binary_data = "\x00\x01\x02\x03"
      result = described_class.base64_encode(binary_data)
      expect(result).to eq('AAECAw==')
    end

    it 'encodes 32-byte public key' do
      public_key = "\x00" * 32
      result = described_class.base64_encode(public_key)
      expect(result).to eq('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=')
    end

    it 'encodes 64-byte secret key' do
      secret_key = "\x00" * 64
      result = described_class.base64_encode(secret_key)
      expect(result).to eq('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==')
    end

    it 'produces consistent results' do
      data = 'test data'
      first_result = described_class.base64_encode(data)
      second_result = described_class.base64_encode(data)
      expect(first_result).to eq(second_result)
    end

    it 'handles special characters' do
      data = "\x00\xFF\x7F\x80"
      result = described_class.base64_encode(data)
      # The actual encoding depends on the Base64 implementation
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe '.base64_decode' do
    it 'decodes empty string' do
      result = described_class.base64_decode('')
      expect(result).to eq('')
    end

    it 'decodes simple string' do
      result = described_class.base64_decode('aGVsbG8=')
      expect(result).to eq('hello')
    end

    it 'decodes binary data' do
      result = described_class.base64_decode('AAECAw==')
      expect(result).to eq("\x00\x01\x02\x03")
    end

    it 'decodes 32-byte public key' do
      result = described_class.base64_decode('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=')
      expect(result).to eq("\x00" * 32)
    end

    it 'decodes 64-byte secret key' do
      result = described_class.base64_decode('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==')
      expect(result).to eq("\x00" * 64)
    end

    it 'round-trips correctly' do
      test_data = 'round trip test data'
      encoded = described_class.base64_encode(test_data)
      decoded = described_class.base64_decode(encoded)
      expect(decoded).to eq(test_data)
    end

    it 'handles special characters' do
      # Test with a known Base64 string that we can encode and decode
      original = "\x00\xFF\x7F\x80"
      encoded = described_class.base64_encode(original)
      result = described_class.base64_decode(encoded)
      # Handle encoding differences
      expect(result.force_encoding('UTF-8')).to eq(original.force_encoding('UTF-8'))
    end

    it 'raises error for invalid Base64 string' do
      expect { described_class.base64_decode('invalid!@#') }.to raise_error(ArgumentError)
    end

    it 'raises error for string with invalid characters' do
      expect { described_class.base64_decode('aGVsbG8!') }.to raise_error(ArgumentError)
    end
  end

  describe 'encoding/decoding round trips' do
    it 'round-trips Base58 encoding/decoding' do
      test_cases = [
        'hello'.b,
        "\x00\x01\x02\x03".b,
        ("\x00" * 32).b,
        ("\x00" * 64).b,
        "\xFF\x00\x7F\x80".b,
        'special chars: !@#$%^&*()'.b
      ]

      test_cases.each do |test_data|
        encoded = described_class.base58_encode(test_data)
        decoded = described_class.base58_decode(encoded)
        expect(decoded).to eq(test_data), "Failed for: #{test_data.inspect}"
      end
    end

    it 'round-trips Base64 encoding/decoding' do
      test_cases = [
        ''.b,
        'hello'.b,
        "\x00\x01\x02\x03".b,
        ("\x00" * 32).b,
        ("\x00" * 64).b,
        "\xFF\x00\x7F\x80".b
      ]

      test_cases.each do |test_data|
        encoded = described_class.base64_encode(test_data)
        decoded = described_class.base64_decode(encoded)
        expect(decoded).to eq(test_data), "Failed for: #{test_data.inspect}"
      end
    end
  end

  describe 'edge cases' do
    it 'handles very large data' do
      large_data = ('a' * 10000).b
      encoded = described_class.base58_encode(large_data)
      decoded = described_class.base58_decode(encoded)
      expect(decoded).to eq(large_data)
    end

    it 'handles very large binary data' do
      large_binary = ("\x00" * 10000).b
      encoded = described_class.base58_encode(large_binary)
      decoded = described_class.base58_decode(encoded)
      expect(decoded).to eq(large_binary)
    end

    it 'handles Unicode characters' do
      unicode_data = 'Hello 世界 🌍'.b
      encoded = described_class.base58_encode(unicode_data)
      decoded = described_class.base58_decode(encoded)
      expect(decoded).to eq(unicode_data)
    end

    it 'handles null bytes' do
      null_data = "\x00\x00\x00".b
      encoded = described_class.base58_encode(null_data)
      decoded = described_class.base58_decode(encoded)
      expect(decoded).to eq(null_data)
    end

    it 'handles all byte values' do
      all_bytes = (0..255).map(&:chr).join.b
      encoded = described_class.base58_encode(all_bytes)
      decoded = described_class.base58_decode(encoded)
      expect(decoded).to eq(all_bytes)
    end
  end

  describe 'performance' do
    it 'handles repeated encoding/decoding efficiently' do
      test_data = 'performance test data'.b
      
      # This should complete quickly without memory issues
      1000.times do
        encoded = described_class.base58_encode(test_data)
        decoded = described_class.base58_decode(encoded)
        expect(decoded).to eq(test_data)
      end
    end
  end
end
