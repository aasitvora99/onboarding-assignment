require 'set'
require 'securerandom'
require_relative 'key'

class KeyStore
    def initialize
        @keys = {}
        @available_keys = Set.new
        @blocked_keys = {}
        @mutex = Mutex.new
    end

    def generate_key
        key = Key.new(SecureRandom.hex(16))
        @mutex.synchronize do
            @keys[key.value] = key
            @available_keys.add(key.value)
        end
        key.value
    end

    def get_available_key
        purge_expired_keys
        key_value = nil

        @mutex.synchronize do
            key_value = @available_keys.to_a.sample
            return nil unless key_value

            key = @keys[key_value]
            key.block!
            @available_keys.delete(key_value)
            @blocked_keys[key_value] = Time.now
        end
        key_value
    end

    def unblock_key(key_value)
        @mutex.synchronize do
            key = @keys[key_value]
            return false unless key && key.blocked

            key.unblock!
            @available_keys.add(key_value)
            @blocked_keys.delete(key_value)
        end
        true
    end

    def delete_key(key_value)
        @mutex.synchronize do
            return false unless @keys[key_value]

            @keys.delete(key_value)
            @available_keys.delete(key_value)
            @blocked_keys.delete(key_value)
        end
        true
    end

    def keep_alive(key_value)
        @mutex.synchronize do
            key = @keys[key_value]
            return false unless key

            key.keep_alive!
        end
        true
    end

    def purge_expired_keys
        @mutex.synchronize do
            @keys.each do |key_value, key|
                if key.keep_alive_expired?
                    @keys.delete(key_value)
                    @available_keys.delete(key_value)
                    @blocked_keys.delete(key_value)
                end
            end
        end
    end

    def exists?(key_value)
        @keys.key?(key_value)
    end
end