require_relative "methods"
require 'flamegraph'

if ARGV.size != 1
  abort "You must provide a file to verify."
end

Flamegraph.generate("#{ARGV[0].split(".")[0]}_flame.html") do

  begin
    addresses = Array::new
    filename = ARGV[0]
    file = File.open(filename, "r")
    block_number_check = 0
    prev_found_hash = "0";
    prev_time = "0.0"

    file.each_line do |line|
      split_line = Methods.parse_line(line.chop)
      if split_line.length != 5
        abort "Line #{block_number_check}: Line string #{line} is in an invalid format\n BLOCKCHAIN INVALID"
      end
      block_number,previous_hash,transaction_string,timestamp_string,current_hash =split_line
      if block_number.to_i != block_number_check
        abort "Line #{block_number_check}: Invalid block number #{block_number}, should be #{block_number_check}\n BLOCKCHAIN INVALID"
      end
      prev_secs = prev_time.split(".")[0].to_i
      prev_nano = prev_time.split(".")[1].to_i
      cur_secs = timestamp_string.split(".")[0].to_i
      cur_nano = timestamp_string.split(".")[1].to_i
      if prev_secs > cur_secs
        abort "Line #{block_number_check}: Previous timestamp #{prev_time} >= new timestamp #{timestamp_string}\n BLOCKCHAIN INVALID"
      elsif prev_secs == cur_secs && prev_nano >= cur_nano
        abort "Line #{block_number_check}: Previous timestamp #{prev_time} >= new timestamp #{timestamp_string}\n BLOCKCHAIN INVALID"
      end
      prev_time = timestamp_string

      if previous_hash != prev_found_hash
        abort "Line #{block_number_check}: Previous hash was #{previous_hash}, should be #{prev_found_hash}\n BLOCKCHAIN INVALID"
      end
      prev_found_hash = Methods.hash("#{block_number}|#{previous_hash}|#{transaction_string}|#{timestamp_string}")
      if prev_found_hash != current_hash
        abort "Line #{block_number_check}: String \'#{block_number}|#{previous_hash}|#{transaction_string}|#{timestamp_string}\' hash set to #{current_hash}, should be #{prev_found_hash}\n BLOCKCHAIN INVALID"
      end

      transaction_result = Methods.compute_block_transaction(transaction_string, addresses)

      if !transaction_result[0]
        abort "Line #{block_number_check}: Invalid block, address #{transaction_result[1].name} has #{transaction_result[1].balance} billcoins\n BLOCKCHAIN INVALID"
      end

      block_number_check = block_number_check + 1
    end
    file.close
  rescue ArgumentError => e
    abort "Line #{block_number_check}: Transaction string #{transaction_string} has an invalid address\n BLOCKCHAIN INVALID"
  rescue
    abort "Error while reading from file, check whether the file exists and is in the right format"
  end
  addresses.each do |address|
    print "\n"+address.name+": "+address.balance.to_s+" billcoins"
  end
end
