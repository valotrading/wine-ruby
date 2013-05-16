module Wine

  class Error < StandardError
  end

  class ConnectionRefused < Error
  end

  class ConnectionClosed < Error
  end

  class ResponseTimeout < Error
  end

  class ProtocolError < Error
  end

end
