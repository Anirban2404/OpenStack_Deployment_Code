This will guide to add new compute node to existing controller node.

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
root@ubuntu:~/OpenStack_Deployment_Code#  cp -r Add_Compute/ /root/
cd /root/Add_Compute
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

After the reboot of compute nodes, please check the connectivity. (e.g ping -c 4 www.google.com)

========================================================
Configure /etc/hosts
========================================================
No Configure the /etc/hosts file of the Compute Node.
```
chmod 755 compute_node_host_setup.sh
./compute_node_host_setup.sh
```
Setup root ssh between controller and new compute and edit /etc/hosts in Controller node
```
chmod 755 change_hosts.sh
./change_hosts.sh
```

========================================================
Network Time Protocol (NTP) -- chrony
========================================================

Setup Network Time Protocol (NTP) -- chrony in new compute node
chmod 755 compute_chrony.sh
./compute_chrony.sh

chmod 755 verify_chrony.sh
./verify_chrony.sh

========================================================
Setup openstack environment
========================================================

Enable the OpenStack repository and install openstack packages in Compute node
./openstack_packages.sh

========================================================
Add the Compute service -- Nova
========================================================
Configure nova-compute in compute node
./compute_nova_setup.sh

========================================================
Add the Networking service -- Neutron
========================================================
Install and Configure OpenStack Networking – neutron in compute node
./compute_neutron_setup.sh 
it includes compute_neutron_selfservice_setup.sh


========================================================
Add the Configuration of live migrations
========================================================
Install and Configure Live Migration in compute node
```
./compute_setup_livemigration.sh
```
verify Live Migration on compute
```
./Compute/verify_live_migration.sh
```