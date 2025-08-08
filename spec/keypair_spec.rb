require 'rspec'
require 'tempfile'
require 'solana-ruby'

RSpec.describe Solana::Keypair do
  let(:temp_file) { Tempfile.new(['keypair', '.json']) }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe '#initialize' do
    it 'generates a new keypair when no secret key is provided' do
      keypair = described_class.new
      
      expect(keypair.public_key).to be_a(String)
      expect(keypair.secret_key).to be_a(String)
      expect(keypair.public_key.bytesize).to eq(32)
      expect(keypair.secret_key.bytesize).to eq(64)
    end

    it 'creates keypair from provided secret key' do
      # Generate a valid 64-byte secret key
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.generate
      secret_key = signing_key.to_bytes + signing_key.verify_key.to_bytes
      
      keypair = described_class.new(secret_key)
      
      expect(keypair.public_key).to eq(signing_key.verify_key.to_bytes)
      expect(keypair.secret_key).to eq(secret_key)
    end

    it 'raises error for invalid secret key size' do
      invalid_secret_key = 'invalid_key'
      
      expect { described_class.new(invalid_secret_key) }.to raise_error('Bad secret key size')
    end
  end

  describe '.generate' do
    it 'generates a new keypair' do
      keypair = described_class.generate
      
      expect(keypair).to be_a(described_class)
      expect(keypair.public_key).to be_a(String)
      expect(keypair.secret_key).to be_a(String)
    end

    it 'generates unique keypairs' do
      keypair1 = described_class.generate
      keypair2 = described_class.generate
      
      expect(keypair1.public_key).not_to eq(keypair2.public_key)
      expect(keypair1.secret_key).not_to eq(keypair2.secret_key)
    end
  end

  describe '.from_secret_key' do
    it 'creates keypair from secret key' do
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.generate
      secret_key = signing_key.to_bytes + signing_key.verify_key.to_bytes
      
      keypair = described_class.from_secret_key(secret_key)
      
      expect(keypair).to be_a(described_class)
      expect(keypair.public_key).to eq(signing_key.verify_key.to_bytes)
      expect(keypair.secret_key).to eq(secret_key)
    end

    it 'raises error for invalid secret key size' do
      expect { described_class.from_secret_key('invalid') }.to raise_error('Bad secret key size')
    end
  end

  describe '#save_to_json' do
    it 'saves keypair to JSON file' do
      keypair = described_class.generate
      keypair.save_to_json(temp_file.path)
      
      expect(File.exist?(temp_file.path)).to be true
      
      data = JSON.parse(File.read(temp_file.path))
      expect(data).to have_key('public_key')
      expect(data).to have_key('secret_key')
      expect(data['public_key']).to eq(keypair.public_key_base58)
      expect(data['secret_key']).to eq(keypair.secret_key_base58)
    end

    it 'saves keys in Base58 format' do
      keypair = described_class.generate
      keypair.save_to_json(temp_file.path)
      
      data = JSON.parse(File.read(temp_file.path))
      
      # Verify the saved keys are valid Base58
      expect { Solana::Utils.base58_decode(data['public_key']) }.not_to raise_error
      expect { Solana::Utils.base58_decode(data['secret_key']) }.not_to raise_error
    end
  end

  describe '.load_from_json' do
    it 'loads keypair from JSON file' do
      original_keypair = described_class.generate
      original_keypair.save_to_json(temp_file.path)
      
      loaded_keypair = described_class.load_from_json(temp_file.path)
      
      expect(loaded_keypair).to be_a(described_class)
      expect(loaded_keypair.public_key).to eq(original_keypair.public_key)
      expect(loaded_keypair.secret_key).to eq(original_keypair.secret_key)
    end

    it 'raises error for invalid secret key size in file' do
      # Create invalid JSON file with properly encoded binary data
      invalid_data = {
        public_key: Solana::Utils.base58_encode('test'.b),
        secret_key: Solana::Utils.base58_encode('invalid_size'.b)
      }
      File.write(temp_file.path, invalid_data.to_json)
      
      expect { described_class.load_from_json(temp_file.path) }.to raise_error('Bad secret key size')
    end

    it 'raises error when derived public key does not match saved public key' do
      # Create keypair with mismatched keys
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.generate
      secret_key = signing_key.to_bytes + signing_key.verify_key.to_bytes
      wrong_public_key = RbNaCl::Signatures::Ed25519::SigningKey.generate.verify_key.to_bytes
      
      invalid_data = {
        public_key: Solana::Utils.base58_encode(wrong_public_key),
        secret_key: Solana::Utils.base58_encode(secret_key)
      }
      File.write(temp_file.path, invalid_data.to_json)
      
      expect { described_class.load_from_json(temp_file.path) }.to raise_error('Provided secretKey is invalid')
    end

    it 'raises error for non-existent file' do
      expect { described_class.load_from_json('non_existent_file.json') }.to raise_error(Errno::ENOENT)
    end

    it 'raises error for invalid JSON file' do
      File.write(temp_file.path, 'invalid json')
      
      expect { described_class.load_from_json(temp_file.path) }.to raise_error(JSON::ParserError)
    end
  end

  describe '#public_key_base58' do
    it 'returns public key in Base58 format' do
      keypair = described_class.generate
      base58_public_key = keypair.public_key_base58
      
      expect(base58_public_key).to be_a(String)
      expect(base58_public_key).to eq(Solana::Utils.base58_encode(keypair.public_key))
    end

    it 'returns consistent Base58 encoding' do
      keypair = described_class.generate
      first_call = keypair.public_key_base58
      second_call = keypair.public_key_base58
      
      expect(first_call).to eq(second_call)
    end
  end

  describe '#secret_key_base58' do
    it 'returns secret key in Base58 format' do
      keypair = described_class.generate
      base58_secret_key = keypair.secret_key_base58
      
      expect(base58_secret_key).to be_a(String)
      expect(base58_secret_key).to eq(Solana::Utils.base58_encode(keypair.secret_key))
    end

    it 'returns consistent Base58 encoding' do
      keypair = described_class.generate
      first_call = keypair.secret_key_base58
      second_call = keypair.secret_key_base58
      
      expect(first_call).to eq(second_call)
    end
  end

  describe 'cryptographic properties' do
    it 'generates valid Ed25519 keypairs' do
      keypair = described_class.generate
      
      # Verify the keypair can be used for signing
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(keypair.secret_key[0, 32])
      verify_key = RbNaCl::Signatures::Ed25519::VerifyKey.new(keypair.public_key)
      
      message = 'test message'
      signature = signing_key.sign(message)
      
      expect { verify_key.verify(signature, message) }.not_to raise_error
    end

    it 'maintains key consistency after save/load cycle' do
      original_keypair = described_class.generate
      original_keypair.save_to_json(temp_file.path)
      
      loaded_keypair = described_class.load_from_json(temp_file.path)
      
      # Verify the loaded keypair can sign and verify
      signing_key = RbNaCl::Signatures::Ed25519::SigningKey.new(loaded_keypair.secret_key[0, 32])
      verify_key = RbNaCl::Signatures::Ed25519::VerifyKey.new(loaded_keypair.public_key)
      
      message = 'test message'
      signature = signing_key.sign(message)
      
      expect { verify_key.verify(signature, message) }.not_to raise_error
    end
  end

  describe 'edge cases' do
    it 'handles empty file path' do
      keypair = described_class.generate
      
      expect { keypair.save_to_json('') }.to raise_error(Errno::ENOENT)
    end

    it 'handles directory as file path' do
      keypair = described_class.generate
      dir_path = Dir.mktmpdir
      
      expect { keypair.save_to_json(dir_path) }.to raise_error(Errno::EISDIR)
      
      Dir.rmdir(dir_path)
    end

    it 'handles very large secret keys' do
      large_secret_key = 'a' * 128 # 128 bytes instead of 64
      
      expect { described_class.new(large_secret_key) }.to raise_error('Bad secret key size')
    end

    it 'handles very small secret keys' do
      small_secret_key = 'a' * 32 # 32 bytes instead of 64
      
      expect { described_class.new(small_secret_key) }.to raise_error('Bad secret key size')
    end
  end
end
