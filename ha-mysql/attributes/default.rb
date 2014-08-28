default['corosync_bind'] = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == 'inet' }.first
