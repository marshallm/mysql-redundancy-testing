#
# Cookbook Name:: ha-mysql
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

hostsfile_entry '192.168.255.11' do
  hostname  'db1-node'
  action    :create_if_missing
end

hostsfile_entry '192.168.255.12' do
  hostname  'db2-node'
  action    :create_if_missing
end

if node["platform"] == "ubuntu"

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
end

if node["platform"] == "centos"

  package 'pacemaker'
  package 'cman'
  package 'pcs'
  package 'ccs'
  package 'resource-agents'

  cookbook_file "/etc/corosync/authkey" do
    source "authkey"
    owner "root"
    group "root"
    mode "0400"
    action :create_if_missing
  end

  cookbook_file "/etc/cluster/cluster-configure.sh" do
    source "centos-cluster-configure.sh"
    owner "root"
    group "root"
    mode "0700"
    action :create
  end

  execute "configure-cluster" do
    not_if "grep -q 'pacemaker' /etc/cluster/cluster.conf"
    command "/bin/sh /etc/cluster/cluster-configure.sh"
    action :run
  end
  
  cookbook_file "/etc/sysconfig/cman" do
    source "sysconfig-cman"
    owner "root"
    group "root"
    mode "0644"
    action :create
  end

  service "pacemaker" do
    action [ :start, :enable ]
  end
  
  template "/etc/cluster/resource-configure.sh" do
    source "centos-resource-configure.sh.erb"
    owner "root"
    group "root"
    mode "0744"
  end
  
  execute "configure-resources" do
    not_if "/usr/sbin/pcs status | grep -q 'ClusterIP'"
    command "/bin/sh /etc/cluster/resource-configure.sh"
    action :run
  end
end
