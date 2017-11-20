execute "apt-get update" do
  command "apt-get update"
end

mysql_password = ''

apt_package 'mysql-server' do
  action :install
end

node['opencart_setup']['mysql']['users'].each do |username, data|
  execute 'create user' do
    command "mysql -u root -p#{mysql_password} -D mysql -r -B -N -e \"CREATE USER '#{data[:username]}'@'localhost' IDENTIFIED BY '#{data[:password]}'\""
    not_if "mysql -u root -D mysql -r -B -N -e \"SELECT * FROM mysql.user\" | grep #{data[:username]}"
  end

  execute 'grant access to user' do
    command "mysql -u root -p#{mysql_password} -D mysql -r -B -N -e \"GRANT ALL PRIVILEGES ON * . * TO '#{data[:username]}'@'localhost'\""
    not_if "mysql -u root -D mysql -r -B -N -e \"SELECT * FROM mysql.user\" | grep #{data[:username]}"
  end

  execute 'flush privilege' do
    command "mysql -u root -p#{mysql_password} -D mysql -r -B -N -e \"FLUSH PRIVILEGES\""
    not_if "mysql -u root -D mysql -r -B -N -e \"SELECT * FROM mysql.user\" | grep #{data[:username]}"
  end

  execute 'create database' do
    command "mysql -u #{data[:username]} -p#{data[:password]} -D mysql -r -B -N -e \"CREATE DATABASE #{data[:database]}\""
    not_if "mysql -u root -D mysql -r -B -N -e \"SHOW DATABASES\" | grep #{data[:database]}"
  end

  execute 'restore data' do
    command "mysql -u #{data[:username]} -p#{data[:password]} #{data[:database]} < /vagrant/ocart2/larrycoc_ocar825.sql"
  end
end
