# OpenStack Deployment Code on Ubuntu
All the documentation is based on http://docs.openstack.org/liberty/install-guide-ubuntu/.

In the Controller node:

----------------
```
root@ubuntu:~# git clone https://github.com/Anirban2404/OpenStack_Deployment_Code

Cloning into 'OpenStack_Deployment_Code'...
remote: Counting objects: 81, done.
remote: Compressing objects: 100% (40/40), done.
remote: Total 81 (delta 46), reused 68 (delta 39), pack-reused 0
Unpacking objects: 100% (81/81), done.
Checking connectivity... done.
root@ubuntu:~# ls -lrt
total 4
drwxr-xr-x 5 root root 4096 May  2 10:59 OpenStack_Deployment_Code
root@ubuntu:~# cd OpenStack_Deployment_Code/
root@ubuntu:~/OpenStack_Deployment_Code# ls
Compute  Controller  openstack_installation_documentaion.txt  README.md
```
-------------------


```
sudo su
```
Put the Controller folder in /root/
```
root@ubuntu:~/OpenStack_Deployment_Code# cp -r Controller/ /root/
cd /root/Controller
chmod 755 controller_configure_network.sh
```
Create .nic_interfaces and change private and public interface name accordingly
```
vi ~/.nic_interfaces
```
e.g.
```
private_interface = em1
public_interface = p1p1
```
In the Controller folder execute configure_network.sh
```
./controller_configure_network.sh
```
In the configure_network.sh below scripts will be executed.
Execute to enable root login 
```
./enable_root_login.sh
```
Setup controller name
```
./contoller_name_setup.sh
```
Execute to do linux portforward
```
./linux_portforward.sh
```
Execute to setup network on controller node
```
./openstack_network_setup.sh
```
========================================================


In the Compute node(s):
----------------
```
root@ubuntu:~# git clone https://github.com/Anirban2404/OpenStack_Deployment_Code

Cloning into 'OpenStack_Deployment_Code'...
remote: Counting objects: 81, done.
remote: Compressing objects: 100% (40/40), done.
remote: Total 81 (delta 46), reused 68 (delta 39), pack-reused 0
Unpacking objects: 100% (81/81), done.
Checking connectivity... done.
root@ubuntu:~# ls -lrt
total 4
drwxr-xr-x 5 root root 4096 May  2 10:59 OpenStack_Deployment_Code
root@ubuntu:~# cd OpenStack_Deployment_Code/
root@ubuntu:~/OpenStack_Deployment_Code# ls
Compute  Controller  openstack_installation_documentaion.txt  README.md
```
-------------------
```
sudo su
```
Put the Compute folder in /root/
```
root@ubuntu:~/OpenStack_Deployment_Code#  cp -r Compute/ /root/
cd /root/Compute
chmod 755 compute_configure_network.sh
```
Create .nic_interfaces and change private and public interface name accordingly

```
vi ~/.nic_interfaces
```
e.g.
```
private_interface = em1
public_interface = p1p1
```

In the Compute folder execute configure_network.sh
```
./compute_configure_network.sh
```
In the configure_network.sh below scripts will be executed.
Execute to enable root login 
```
./enable_root_login.sh
```
Setup compute name(s)
```
./compute_name_setup.sh
```
Execute to setup network on compute node(s)
```
./openstack_network_setup.sh
```
========================================================

After the reboot of all nodes, please check the connectivity. (e.g ping -c 4 www.google.com)

========================================================
Configure /etc/hosts
========================================================
No Configure the /etc/hosts file of the Controller Node.
```
chmod 755 controller_node_host_setup.sh
./controller_node_host_setup.sh
```
Setup root ssh between controller and computes and edit /etc/hosts in Compute nodes
```
chmod 755 controller_find_computes.sh
./controller_find_computes.sh
```
========================================================
Network Time Protocol (NTP) -- chrony
========================================================

Setup Network Time Protocol (NTP) -- chrony in all nodes
```
chmod 755 chrony_setup.sh
./chrony_setup.sh
```
In the chrony_setup.sh below scripts will be executed.
Setup Network Time Protocol (NTP)--Chrony in controller node
```
./controller_chrony.sh
```
Setup Network Time Protocol (NTP)--Chrony in compute node(s) by ssh from Controller node
```
./controller_chrony_computes.sh
```
It'll execute the below script in Compute node(s)
```
./Compute/compute_chrony.sh
```
Verify chrony is all node.
```
chmod 755 verify_chrony.sh
./verify_chrony.sh
```
========================================================
Setup openstack environment
========================================================

