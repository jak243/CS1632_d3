require_relative 'methods'
require_relative 'address'
require 'minitest/autorun'


class VerifierTest < Minitest::Test
  def setup
    @ad1 = Address::new("1", 10)
    @ad2 = Address::new("2", 10)
    @ad3 = Address::new("3", 10)
    @addresses = [@ad1,@ad2,@ad3]
  end

  def test_hash
    testString ="0|0|SYSTEM>Henry(100)|1518892051.737141000"
    assert_equal Methods.hash(testString), "1c12"
  end

  def test_parse_line
    testString ="0|0|SYSTEM>Henry(100)|1518892051.737141000|1c12"
    assert_equal Methods.parse_line(testString),["0","0","SYSTEM>Henry(100)","1518892051.737141000","1c12"]
  end

  def test_parse_transaction_line
    testString = "Kublai>Pakal(1):Peter>Sheba(1):SYSTEM>Amina(100)"
    assert_equal Methods.parse_transaction_line(testString), ["Kublai>Pakal(1)","Peter>Sheba(1)","SYSTEM>Amina(100)"]
  end

  def test_parse_transaction
    testString = "Kublai>Pakal(1)"
    assert_equal Methods.parse_transaction(testString), ["Kublai","Pakal",1]
  end

  def test_compute_block_transaction_valid
    transaction_string = "2>3(11):1>2(1):SYSTEM>1(100)"
    assert Methods.compute_block_transaction(transaction_string, @addresses)[0]
    assert_equal @ad1.balance, 109
    assert_equal @ad2.balance, 0
    assert_equal @ad3.balance, 21
  end

  def test_compute_block_transaction_valid_new_user
    transaction_string = "SYSTEM>4(100)"
    assert Methods.compute_block_transaction(transaction_string, @addresses)[0]
    assert_equal @addresses[3].balance, 100
  end

  def test_compute_block_transaction_invalid
    transaction_string = "2>3(11)"
    result = Methods.compute_block_transaction(transaction_string, @addresses)
    assert !result[0]
    assert_equal result[1],@ad2
  end

  def test_find_address_new_address
    name = "4"
    a4 = Methods.find_address(name, @addresses)
    assert_equal "4", a4.name
    assert_equal 0, a4.balance
    assert_equal a4, @addresses[3]
  end

  def test_find_address_existing_address
    name = "3"
    a4 = Methods.find_address(name, @addresses)
    assert_equal "3", a4.name
    assert_equal 10, a4.balance
    assert_equal a4, @addresses[2]
  end

  def test_invalid_balances_true
    a4 = Minitest::Mock.new("mock address4")
    a5 = Minitest::Mock.new("mock address5")
    def a4.debt?
      true
    end
    def a5.debt?
      false
    end
    assert Methods.invalid_balances?([a4,a5])
  end

  def test_invalid_balances_false
    a4 = Minitest::Mock.new("mock address4")
    a5 = Minitest::Mock.new("mock address5")
    def a4.debt?
      true
    end
    def a5.debt?
      true
    end
    assert Methods.invalid_balances?([a4,a5])
  end

  def test_compute_transaction_valid
    transaction_array = ["1","2",1]
    Methods.compute_transaction(transaction_array, @addresses)
    assert_equal 9, @ad1.balance
    assert_equal 11, @ad2.balance
    assert_equal 10, @ad3.balance
  end

end
