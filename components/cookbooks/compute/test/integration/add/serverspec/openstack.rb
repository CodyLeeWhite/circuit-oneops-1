require "#{CIRCUIT_PATH}/components/spec_helper"
require "#{COOKBOOKS_PATH}/compute/libraries/compute_util"
require 'fog'


cloud_name = $node['workorder']['cloud']['ciName']
provider = $node['workorder']['services']['compute'][cloud_name]['ciClassName'].gsub("cloud.service.","").downcase.split(".").last

if provider =~ /openstack/i
  cloud = $node[:workorder][:services][:compute][cloud_name][:ciAttributes]
  os = nil
  ostype = "default-cloud"
  if $node[:workorder][:payLoad].has_key?("os")
    os = $node[:workorder][:payLoad][:os].first
    ostype = os[:ciAttributes][:ostype]
  else
    Chef::Log.warn("missing os payload - using default-cloud")
    if ostype == "default-cloud"
      ostype = cloud[:ostype]
    end
  end

  compute_service = $node['workorder']['services']['compute'][cloud_name]['ciAttributes']
  rfcCi = $node['workorder']['rfcCi']
  nsPathParts = rfcCi['nsPath'].split("/")
  server_name = $node['workorder']['box']['ciName']+'-'+nsPathParts[3]+'-'+nsPathParts[2]+'-'+nsPathParts[1]+'-'+ rfcCi['ciId'].to_s
  
  domain = compute_service.key?('domain') ? compute_service[:domain] : 'default'

  conn = Fog::Compute.new({
    :provider => 'OpenStack',
    :openstack_api_key => compute_service[:password],
    :openstack_username => compute_service[:username],
    :openstack_tenant => compute_service[:tenant],
    :openstack_auth_url => compute_service[:endpoint],
    :openstack_project_name => compute_service[:tenant],
    :openstack_domain_name => domain
  })  

  server = nil

  # Find your compute
  conn.servers.all.each do |i|
    if i.name == server_name
      server = i
      break
    end
  end

  server_metadata = server.metadata.to_hash
  describe "Compute connection" do
    it "Should exist" do
      expect(server.nil?).to be == false
    end
  end

  describe "Compute", :if => !server.nil? do
    it "Should be in state ACTIVE" do
      expect(server.state).to be == "ACTIVE"
    end
    it "Platform should be #{nsPathParts[5]}" do
      expect(server_metadata['platform']).to be == nsPathParts[5]
    end
    it "Management url should be #{$node['mgmt_url']}" do
      expect(server_metadata['mgmt_url']).to be == $node['mgmt_url']
    end
    it "Organization should be #{$node['workorder']['payLoad']['Organization'][0]['ciName'].to_s}" do
      expect(server_metadata['organization']).to be == $node['workorder']['payLoad']['Organization'][0]['ciName'].to_s
    end
    it "Component should be #{$node['workorder']['payLoad']['RealizedAs'][0]['ciId'].to_s}" do
      expect(server_metadata['component']).to be == $node['workorder']['payLoad']['RealizedAs'][0]['ciId'].to_s
    end
    it "Environment should be #{nsPathParts[3]}" do
      expect(server_metadata['environment']).to be == nsPathParts[3]
    end
    it "Assembly should be #{nsPathParts[2]}" do
      expect(server_metadata['assembly']).to be == nsPathParts[2]
    end
    it "Instance should be #{rfcCi['ciId']}" do
      expect(server_metadata['instance'].to_i).to be == rfcCi['ciId'].to_i
    end
  end

  describe 'Image used' do
    image_used = conn.images.get (server.image)['id']
    pattern = "wmlabs-#{ostype.gsub(/\./, "")}"
    $node['workorder']['config']['TESTING_MODE'].to_s.downcase == "true" ? pattern_snap = "RandomString" : pattern_snap = "snapshot"
    images = conn.images

    if image_used.name =~ /#{pattern}/i && image_used.name !~ /#{pattern_snap}/i
      context "When a fast image" do
        it "Flag should be set" do
          expect($node['workorder']['config']['FAST_IMAGE'].to_s.downcase == "true").to be true
        end
        it 'Should be latest' do
          latest = find_latest_fast_image(images, pattern, pattern_snap)
          expect(latest.name).to eql(image_used.name)
        end
      end
    end

    if image_used.name =~ /#{pattern_snap}/i
      context "When a fast image snapshot" do
        it 'Flag should be set' do
          expect($node['workorder']['config']['TESTING_MODE'].to_s.downcase == "true").to be true
        end
        it 'Should be latest' do

          latest = find_latest_fast_image(images, pattern, pattern_snap)
          expect(latest.name).to eql(image_used.name)
        end
      end
    end

  end
end
