#
# Cookbook Name:: ha-mysql
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'corosync'
package 'pacemaker'


template "/etc/corosync/corosync.conf" do
  source "corosync.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/corosync/authkey" do
  source "authkey"
  owner "root"
  group "root"
  mode "0400"
  action :create_if_missing
end

cookbook_file "/etc/default/corosync" do
  source "corosync-default"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

service "corosync" do
  action [ :start, :enable ]
end

service "pacemaker" do
  action [ :start, :enable ]
end

# Configure cluster for shared IP

template "/etc/corosync/crm-resource-configuration.res" do
  source "crm-resource-configuration.res.erb"
  owner "root"
  group "root"
  mode "0644"
end

execute "configure-cluster" do
  not_if "/usr/sbin/crm status | grep -q 'shared_ip'"
  command "/usr/sbin/crm configure < /etc/corosync/crm-resource-configuration.res"
  action :run
end

