require 'wine/error'
require 'wine/message'

module Wine
  class Connection

    DEFAULT_TIMEOUT = 5000

    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    def send(message)
      message.write(@socket)
    end

    def recv(timeout = DEFAULT_TIMEOUT)
      readable = IO.select([ @socket ], nil, nil, timeout / 1000.0)
      return nil unless readable

      msg_type = @socket.recv(1, Socket::MSG_PEEK)
      raise ConnectionClosed unless msg_type.length == 1

      Message.read(@socket)
    end

    def recv_nonblock
      begin
        msg_type = @socket.recv_nonblock(1, Socket::MSG_PEEK)
        raise ConnectionClosed unless msg_type.length == 1

        Message.read(@socket)
      rescue IO::WaitReadable
        nil
      end
    end

    def close
      @socket.close
    end

  end
end
