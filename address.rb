class Address
  attr_accessor :name, :balance
  def initialize(name, deposit)
    @name = name
    @balance = deposit.to_i
  end

  def withdraw(coins)
    @balance = @balance - coins
  end

  def deposit(coins)
    @balance = @balance + coins
  end

  def debt?
    if @balance <0
      return true
    else
      return false
    end
  end
end
