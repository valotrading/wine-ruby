require 'test/unit'
require 'wine'

class MessageTest < Test::Unit::TestCase
  include Wine

  def test_login_formatting
    message  = Message::Login.new(:username => 'foo', :password => 'bar')
    expected = "Lfoo     bar                 "
    assert_equal expected, format(message)
  end

  def test_login_parsing
    message  = "Lfoo     bar                 "
    expected = Message::Login.new(:username => 'foo', :password => 'bar')
    assert_equal expected, parse(message)
  end

  def test_login_accepted_formatting
    assert_equal "A", format(Message::LoginAccepted.new)
  end

  def test_login_accepted_parsing
    assert_equal Message::LoginAccepted.new, parse("A")
  end

  def test_login_rejected_formatting
    assert_equal "J", format(Message::LoginRejected.new)
  end

  def test_login_rejected_parsing
    assert_equal Message::LoginRejected.new, parse("J")
  end

  def test_get_formatting
    message  = Message::Get.new(:key_data => 'foo')
    expected = "G\x00\x00\x00\x03foo"
    assert_equal expected, format(message)
  end

  def test_get_parsing
    message  = "G\x00\x00\x00\x03foo"
    expected = Message::Get.new(:key_data => 'foo')
    assert_equal expected, parse(message)
  end

  def test_value_formatting
    message  = Message::Value.new(:key_data => 'foo', :value_data => 'quux')
    expected = "V\x00\x00\x00\x03\x00\x00\x00\x04fooquux"
    assert_equal expected, format(message)
  end

  def test_value_parsing
    message = "V\x00\x00\x00\x03\x00\x00\x00\x04fooquux"
    expected = Message::Value.new(:key_data => 'foo', :value_data => 'quux')
    assert_equal expected, parse(message)
  end

  def test_set_formatting
    message = Message::Set.new(:key_data => 'foo', :value_data => 'quux')
    expected = "S\x00\x00\x00\x03\x00\x00\x00\x04fooquux"
    assert_equal expected, format(message)
  end

  def test_set_parsing
    message = "S\x00\x00\x00\x03\x00\x00\x00\x04fooquux"
    expected = Message::Set.new(:key_data => 'foo', :value_data => 'quux')
    assert_equal expected, parse(message)
  end

  def test_protocol_error
    assert_raise ProtocolError do
      parse("G\x00\x00\x00")
    end
  end

  def format(message)
    message.to_binary_s
  end

  def parse(str)
    Message.read(StringIO.new(str))
  end

end
