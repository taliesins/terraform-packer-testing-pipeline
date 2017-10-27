execute 'install goss (a lightweight serverspec alternative)' do
  goss_file_location = node[:base][:goss][:file_location]
  goss_installation_url = node[:base][:goss][:file_uri]
  command "sudo curl -o #{goss_file_location} -L #{goss_installation_url}; chmod +x #{goss_file_location}"
end

directory '/usr/share/goss' do
  action :create
end

cookbook_file '/usr/share/goss/base_tests.yml' do
  source 'goss.yml'
  mode '0644'
end
