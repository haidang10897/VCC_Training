# Cài đặt NEUTRON (Networking service)


## 1. Cài đặt neutron.

###  Tạo database cho neutron
-  Đăng nhập vào `database`
	 ```sh
	 mysql -u root -pWelcome123
	 ```

	- Tạo database `neutron` và phân quyền:
```sh
	MariaDB [(none)]> CREATE DATABASE neutron;  
Query OK, 1 row affected (0.00 sec)  
MariaDB [(none)]> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'lxcpassword';  
Query OK, 0 rows affected (0.00 sec)  
MariaDB [(none)]> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%'IDENTIFIED BY 'lxcpassword';  
Query OK, 0 rows affected (0.00 sec)  
MariaDB [(none)]> exit  
Bye
```

- Tạo user, endpoint cho dịch vụ `neutron`
	- Khai báo biến môi trường
	 ```sh
	 . rc.admin
	 ```

- Tạo tài khoản tên là `neutron` bằng lênh dưới, sau đó nhập mật khẩu `lxcpassword`:
	 ```sh
	 root@controller:~# openstack user create --domain default --passwordprompt neutron
	 ```

	<img src = "../Images/II.4.1. Cài đặt Neutron/1.png">  

- Gán role `admin` cho tài khoản `neutron`
	```sh
	root@controller:~# openstack role add --project service --user neutron admin
	```
- Tạo dịch vụ tên là `neutron`
	```sh
	root@controller:~# openstack service create --name neutron --description "OpenStack Networking" network
	```
<img src = "../Images/II.4.1. Cài đặt Neutron/2.png">  

- Tạo endpoint tên cho `neutron`
	```sh
	openstack endpoint create --region RegionOne network public http://controller:9696
	openstack endpoint create --region RegionOne network internal http://controller:9696
	openstack endpoint create --region RegionOne network admin http://controller:9696
	```
<img src = "../Images/II.4.1. Cài đặt Neutron/3.png">  

- Cài đặt và cấu hình cho dịch vụ `neutron`. Trong hướng dẫn này lựa chọn cơ chế self-service netwok
- Cài đặt các thành phần cho `neutron`
	```sh
	apt install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutronmetadata-agent
	```
###  Cấu hình cho dịch vụ `neutron`

-  Sao lưu file cấu hình gốc của `neutron`
 	
```sh
	cp /etc/neutron/neutron.conf  /etc/neutron/neutron.conf.orig
```
- Trong section `[database]` comment dòng:
	 ```sh
	 # connection = sqlite:////var/lib/neutron/neutron.sqlite
	 ```
	 
 	và thêm dòng dưới

	```sh
	connection = mysql+pymysql://neutron:lxcpassword@controller/neutron
	```

- Trong section `[DEFAULT]` khai báo lại hoặc thêm mới các dòng dưới: 
	```sh
	core_plugin = ml2
	service_plugins = router
	allow_overlapping_ips = true
	transport_url = rabbit://openstack:lxcpassword@controller
	auth_strategy = keystone
	notify_nova_on_port_status_changes = true
	notify_nova_on_port_data_changes = true
	```

- Trong section `[keystone_authtoken]` khai báo hoặc thêm mới các dòng dưới:
	```sh
	auth_uri = http://controller:5000
	auth_url = http://controller:35357
	memcached_servers = controller:11211
	auth_type = password
	project_domain_name = default
	user_domain_name = default
	project_name = service
	username = neutron
	password = lxcpassword
	```
- Trong section `[nova]` khai báo mới hoặc thêm các dòng dưới
	```sh
	[nova]
	auth_url = http://controller:35357
	auth_type = password
	project_domain_name = default
	user_domain_name = default
	region_name = RegionOne
	project_name = service
	username = nova
	password = lxcpassword
	```
