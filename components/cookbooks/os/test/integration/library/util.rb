# Testing library

# Mimics file creation of /etc/bind/named.conf.options file from network.rb
#
# @param  : chef node object
# @return : string file contents
#
def get_options_config_string
  given_nameserver =(`cat /etc/resolv.conf |grep -v 127  | grep -v '^#' | grep nameserver | awk '{print $2}'`.split("\n")).join(";")
  options_config =  "options {\n"
  options_config += "  directory \"/var/cache/bind\";\n";
  options_config += "  auth-nxdomain no;    # conform to RFC1035\n";
  options_config += "  listen-on-v6 { any; };\n";
  options_config += "  forward only;\n"
  options_config += "  forwarders { "+given_nameserver+"; };\n"
  options_config += "};\n"

  return options_config
end

# Mimics file creation of /etc/bind/named.conf.local file from network.rb
#
# @param  : chef node object
# @return : string file contents
#
def get_zone_config_string(node)
  zone_config = ""
  zone_domain = get_zone_domain(node)
  
  authoritative_dns_servers = (`dig +short NS #{zone_domain}`).split("\n")
  dig_out = `dig +short #{authoritative_dns_servers.join(" ")}`
  nameservers = dig_out.split("\n")
  
  nameservers = compare_forwarders(nameservers)
  zone_config += "zone \"#{zone_domain+'.'}\" IN {\n"
  zone_config += "    type forward;\n"
  zone_config += "    forwarders {"+nameservers.join(";")+";};\n"
  zone_config += "};\n"

  return zone_config
end

# Mimics file creation of /etc/dhcp/dhclient.conf file from network.rb
#
# @param  : chef node object
# @return : string file contents
#
def get_dhcp_config_string(node)
  rfcCi = node['workorder']['rfcCi']
  host_name = "#{node['workorder']['box']['ciName']}-#{node['workorder']['cloud']['ciId']}-#{node['workorder']['rfcCi']['ciName'].split('-').last.to_i.to_s}-#{rfcCi['ciId']}"
  full_hostname = "#{host_name}.#{node['customer_domain']}"
  customer_domain = node['customer_domain']
  given_nameserver =(`cat /etc/resolv.conf |grep -v 127  | grep -v '^#' | grep nameserver | awk '{print $2}'`.split("\n")).join(";")
  if customer_domain =~ /^\./
    customer_domain.slice!(0)
  end
  customer_domains = ""
  customer_domains_dot_terminated = ""
  if node['workorder']['rfcCi']['ciAttributes'].has_key?("additional_search_domains") &&
      !node['workorder']['rfcCi']['ciAttributes']['additional_search_domains'].empty?

    additional_search_domains = JSON.parse(node['workorder']['rfcCi']['ciAttributes']['additional_search_domains'])
    additional_search_domains.each do |d|
      customer_domains += "\"#{d.strip}\","
      customer_domains_dot_terminated += "#{d.strip}. "
    end
  end
  customer_domains += "\"#{customer_domain}\""
  customer_domains.downcase!

  

  dhcp_config_content = "supersede domain-search #{customer_domains};\n"
  dhcp_config_content += "prepend domain-name-servers 127.0.0.1;\n"
  dhcp_config_content += "supersede domain-name-servers #{given_nameserver.gsub(";",",")};\n"
  dhcp_config_content += "send host-name \"#{full_hostname.downcase}\";\n"

  return dhcp_config_content
end

# Mimics zone domain gathering operation in network.rb recipe
#
# @param  : chef node object
# @return : string zone domain
#
def get_zone_domain(node)
  node['customer_domain']
  
  zone_domain = node['customer_domain'].downcase
  dns_zone_found = false
  while !dns_zone_found && zone_domain.split(".").size > 2
    result = `dig +short NS #{zone_domain}`.to_s
    
    valid_result = result.split("\n") - [""]
    if valid_result.size > 0
      dns_zone_found = true
    else
      parts = zone_domain.split(".")
      trash = parts.shift
      zone_domain = parts.join(".")
    end
  end
  
  return zone_domain
end

# Checks whether the list of forwarders ip contain the same elements as named servers in any order
#
# @param  : namedservers array of ips
# @return : array namedervers if namedservers matches forwarders in /etc/bind/named.conf.local
#
def compare_forwarders(namedservers=[])
  temp_array = []
  File.foreach('/etc/bind/named.conf.local') do |line|
    if line =~ /forwarders/
      temp = line.strip
      temp = temp.scan(/(forwarders {[\d,.,;]*})/).last.first
      temp_array = temp.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
    end
  end
  if namedservers.sort == temp_array.sort
    return temp_array
  else
    return namedservers
  end
end