package 'nginx' do
  action :install
end

service 'nginx' do
  action [:enable, :start]
end

directory '/usr/share/nginx/html' do
  action :create
end

cookbook_file "/usr/share/nginx/html/index.html" do
  source 'index.html'
  mode '0644'
end

cookbook_file "/usr/share/goss/nginx_tests.yml" do
  source "goss.yml"
  mode "0644"
end
