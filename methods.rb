require_relative "address"

class Methods
  def self.hash(lineString)
    values = lineString.unpack('U*')
    result = 0
    values.each do |x|
      result +=  (x ** 2000) * ((x + 2) ** 21) - ((x + 5) ** 3)
    end
    return (result%65536).to_s(16)
  end

  def self.parse_line(line)
    return line.split("|")
  end

  def self.parse_transaction_line(transaction_line)
    return transaction_line.split(":")
  end

  def self.parse_transaction(transaction)
    users = transaction.split(">")
    second_user = users[1].split("(")[0]
    transaction_amount = users[1].split("(")[1].split(")")[0]
    return users[0],second_user,transaction_amount.to_i
  end

  def self.compute_block_transaction(transaction_line, addresses)
      parse_transaction_line(transaction_line).each do |transaction|
        compute_transaction(parse_transaction(transaction), addresses)
      end
      invalid = invalid_balances?(addresses)
      if(invalid[0])
        return false, invalid[1]
      end
      return true, nil
  end

  def self.find_address(name, addresses)
    if name.length > 6
      raise ArgumentError.new("Invalid Address")
    end
    addresses.each do |address|
      if address.name == name
        return address
      end
    end
    newAddress = Address::new(name, 0)
    addresses << newAddress
    return newAddress
  end

  def self.invalid_balances?(addresses)
    addresses.each do |address|
      if address.debt?
        return true, address
      end
    end
    return false, nil
  end

  def self.compute_transaction(transaction_array, addresses)
    from = transaction_array[0]
    to = transaction_array[1]
    amount = transaction_array[2]
    from_address = nil
    to_address = nil
    if from == "SYSTEM"
      to_address = find_address(to, addresses)
      to_address.deposit(amount)
    else
      to_address = find_address(to, addresses)
      from_address = find_address(from, addresses)
      from_address.withdraw(amount)
      to_address.deposit(amount)
    end
  end
end
