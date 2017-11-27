
# Cookbook:: opencart_setup
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

apt_update 'Update the apt cache daily' do
  frequency 86_400
  action :periodic
end

package 'apache2'

service 'apache2' do
  supports status: true
  action [:enable, :start]
end

www_path = "/home/larrycoc"

directory "#{www_path}/public_html" do
  mode '755'
end

directory "#{www_path}/logs" do
  owner 'root'
  mode '755'
  action :create
end

apache_conf_file = '/etc/apache2/apache2.conf'
apache_configuration = "<Directory #{www_path}/>
          AllowOverride None
          Require all granted
  </Directory>"

execute "Whitelist #{www_path} in Apache" do
  command "echo '#{apache_configuration}' >> #{apache_conf_file}"
  not_if "grep '#{www_path}/' /etc/apache2/apache2.conf"
end


node['opencart_setup']['sites'].each do |sitename, data|
  document_root = www_path

  directory document_root do
    mode "0755"
    recursive true
  end

  template "/etc/apache2/sites-available/#{sitename}.conf" do
    source "virtualhosts.erb"
    mode "0644"
    variables(
      document_root: document_root,
      port: data["port"],
      serveradmin: data["serveradmin"],
      servername: data["servername"]
    )
    notifies :restart, 'service[apache2]'
  end

  execute "enable site" do
    command "a2ensite #{sitename}"
    not_if "ls /etc/apache2/sites-enabled/ | grep larryco.my"
  end
end
