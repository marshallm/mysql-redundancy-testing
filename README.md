mysql-redundancy-testing
========================

I used this to experiment with setting up corosync/pacemaker with MySQL.

On a properly setup workstation you can boot up 3 servers and play with MySQL

Prerequisites:

- Install [VirtualBox](https://www.virtualbox.org) latest version
- Install and use [RVM](http://rvm.io) to get ruby (latest version) installed and setup
- Download [vagrant](http://www.vagrantup.com/downloads.html) latest version and install
- Downlad [chef-dk](http://downloads.getchef.com/chef-dk/) latest version and install
  - This includes Berkshelf and foodcritic and a bunch of other crap
- Install chef gem `gem install chef`

The do these bash commands:

    vagrant plugin install vagrant-berkshelf
    vagrant plugin install vagrant-omnibus
    git clone git@github.com:mclazarus/mysql-redundancy-testing.git
    # Alternate command: If ssh is not setup with github use this instead- 
    #      git clone https://github.com/mclazarus/mysql-redundancy-testing.git
    cd mysql-redundancy-testing/ha-mysql
    # Install Bundler if not installed:  gem install bundler
    bundle install
    # Deal with a problem with virtual box
    VBoxManage dhcpserver remove --netname HostInterfaceNetworking-vboxnet0

Now you're ready to get the machines running.  At this point you can boot into ubuntu 14.04 and see it working which is corosync/pacemaker using the corosync pacemaker plugin.  Which aparently is not the way RedHat is doing it anymore.  They're using cman to manage the configuration.

But for testing I wanted to validate it on CentOS 6.3.  I have that working two in this recipe and Vagrantfile.  To do CentOS you set the environment variable HA_CENTOS=true and then run vagrant up.

so:

    vagrant up # for ubuntu 14.04

or:

    HA_CENTOS=true vagrant up # for centos 6.3
  
  # If you encounter errors running vagrant installing chef.  For example, installing corosync when running package corosync in the ha-mysql:default recipe.  Run - vagrant ssh <example db1>, once on the machine run sudo apt-get update , exit.  Rerun on bash as vagrant provision <example db1>.  This should have cleaned up everything on db1 (for example) and you should successfully setup everything for that machine.
    
After all the stuff gets setup and you'll have 3 machines running and you can work them out by running these commands and see this result.

    $ vagrant ssh client1
    Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-24-generic x86_64)

     * Documentation:  https://help.ubuntu.com/
    Last login: Sat Apr 19 05:27:17 2014 from 10.0.2.2
    vagrant@client1:~$ mysql -u root -prootpass -h 192.168.255.254
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 41
    Server version: 5.5.35-1ubuntu1 (Ubuntu)

    Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | mysql              |
    | performance_schema |
    +--------------------+
    3 rows in set (0.02 sec)
    mysql>


This showed you connecting to the default shared IP 192.168.255.254.

In another window in the same directory:

    $ vagrant ssh -c 'sudo /usr/sbin/crm status' db1
    Last updated: Thu Aug 28 21:00:49 2014
    Last change: Thu Aug 28 20:53:10 2014 via cibadmin on db1
    Stack: corosync
    Current DC: db2 (1084817154) - partition with quorum
    Version: 1.1.10-42f2063
    2 Nodes configured
    1 Resources configured


    Online: [ db1 db2 ]

     shared_ip	(ocf::heartbeat:IPaddr2):	Started db1
    Connection to 127.0.0.1 closed.


And you see there are two nodes online and they have a shared_ip running on db1.  Using CentOS you need to use the command: `vagrant ssh -c 'sudo /usr/sbin/pcs status' db1` to learn the state of the cluster.  As `crm` is not supported on RedHat and it's variants.


    $ vagrant halt db1
    ==> db1: Attempting graceful shutdown of VM...
    $ vagrant ssh -c 'sudo /usr/sbin/crm status' db2
    Last updated: Thu Aug 28 21:09:55 2014
    Last change: Thu Aug 28 20:53:10 2014 via cibadmin on db2
    Stack: corosync
    Current DC: db2 (1084817154) - partition WITHOUT quorum
    Version: 1.1.10-42f2063
    2 Nodes configured
    1 Resources configured


    Online: [ db2 ]
    OFFLINE: [ db1 ]

     shared_ip	(ocf::heartbeat:IPaddr2):	Started db2
    Connection to 127.0.0.1 closed.

Now you can see that there is one node online one offline and the shared_ip is on db2.

If you switch back to your `client1` window and issue a database command (show databases) you'll see that your connection went away, but the mysql-client successfully reconnects and can issue the command as the IP has failed over.

