#
# Cookbook Name:: nodejs
# Recipe:: Install_from_file
#
require 'yaml'

runtimes = YAML.load_file("/etc/oneops-tools-inventory.yml")

runtime_path = runtimes["nodejs_#{node['nodejs']['version']}"]
Chef::Log.info("Runtime path is #{runtime_path}")

destination_dir = node['nodejs']['dir']
Chef::Log.info("OneOps CI destination_dir : #{destination_dir}")

execute "install package to system" do
  command <<-EOF
            ln -sf #{runtime_path}/bin/* #{destination_dir}/bin/
            ln -sf #{runtime_path}/share/* #{destination_dir}/share/
            ln -sf #{runtime_path}/lib/* #{destination_dir}/lib/
  EOF
end


execute "set npm registry" do
  command "#{node['nodejs']['dir']}/bin/npm config set registry #{node['nodejs']['npm_src_url']}"
  only_if { node['nodejs']['npm_src_url'] }
end

execute "set npm strict-ssl" do
  command "#{node['nodejs']['dir']}/bin/npm config set strict-ssl false"
  only_if { node['nodejs']['npm_src_url'] }
end

execute "update npm" do
  command "#{node['nodejs']['dir']}/bin/npm install npm@#{node['nodejs']['npm']} -g"
  not_if "#{node['nodejs']['dir']}/bin/npm -v 2>&1 | grep '#{node['nodejs']['npm']}'"
end
