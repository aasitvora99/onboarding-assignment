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
                if key.expired?
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

    def release_stale_blocked_keys
        @mutex.synchronize do
            now = Time.now
            @blocked_keys.each do |key_value, blocked_at|
                if now - blocked_at > 60
                    key = @keys[key_value]
                    next unless key
                    key.unblock!
                    @available_keys.add(key_value)
                end
            end
            @blocked_keys.delete_if { |_, blocked_at| now - blocked_at > 60 }
        end
    end
end