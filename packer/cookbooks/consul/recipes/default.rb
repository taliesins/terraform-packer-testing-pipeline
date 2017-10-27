download_url_parts = [
  'consul',
  node[:consul][:version],
  "consul_#{node[:consul][:version]}_linux_amd64.zip"
]
download_url = "https://releases.hashicorp.com/#{download_url_parts.join('/')}"

remote_file "Download Consul zip from #{download_url}" do
  path "/tmp/consul.zip"
  source download_url
  action :create
end

execute "unzip Consul package" do
  command "unzip -d /tmp/consul /tmp/consul.zip"
  not_if { !File.exists?('/tmp/consul.zip') }
end

remote_file "Copy Consul package to #{node[:consul][:installation_directory]}" do
  path "/usr/local/bin/consul"
  source "file:///tmp/consul/consul"
  mode 0755
  not_if { !File.exists?('/tmp/consul/consul') }
end

cookbook_file "/etc/systemd/system/consul.service" do
  source "consul.service"
  action :create
end

directory "/etc/consul.d" do
  action :create
end


[ '/var/consul', '/var/consul/data'].each do |path|
  directory path do
    action :create
  end
end
