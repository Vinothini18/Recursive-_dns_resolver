def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone.txt")

#code starting

def parse_dns(dns_raw)
  dns_raw.each do |record_unsplit|
    record = record_unsplit.split(",")

    if record[0] == "A"
      $A_hash[record[1].strip] = record[2].strip
    elsif record[0] == "CNAME"
      $CNAME_hash[record[1].strip] = record[2].strip
    else
      puts "Faulty record found with domain : #{record[1]}"
    end
  end

  dns_record = {}
  dns_record[:A_hash] = $A_hash
  dns_record[:CNAME_hash] = $CNAME_hash
  return dns_record
end

$A_hash = {}
$CNAME_hash = {}

def resolve(dns_records, lookup_chain, new_domain)
  if dns_records[:A_hash][new_domain]

    # If the domain name is present as an A record in the
    # A_hash hashtable
    lookup_chain.append(dns_records[:A_hash][new_domain])
    return lookup_chain
  elsif dns_records[:CNAME_hash][new_domain]

    # If the domain name is present as an alias in the CNAME_hash
    # hastable.

    lookup_chain.append(dns_records[:CNAME_hash][new_domain])
    resolve(dns_records, lookup_chain, dns_records[:CNAME_hash][new_domain])
  else

    #If the domain name was not found in any of the records.
    puts "The domain name #{new_domain} was not found in DNS records."
    lookup_chain.append("End")
    return lookup_chain
  end
end

#Code ends here

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)

puts lookup_chain.join(" => ")