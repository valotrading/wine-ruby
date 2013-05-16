require 'socket'
require 'wine/connection'
require 'wine/errors'
require 'wine/message'

module Wine
  class Session

    def self.connect(host, port)
      begin
        socket     = TCPSocket.new(host, port)
        connection = Connection.new(socket)

        new(connection)
      rescue Errno::ECONNREFUSED
        raise ConnectionRefused
      end
    end

    def initialize(connection)
      @connection = connection
    end

    def login(username, password, timeout = Connection::DEFAULT_TIMEOUT)
      request = Message::Login.new(:username => username, :password => password)
      @connection.send(request)

      response = @connection.recv(timeout)
      raise ResponseTimeout unless response

      case response.msg_type
      when Message::LOGIN_ACCEPTED
        true
      when Message::LOGIN_REJECTED
        false
      else
        raise ProtocolError
      end
    end

    def get(key, timeout = Connection::DEFAULT_TIMEOUT)
      request = Message::Get.new(:key_data => key)
      @connection.send(request)

      response = @connection.recv(timeout)
      raise ResponseTimeout unless response

      case response.msg_type
      when Message::VALUE
        response.value_data
      else
        raise ProtocolError
      end
    end

    def set(key, value)
      request = Message::Set.new(:key_data => key, :value_data => value)
      @connection.send(request)
    end

    def close
      @connection.close
    end

  end
end