- **TỔNG KẾT LẠI NHƯ SAU:**
```
root@controller:~# cat /etc/neutron/neutron.conf  
[DEFAULT]  
core_plugin = ml2  
service_plugins = router  
allow_overlapping_ips = True  
transport_url = rabbit://openstack:lxcpassword@controller  
auth_strategy = keystone  
notify_nova_on_port_status_changes = True  
notify_nova_on_port_data_changes = True  
[agent]  
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf  
[cors]  
[cors.subdomain]  
[database]  
connection = mysql+pymysql://neutron:lxcpassword@controller/neutron  
[keystone_authtoken]  
auth_uri = http://controller:5000  
auth_url = http://controller:35357  
memcached_servers = controller:11211  
auth_type = password  
project_domain_name = default  
user_domain_name = default  
project_name = service  
username = neutron  
password = lxcpassword  
[matchmaker_redis]  
[nova]  
auth_url = http://controller:35357  
auth_type = password  
project_domain_name = default  
user_domain_name = default  
region_name = RegionOne  
project_name = service  
username = nova  
password = lxcpassword  
[oslo_concurrency]  
[oslo_messaging_amqp]  
[oslo_messaging_notifications]  
[oslo_messaging_rabbit]  
[oslo_messaging_zmq]  
[oslo_policy]  
[qos]  
[quotas]  
[ssl]
```  
### Cài đặt và cấu hình plug-in `Modular Layer 2 (ML2)`
- Sao lưu file `/etc/neutron/plugins/ml2/ml2_conf.ini`
	```sh
	cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.orig
	```

- Trong section `[ml2]` khai báo thêm hoặc sửa dòng dưới
	```sh
	[ml2]
	type_drivers = flat,vlan,vxlan
	tenant_network_types = vxlan
	mechanism_drivers = linuxbridge,l2population
	extension_drivers = port_security
 	```

- Trong section `[ml2_type_flat]` khai báo thêm hoặc sửa thành dòng dưới
	```sh
	[ml2_type_flat]
	flat_networks = provider
	```

- Trong section `[ml2_type_vxlan]` khai báo thêm hoặc sửa thành dòng dưới
	```sh
	[ml2_type_vxlan]
	vni_ranges = 1:1000
	```

- Trong section `[securitygroup]` khai báo thêm hoặc sửa thành dòng dưới
	```sh
	[securitygroup]
	enable_ipset = true
	```
- **TỔNG KẾT LẠI NHƯ SAU:**
```
root@controller:~# cat /etc/neutron/plugins/ml2/ml2_conf.ini  
[DEFAULT]  
[ml2]  
type_drivers = flat,vlan,vxlan  
tenant_network_types = vxlan  
mechanism_drivers = linuxbridge,l2population  
extension_drivers = port_security  
[ml2_type_flat]  
flat_networks = provider  
[ml2_type_geneve]  
[ml2_type_gre]  
[ml2_type_vlan]  
[ml2_type_vxlan]  
vni_ranges = 1:1000  
[securitygroup]  
enable_ipset = True
```  

### Cấu hình `linuxbridge`
- Sao lưu file  `/etc/neutron/plugins/ml2/linuxbridge_agent.ini`
	```sh
	cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini  /etc/neutron/plugins/ml2/linuxbridge_agent.ini.orig
	```

- Trong section `[linux_bridge]` khai báo mới hoặc sửa thành dòng
	 ```sh
	 physical_interface_mappings = provider:ens33
	 ```

- Trong section `[vxlan]` khai báo mới hoặc sửa thành dòng
	```sh
	enable_vxlan = true
	local_ip = 192.168.237.129
	l2_population = true
	```

- Trong section `[securitygroup]` khai báo mới hoặc sửa thành dòng
	```sh
	enable_security_group = true
	firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
	```

- Cấu hình `l3-agent`
 	- Sao lưu file `/etc/neutron/l3_agent.ini`
	```sh
	cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.orig
	```

- Trong section `[DEFAULT]` khai báo mới hoặc sửa thành dòng dưới: 
	```sh
	interface_driver = linuxbridge
	```