Setup openstack environment
```
chmod 755 openstack_environment_setup.sh
./openstack_environment_setup.sh
```
In openstack_environment_setup.sh below scripts will be executed.
Enable the OpenStack repository and install openstack packages in Controller node
```
./openstack_packages.sh
```
Enable the OpenStack repository and install openstack packages in Compute node by ssh from Controller node
```
./controller_openstackpkgs_computes.sh
```
It'll execute the below script in Compute node(s)
```
./Compute/openstack_packages.sh
```
Install and configure components SQL database (MariaDB) in Controller Node
```
./controller_sqlsetup.sh
```
Install and configure components NoSQL database (MongoDB) in Controller Node
```
./controller_nosqlsetup.sh
```
Message queue RABBITMQ setup
```
./controller_messagequeuesetup.sh
```
========================================================
Add the Identity service -- Keystone
========================================================

Add the Identity service -- Keystone
```
chmod 755 openstack_keystone_setup.sh
./openstack_keystone_setup.sh
```
In openstack_keystone_setup.sh below scripts will be executed.
Install and configure Keystone Identity service
```
./controller_keystone_setup.sh
```
Configure the Apache HTTP server
```
./controller_apache_config.sh
```
Create the keystone service entity and API endpoints and projects, users, and roles
```
./openstack_keystone_endpoint_setup.sh
```
Verify operation of the keystone Identity service before installing other services
```
./verify_keystone.sh
```
========================================================
Add the Image service -- Glance
========================================================

Add the glance Image service
```
chmod 755 controller_glance_setup.sh
./controller_glance_setup.sh
```
Verify the glace image service
```
chmod 755 verify_glance.sh
./verify_glance.sh
```
========================================================
Add the Compute service -- Nova
========================================================

Make sure to add controller in known host.

Add the Identity service -- Keystone
```
chmod 755 openstack_nova_setup.sh
./openstack_nova_setup.sh
```
In openstack_nova_setup.sh below scripts will be executed.
Install and Configure nova-compute in controller node
```
./controller_nova_setup.sh
```
Install and Configure nova-compute in compute node(s) by ssh from Controller node
```
./controller_nova_computes.sh
```
It'll execute the below script in Compute node(s)
```
./Compute/compute_nova_setup.sh
```
Verify nova setup from Controller node
```
./verify_nova.sh
```
========================================================
Add the Networking service -- Neutron
========================================================

Make sure to add controller in known host.

Add the Networking service -- Neutron
```
chmod 755 openstack_neutron_setup.sh
./openstack_neutron_setup.sh
```
In openstack_neutron_setup.sh below scripts will be executed.
Add OpenStack Networking – neutron in controller node
```
./controller_neutron_setup.sh 
```
It includes controller_neutron_selfservice_setup.sh

Install and Configure OpenStack Networking – neutron in compute node(s) by ssh from Controller node
```
./controller_neutron_computes.sh
```
It'll execute the below script in Compute node(s)
```
./Compute/compute_neutron_setup.sh
```
It includes compute_neutron_selfservice_setup.sh

Verify neutron networking service
```
./verify_neutron.sh
```
========================================================
Add the dashboard
========================================================
Add dashboard
```
chmod 755 controller_dashboard_setup.sh
./controller_dashboard_setup.sh
```

========================================================
Add the OpenStack Orchestration service -- Heat
========================================================

Add the OpenStack Orchestration service -- Heat
```
chmod 755 controller_heat_setup.sh
./controller_heat_setup.sh
```
Verify the OpenStack Orchestration service -- Heat
```
chmod 755 verify_heat.sh
./verify_heat.sh
```
========================================================
Add the Configuration of live migrations
========================================================

Setup Live Migration in controller node
```
chmod 755 controller_setup_livemigration.sh
./controller_setup_livemigration.sh
```
Install and Configure Live Migration in compute node(s) by ssh from Controller node
```
chmod 755 ssh_live_migration.sh
./ssh_live_migration.sh
```
It'll execute the below script in Compute node(s)
```
./Compute/compute_setup_livemigration.sh
```
verify Live Migration on compute
```
./Compute/verify_live_migration.sh
```
========================================================
Setup Network
========================================================

Setup public network
```
chmod 755 setup_public_network.sh
./setup_public_network.sh
```
Setup private network
```
chmod 755 setup_private_network.sh
./setup_private_network.sh
```
Setup security
```
chmod 755 setup_security.sh
./setup_security.sh
```
========================================================
Spawn using heat
========================================================
Heat spawn
Make sure you have demo-template.yml
```
chmod 755 sample_spawn.sh
./sample_spawn.sh
```
