# cookbook util
require '/home/oneops/circuit-oneops-1/components/cookbooks/os/libraries/util'
# Testing util
require '/home/oneops/circuit-oneops-1/components/cookbooks/os/test/integration/library/util'

rfcCi = $node['workorder']['rfcCi']
host_name = "#{$node['workorder']['box']['ciName']}-#{$node['workorder']['cloud']['ciId']}-#{$node['workorder']['rfcCi']['ciName'].split('-').last.to_i.to_s}-#{rfcCi['ciId']}"
fqdn_name = "#{host_name}.#{$node['customer_domain']}"

data = YAML::load(File.read("/home/oneops/circuit-oneops-1/components/cookbooks/os/test/integration/add/serverspec/checklist.yml"))
limits = {}

# Directory and file checks
checks = data['files']
checks.each do |check|
  if check['type'] == 'd'
    describe file(check['name']) do
      it { should be_directory  }
      it { should be_mode check['mode'] }
      it { should be_owned_by check['owner'] }
      it { should be_grouped_into check['group'] }
    end
  else
    describe file(check['name']) do
      it { should be_file }
      it { should be_mode check['mode'] }
      it { should be_owned_by check['owner'] }
      it { should be_grouped_into check['group'] }
    end
  end
end

# Config file contents

#--- add-config-files.rb
env_vars_content = get_cloud_env_vars_content($node)
oo_vars_content = get_oo_vars_content($node)
oo_vars_conf_content = get_oo_vars_conf_content($node)

describe file('/etc/profile.d/oneops_compute_cloud_service.sh') do
  its(:content) { should eq env_vars_content }
end
describe file('/etc/profile.d/oneops.sh') do
  its(:content) { should eq oo_vars_content }
end
describe file('/etc/profile.d/oneops.conf') do
  its(:content) { should eq oo_vars_conf_content }
end
describe file("/etc/oneops") do
  it { should be_symlink }
end
#--- add-config-files.rb

#--- network.rb
host_cmd = `hostname -f`

describe file('/etc/cloud/cloud.cfg') do
  its(:content) { should match /preserve_hostname: true/ }
end

describe file('/etc/cloud/cloud.cfg.d/99_hostname.cfg') do
  its(:content) { should eq "hostname: #{host_name.downcase}\nfqdn: #{fqdn_name.downcase}\n" }
end

describe file('/opt/oneops/domain') do
  its(:content) { should eq "#{$node['customer_domain']}\n" }
end

describe "FQDN" do
  it "Should equal #{fqdn_name.downcase}" do
    expect(host_cmd.downcase.strip).to be == fqdn_name.downcase.strip
  end
end

describe file('/etc/bind/named.conf.options') do
  its(:content) { should eq get_options_config_string }
end

describe file('/etc/bind/named.conf.local') do
  its(:content) { should eq get_zone_config_string($node) }
end

describe file('/etc/dhcp/dhclient.conf') do
  its(:content) { should eq get_dhcp_config_string($node) }
end

describe command('ls -1 /etc/dhcp/*conf|grep -v dhclient.conf') do
  its(:exit_status) { should eq 1 }
end

describe service('named') do
  it { should be_enabled }
end

attrs = $node[:workorder][:rfcCi][:ciAttributes]
if attrs[:dhclient] == 'false'
  describe file('/etc/init.d/killdhclient') do
    it { should exist }
  end
else
  describe file('/etc/init.d/killdhclient') do
    it { should_not exist }
  end
end
#--- network.rb

#--- time.rb
timezone = $node['workorder']['rfcCi']['ciAttributes']['timezone']

describe file('/etc/localtime') do
  it { should be_symlink }
  it { should be_linked_to "/usr/share/zoneinfo/#{timezone}" }
end
describe file('/etc/sysconfig/clock') do
  its(:content) { should eq "ZONE=\"#{timezone}\"\n" }
end
#--- time.rb

#--- kernel.rb
if $node['workorder']['rfcCi']['ciAttributes'].has_key?('limits') && !$node['workorder']['rfcCi']['ciAttributes']['limits'].empty? && JSON.parse($node['workorder']['rfcCi']['ciAttributes']['limits']) != limits
  limits = JSON.parse($node['workorder']['rfcCi']['ciAttributes']['limits'])
  limits.each do |lim|
    describe file('/etc/security/limits.d/oneops.conf') do
      its(:content) { should match /#{lim}/ }
    end
  end
else
  describe file('/etc/security/limits.d/oneops.conf') do
    its(:content) { should eq '' }
  end
end
#--- kernel.rb

# Config file contents end

# Yum packages
packages = data['packages']
packages.each do |a_package|
  describe package(a_package) do
    it { should be_installed }
  end
end

# Gems
gems = data['gems']
gems.each do |a_gem|
  describe package(a_gem) do
    it { should be_installed.by('gem') }
  end
end

# Proxys

# Check against yum repos
yum_repos_url = `yum repolist enabled -v | grep Repo-baseurl | awk  '{print $3}'`.split
yum_repos_url.each do |yum_url|
  describe command("curl -I #{yum_url}") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /200 OK/ }
  end
end

# Check against Gem sources
describe command("curl -I `gem source | grep http -m 1`") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /200 OK/ }
end


describe user("oneops") do
  it { should exist }
end

context "Environment variable" do
  it "should exist" do
    result = `env`
    variables = result.split("\n")
    env_var = Hash.new
    variables.each do |var|
      env_key = var.split("=").first
      env_value = var.split("=").last
      env_var[env_key] = env_value
    end

    env_variable = get_cloud_environment_vars($node)
    env_variable.each do |key,value|
      expect(env_var[key]).to eq(value) if !value.empty?
    end
  end
end