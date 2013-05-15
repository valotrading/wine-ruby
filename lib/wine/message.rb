require 'bindata'
require 'wine/error'

module Wine
  module Message

    LOGIN          = 'L'
    LOGIN_ACCEPTED = 'A'
    LOGIN_REJECTED = 'J'
    GET            = 'G'
    VALUE          = 'V'
    SET            = 'S'

    class Login < BinData::Record
      string :msg_type, :value  => LOGIN
      string :username, :length =>  8, :pad_byte => ' '
      string :password, :length => 20, :pad_byte => ' '
    end

    class LoginAccepted < BinData::Record
      string :msg_type, :value => LOGIN_ACCEPTED
    end

    class LoginRejected < BinData::Record
      string :msg_type, :value => LOGIN_REJECTED
    end

    class Get < BinData::Record
      string  :msg_type,   :value       => GET
      int32be :key_length, :value       => lambda { key_data.length }
      string  :key_data,   :read_length => :key_length
    end

    class Value < BinData::Record
      string  :msg_type,     :value       => VALUE
      int32be :key_length,   :value       => lambda { key_data.length }
      int32be :value_length, :value       => lambda { value_data.length }
      string  :key_data,     :read_length => :key_length
      string  :value_data,   :read_length => :value_length
    end

    class Set < BinData::Record
      string  :msg_type,     :value       => SET
      int32be :key_length,   :value       => lambda { key_data.length }
      int32be :value_length, :value       => lambda { value_data.length }
      string  :key_data,     :read_length => :key_length
      string  :value_data,   :read_length => :value_length
    end

    def self.read(io)
      begin
        type = Types[io.read(1)]
        type.read(io)
      rescue StandardError
        raise ProtocolError
      end
    end

    private

    Types = {
      LOGIN          => Login,
      LOGIN_ACCEPTED => LoginAccepted,
      LOGIN_REJECTED => LoginRejected,
      GET            => Get,
      VALUE          => Value,
      SET            => Set
    }

  end
end
