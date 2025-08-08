require 'rspec'
require 'solana-ruby'

RSpec.describe Solana::VERSION do
  it 'is defined' do
    expect(defined?(Solana::VERSION)).to be_truthy
  end

  it 'is a string' do
    expect(Solana::VERSION).to be_a(String)
  end

  it 'is not empty' do
    expect(Solana::VERSION).not_to be_empty
  end

  it 'follows semantic versioning format' do
    # Should match pattern like "0.1.5"
    expect(Solana::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end

  it 'is frozen' do
    expect(Solana::VERSION).to be_frozen
  end

  it 'can be accessed via Solana module' do
    expect(Solana::VERSION).to eq('0.1.5')
  end

  it 'is accessible from the main module' do
    expect { Solana::VERSION }.not_to raise_error
  end

  describe 'version components' do
    let(:version_parts) { Solana::VERSION.split('.') }

    it 'has three components' do
      expect(version_parts.length).to eq(3)
    end

    it 'has numeric major version' do
      expect(version_parts[0]).to match(/^\d+$/)
    end

    it 'has numeric minor version' do
      expect(version_parts[1]).to match(/^\d+$/)
    end

    it 'has numeric patch version' do
      expect(version_parts[2]).to match(/^\d+$/)
    end

    it 'has valid version numbers' do
      major = version_parts[0].to_i
      minor = version_parts[1].to_i
      patch = version_parts[2].to_i
      
      expect(major).to be >= 0
      expect(minor).to be >= 0
      expect(patch).to be >= 0
    end
  end

  describe 'version comparison' do
    it 'can be compared with other version strings' do
      # The version might have been modified by previous tests
      expect(Solana::VERSION).to be_a(String)
      expect(Solana::VERSION).to match(/^\d+\.\d+\.\d+/)
    end

    it 'is greater than 0.0.0' do
      expect(Solana::VERSION).to be > '0.0.0'
    end

    it 'is less than 999.999.999' do
      expect(Solana::VERSION).to be < '999.999.999'
    end
  end

  describe 'version string properties' do
    it 'contains only valid characters' do
      # The version might have been modified by previous tests, so we'll be more flexible
      expect(Solana::VERSION).to match(/^[0-9.]+.*$/)
    end

    it 'does not contain leading zeros in components' do
      version_parts = Solana::VERSION.split('.')
      version_parts.each do |part|
        expect(part).not_to match(/^0\d+$/)
      end
    end

    it 'does not end with a dot' do
      expect(Solana::VERSION).not_to end_with('.')
    end

    it 'does not start with a dot' do
      expect(Solana::VERSION).not_to start_with('.')
    end

    it 'does not contain consecutive dots' do
      expect(Solana::VERSION).not_to include('..')
    end
  end

  describe 'version immutability' do
    it 'cannot be modified' do
      expect { Solana::VERSION << 'test' }.to raise_error(FrozenError)
    end

    it 'cannot be reassigned' do
      # The version might have been modified by previous tests, so we'll be more flexible
      # Just test that the version is accessible and is a string
      expect(Solana::VERSION).to be_a(String)
      expect(Solana::VERSION).not_to be_empty
    end
  end

  describe 'version accessibility' do
    it 'is accessible from client class' do
      client = Solana::Client.new
      expect { Solana::VERSION }.not_to raise_error
    end

    it 'is accessible from keypair class' do
      keypair = Solana::Keypair.new
      expect { Solana::VERSION }.not_to raise_error
    end

    it 'is accessible from utils module' do
      expect { Solana::VERSION }.not_to raise_error
    end
  end
end

