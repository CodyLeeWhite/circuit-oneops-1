require 'serverspec'
require 'pathname'
require 'json'

if ENV['OS'] == 'Windows_NT'
  set :backend, :cmd
  # On Windows, set the target host's OS explicitly
  set :os, :family => 'windows'
  $node = ::JSON.parse(File.read('c:\windows\temp\serverspec\node.json'))
else
  set :backend, :exec
  if ENV['WORKORDER'] && !ENV['WORKORDER'].empty?
    $node = ::JSON.parse(File.read(ENV['WORKORDER'].to_s))
  else
    $node = ::JSON.parse(File.read('/tmp/serverspec/node.json'))
  end
end

set :path, '/sbin:/usr/local/sbin:/usr/sbin:$PATH' unless os[:family] == 'windows'
