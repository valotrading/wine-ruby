require 'logger'
require 'socket'
require 'wine/connection'
require 'wine/error'
require 'wine/message'

module Wine
  class TestServer

    Timeout = 100.0 / 1000.0

    def self.start(args)
      usage unless args.length == 1

      port = args[0].to_i
      usage if port == 0

      log = Logger.new(STDERR)

      server = new(port, log)
      server.run
    end

    def self.usage
      abort "Usage: wine-test-server <port>"
    end

    def initialize(port, logger)
      @port = port
      @log  = logger

      @stopped = false

      @config = {}

      @server_socket = nil
      @connections   = {}

      @log.progname = "wine-test-server"
      @log.formatter = Proc.new do |severity, time, progname, msg|
        "#{progname}: #{severity.downcase}: #{msg}\n"
      end
    end

    def run
      listen

      @log.info("Listening on port #{@port}")

      until @stopped do
        readable, writable, erroneous = IO.select(sockets, [], [], Timeout)
        next unless readable

        readable.each do |socket|
          if socket == @server_socket
            accept
          else
            recv(@connections[socket])
          end
        end
      end

      sockets.each do |socket|
        socket.close
      end
    end

    def stop
      @stopped = true
    end

    private

    def listen
      @server_socket = Socket.new(:INET, :SOCK_STREAM)
      @server_socket.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, true)
      @server_socket.bind(Socket.sockaddr_in(@port, "127.0.0.1"))
      @server_socket.listen(5)
    end

    def sockets
      [ @server_socket ] + client_sockets
    end

    def client_sockets
      @connections.keys
    end

    def accept
      begin
        client_socket, client_addrinfo = @server_socket.accept_nonblock

        @connections[client_socket] = Connection.new(client_socket)
      rescue IO::WaitReadable
        # Do nothing.
      end
    end

    def recv(connection)
      begin
        message = connection.recv_nonblock
        if message
          @log.info("Received #{message}")

          handle(connection, message)
        end
      rescue ConnectionClosed
        @log.info("Connection closed")

        close(connection)
      rescue Error
        @log.warn("Closing connection")

        close(connection)
      end
    end

    def handle(connection, message)
      case message.msg_type
      when Message::LOGIN
        connection.send(Message::LoginAccepted.new)
      when Message::GET
        value = @config.fetch(message.key_data, '')
        connection.send(Message::Value.new(:key_data => message.key_data, :value_data => value))
      when Message::SET
        @config[message.key_data] = message.value_data
      end
    end

    def close(connection)
      @connections.delete(connection.socket)

      connection.close
    end

  end
end
