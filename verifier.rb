require_relative "methods"


if ARGV.size != 1
  abort "You must provide a file to verify."
end

begin
  @adresses = Array::new
  file = File.open(filename, "r")
  block_number_check = 0
  prev_found_hash = "0";
  prev_time = "0.0"
  file.each_line do |line|
    block_number,previous_hash,transaction_string,timestamp_string,current_hash
    if block_number != block_number_check
      abort "Invalid block number #{block_number} We expected #{block_number_check}"
    end
    if previous_hash != prev_found_hash
      abort "Invalid previous hash of #{previous_hash} We expected #{prev_found_hash} in block #{block_number}"
    end
    prev_found_hash = Methods.hash("#{block_number}|#{previous_hash}|#{transaction_string}|#{timestamp_string}")
    if prev_found_hash != current_hash
      abort "Invalid current hash of #{current_hash} We expected #{prev_found_hash} in block #{block_number}"
    end
    prev_secs = prev_time.split(".")[0].toi
    prev_nano = prev_time.split(".")[1].toi
    cur_secs = timestamp_string.split(".")[0].toi
    cur_nano = timestamp_string.split(".")[1].toi
    if prev_secs > cur_secs
      abort "Invalid time change of #{prev_time} to #{timestamp_string} in block #{block_number}"
    elsif prev_secs == cur_secs && prev_nano >= cur_nano
      abort "Invalid time change of #{prev_time} to #{timestamp_string} in block #{block_number}"
    end
    prev_time = timestamp_string
    begin
      if !Methods.compute_block_transaction(transaction_string, @addresses)
        abort "Invalid transaction at block #{block_number}"
      end
    rescue ArgumentError => e
      abort "Invalid address at block #{block_number}"
    end
    block_number_check++;

  end
  file.close
rescue
  abort "Error Opening/Reading File! Exiting!"
end
