class Key
    attr_accessor :value, :blocked, :expiry_time, :last_keep_alive_time

    def initialize(value)
        @value = value
        @blocked = false
        @expiry_time = Time.now + 300 
        @last_keep_alive_time = Time.now
    end

    def expired?
        Time.now > @expiry_time
    end

    def block!
        @blocked = true
        @blocked_time = Time.now
    end

    def unblock!
        @blocked = false
        @blocked_time = nil
        @expiry_time = Time.now + 300
    end

    def keep_alive!
        @last_keep_alive_time = Time.now
        @expiry_time = Time.now + 300
    end
end