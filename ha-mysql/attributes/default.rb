default['ha-mysql']['corosync_bind'] = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == 'inet' }.first
default['ha-mysql']['shared_ip'] = '192.168.255.254'
