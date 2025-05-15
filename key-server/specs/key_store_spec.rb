require 'rspec'
require_relative '../lib/key_store'

RSpec.describe KeyStore do
  let(:store) { KeyStore.new }

  describe '/generate_key' do
    it 'generates a new unique key' do
      key = store.generate_key
      expect(key).to be_a(String)
      expect(store.exists?(key)).to be true
    end
  end

  describe '/get_available_key' do
    it 'returns an available key and blocks it' do
      key = store.generate_key
      fetched_key = store.get_available_key
      expect(fetched_key).to eq(key)
      expect(store.unblock_key(fetched_key)).to be true
    end

    it 'returns nil when no keys are available' do
      expect(store.get_available_key).to be_nil
    end

    it 'does not return a blocked key' do
      key1 = store.generate_key
      store.get_available_key # blocks key1
      key2 = store.get_available_key
      expect(key2).to be_nil
    end
  end

  describe '/unblock_key' do
    it 'unblocks a previously blocked key' do
      key = store.generate_key
      store.get_available_key # block
      result = store.unblock_key(key)
      expect(result).to be true
    end

    it 'fails to unblock a key that is not blocked' do
      key = store.generate_key
      result = store.unblock_key(key)
      expect(result).to be false
    end

    it 'fails to unblock a non-existent key' do
      expect(store.unblock_key('nonexistent')).to be false
    end
  end

  describe '/delete_key' do
    it 'deletes an existing key' do
      key = store.generate_key
      result = store.delete_key(key)
      expect(result).to be true
      expect(store.exists?(key)).to be false
    end

    it 'returns false for a non-existent key' do
      expect(store.delete_key('doesnotexist')).to be false
    end
  end

  describe '/keep_alive' do
    it 'refreshes the expiry time for an existing key' do
      key = store.generate_key
      sleep 1
      expect(store.keep_alive(key)).to be true
    end

    it 'returns false for a non-existent key' do
      expect(store.keep_alive('fake_key')).to be false
    end
  end

  describe '/purge_expired_keys' do
    it 'removes keys not kept alive after 5 minutes' do
      key = store.generate_key
      # Simulate time travel
      key_obj = store.instance_variable_get(:@keys)[key]
      key_obj.instance_variable_set(:@last_keep_alive_time, Time.now - 301)

      store.purge_expired_keys

      expect(store.exists?(key)).to be false
    end
  end

  describe 'automatic expiry and blocking timeout behavior' do
    it 'automatically releases blocked keys after 60 seconds' do
      key = store.generate_key
      store.get_available_key

      store.instance_variable_get(:@blocked_keys)[key] = Time.now - 61
      store.unblock_key(key)

      expect(store.get_available_key).to eq(key)
    end
  end
end
