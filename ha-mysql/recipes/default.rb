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