- **TỔNG KẾT LẠI NHƯ SAU:**
```
root@controller:~# cat /etc/neutron/plugins/ml2/linuxbridge_agent.ini  
[DEFAULT]  
[agent]  
[linux_bridge]  
physical_interface_mappings = provider:ens33  
[securitygroup]  
enable_security_group = True  
firewall_driver =  
neutron.agent.linux.iptables_firewall.IptablesFirewallDriver  
[vxlan]  
enable_vxlan = True  
local_ip = 192.168.237.129  
l2_population = True
```  
* ***NOTE: LƯU Ý THAY ĐỔI IP VÀ TÊN INTERFACE***
### Cấu hình `Layer 3 Agent`
- Sao lưu file `/etc/neutron/l3_agent.ini` gốc

```sh
cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.orig
```  
Sửa file như sau:
```
root@controller:~# cat /etc/neutron/l3_agent.ini  
[DEFAULT]  
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver  
[AGENT]
```  

### Cấu hình `DHCP Agent`
 - Sao lưu file ` /etc/neutron/dhcp_agent.ini` gốc
	```sh
	cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.orig
	```

- Trong section `[DEFAULT]` khai báo mới hoặc sửa thành dòng dưới
	```sh
	interface_driver = linuxbridge
	dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
	enable_isolated_metadata = True
	```
- **TỔNG KẾT LẠI NHƯ SAU:**
```
root@controller:~# cat /etc/neutron/dhcp_agent.ini  
[DEFAULT]  
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver  
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq  
enable_isolated_metadata = True  
[AGENT]
```  

### Cấu hình `metadata agent`
 - Sao lưu file `/etc/neutron/metadata_agent.ini` 
	```sh
	cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.orig
	```
- Sửa file `vi /etc/neutron/metadata_agent.ini`
	- Trong section `[DEFAULT]` khai báo mới hoặc sửa thành dòng dưới
	```sh
	nova_metadata_ip = controller
	metadata_proxy_shared_secret = Welcome123
	```
### Sửa trong file `/etc/nova/nova.conf`
- Trong section `[neutron]` khai báo mới hoặc sửa thành dòng dưới (thêm section `[neutron]`):
	```sh
	[neutron]
	url = http://controller:9696
	auth_url = http://controller:35357
	auth_type = password
	project_domain_name = default
	user_domain_name = default
	region_name = RegionOne
	project_name = service
	username = neutron
	password = lxcpassword
	service_metadata_proxy = true
	metadata_proxy_shared_secret = lxcpassword
	```
- TỔNG KẾT LẠI NHƯ SAU:
```
root@controller:~# cat /etc/nova/nova.conf  
[DEFAULT]  
dhcpbridge_flagfile=/etc/nova/nova.conf  
dhcpbridge=/usr/bin/nova-dhcpbridge  
log-dir=/var/log/nova  
state_path=/var/lib/nova  
force_dhcp_release=True  
verbose=True  
ec2_private_dns_show_ip=True  
enabled_apis=osapi_compute,metadata  
transport_url = rabbit://openstack:lxcpassword@controller  
auth_strategy = keystone  
my_ip = 192.168.237.129  
use_neutron = True  
firewall_driver = nova.virt.firewall.NoopFirewallDriver  
compute_driver = libvirt.LibvirtDriver  
scheduler_default_filters = RetryFilter, AvailabilityZoneFilter, RamFilter, ComputeFilter, ComputeCapabilitiesFilter,ImagePropertiesFilter, ServerGroupAntiAffinityFilter, ServerGroupAffinityFilter  
[database]  
connection = mysql+pymysql://nova:lxcpassword@controller/nova  
[api_database]  
connection = mysql+pymysql://nova:lxcpassword@controller/nova_api  
[oslo_concurrency]  
lock_path = /var/lib/nova/tmp  
[libvirt]  
use_virtio_for_bridges=True  
[wsgi]  
api_paste_config=/etc/nova/api-paste.ini  
[keystone_authtoken]  
auth_uri = http://controller:5000  
auth_url = http://controller:35357  
memcached_servers = controller:11211  
auth_type = password  
project_domain_name = default  
user_domain_name = default  
project_name = service  
username = nova  
password = lxcpassword  
[vnc]  
enabled = True  
vncserver_listen = $my_ip  
vncserver_proxyclient_address = $my_ip  
novncproxy_base_url = http://controller:6080/vnc_auto.html  
[glance]  
api_servers = http://controller:9292  
[libvirt]  
virt_type = kvm  
[neutron]  
url = http://controller:9696  
auth_url = http://controller:35357  
auth_type = password  
project_domain_name = default  
user_domain_name = default  
region_name = RegionOne  
project_name = service  
username = neutron  
password = lxcpassword  
service_metadata_proxy = True  
metadata_proxy_shared_secret = lxcpassword
```  

