#
# Cookbook:: opencart_setup
# Recipe:: php5
#
# Copyright:: 2017, The Authors, All Rights Reserved.

packages = ["wget", "unzip", "php7.0-mysql", "php7.0-curl", "php7.0-json",
            "php7.0-cgi", "php7.0", "libapache2-mod-php7.0", "php7.0-mcrypt"]

execute "apt-get update" do
  command "apt-get update"
end

packages.each do |package|
  apt_package package do
    action :install
  end
end