### Kết thúc quá trình cài đặt `neutron` trên `controller` 
- Đồng bộ database cho `neutron`
	```sh
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
	```

- Khởi động lại `nova-api`
	```sh
	service nova-api restart
	```
- Khởi động lại các dịch vụ của `neutron`
```sh
root@controller:~# service neutron-server restart  
root@controller:~# service neutron-linuxbridge-agent restart  
root@controller:~# service neutron-dhcp-agent restart  
root@controller:~# service neutron-metadata-agent restart  
root@controller:~# service neutron-l3-agent restart 
root@controller:~# service nova-compute restart
```

- Kiểm tra lại hoạt động của các dịch vụ trong `neutron`
	- Khai báo biến môi trường: `. rc.admin`
	
```sh
openstack network agent list
```  
<img src = "../Images/II.4.1. Cài đặt Neutron/4.png">  


## 2. Tạo network mới trong Neutron
### Tạo network tên là `nat`
	- ```root@controller:~# openstack network create nat```
<img src = "../Images/II.4.1. Cài đặt Neutron/5.png">  

<img src = "../Images/II.4.1. Cài đặt Neutron/6.png">   


### Cấu hình cho network tên `nat`
- Cấu hình dns, giải subnet,...
	- ```root@controller:~# openstack subnet create --network nat --dns-nameserver 8.8.8.8 --gateway 192.168.0.1 --subnet-range 192.168.0.0/24 nat```  

<img src = "../Images/II.4.1. Cài đặt Neutron/7.png">  

<img src = "../Images/II.4.1. Cài đặt Neutron/8.png">  

- Cập nhật (update) thông tin subnet trong Neutron
	- ```root@controller:~# neutron net-update nat --router:external```  
<img src = "../Images/II.4.1. Cài đặt Neutron/9.png">  

### Tạo software router mới
- Tạo software router:
``` root@controller:~# openstack router create router```  
<img src = "../Images/II.4.1. Cài đặt Neutron/10.png">  

-  Add subnet chúng ta vừa tạo lúc nãy vào router thành 1 interface  
```
root@controller:~# . rc.admin  
root@controller:~# neutron router-interface-add router nat
```  
<img src = "../Images/II.4.1. Cài đặt Neutron/11.png">  

### Hiển thị danh sách port trên software router
```
root@controller:~# neutron router-port-list router
```  
<img src = "../Images/II.4.1. Cài đặt Neutron/12.png">  

- Hiển thị danh sách Neutron Network
```
root@controller:~# openstack network list
```  
<img src = "../Images/II.4.1. Cài đặt Neutron/13.png">  


# Một số lỗi
- Nếu lúc start up báo lỗi Neutron Linux bridge cleanup fails tức là do đang dùng dhcp nên neutron chưa nhận được ip. cách khắc phục là đặt ip tĩnh cho máy.  
> [https://ask.openstack.org/en/question/103199/neutron-linux-bridge-cleanup-fails-on-host-startup/](https://ask.openstack.org/en/question/103199/neutron-linux-bridge-cleanup-fails-on-host-startup/)


