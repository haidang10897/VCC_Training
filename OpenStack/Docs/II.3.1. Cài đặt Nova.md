# I. Cài đặt dịch vụ `nova` trong OpenStack
***
- Đây là bước cài đặt các thành phần của `nova` trên máy chủ `Controller` . Lưu ý phải làm phần cài đặt keystone và glance trước.
- `nova` đảm nhiệm chức năng cung cấp và quản lý tài nguyên trong OpenStack để cấp cho các VM.

## 1. Tạo database, tạo dịch vụ credentials và API endpoint cho `nova`

- Tạo database:
	- Đăng nhập vào database với quyền `root`
	```sh
	mysql -u root -plxcpassword
	```

	- Tạo database nova_api, nova, và nova_cell0:
	```sh
	CREATE DATABASE nova_api;
	CREATE DATABASE nova;
	CREATE DATABASE nova_cell0;
	```
	- Cấp quyền truy cập database:
	```sh
	GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'lxcpassword';
	GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'lxcpassword';
	
	GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'lxcpassword';
	GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'lxcpassword';
	
	GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'lxcpassword';
	GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'lxcpassword';

	FLUSH PRIVILEGES;
	EXIT;
	```
	* NOTE: NHỚ TẠO DATABASE CELL0

- Khai báo biến môi trường
	```sh
	. rc.admin
	```

- Tạo user, phân quyền và dịch vụ `nova`:
	- Tạo user `nova` dùng lệnh sau và nhập mật khẩu cho user là `lxcpassword`:
		```sh
		openstack user create --domain default --password-prompt nova
		```
	
	- Thêm role `admin` cho user `nova`:
		```sh
		openstack role add --project service --user nova admin
		```

	- Tạo dịch vụ `nova`:
		```sh
		openstack service create --name nova --description "OpenStack Compute" compute
		```
<img src = "../Images/II.3.1. Cài đặt Nova/1.png">  


- Tạo các endpoint:
	```
	openstack endpoint create --region RegionOne compute public 'http://controller:8774/v2.1/%(tenant_id)s'
	```  
	```
	openstack endpoint create --region RegionOne compute internal 'http://controller:8774/v2.1/%(tenant_id)s'
	```  
	```
	openstack endpoint create --region RegionOne compute admin 'http://controller:8774/v2.1/%(tenant_id)s'
	```  

## 2. Cài đặt và cấu hình `nova`

- Cài đặt các gói:
	```sh
	apt-get -y install nova-api nova-conductor nova-consoleauth \
  	nova-novncproxy nova-scheduler nova-placement-api
	```

- Sao lưu file `/etc/nova/nova.conf` trước khi cấu hình

	```sh
	cp /etc/nova/nova.conf /etc/nova/nova.conf.orig
	```

- Sửa file `/etc/nova/nova.conf`. 
- Lưu ý: Trong trường hợp nếu có dòng khai bao trước đó thì tìm và thay thế, chưa có thì khai báo mới hoàn toàn. 
- Trong `[api_database]` và `[database]` sections, cấu hình truy cập database:
	- Tìm và thay thế. Trong `[database]` phải khai báo thêm.  
	```sh
	[api_database]
	# ...
	#connection=sqlite:////var/lib/nova/nova.sqlite
	connection = mysql+pymysql://nova:lxcpassword@controller/nova_api

	[database]
	# ...
	connection = mysql+pymysql://nova:lxcpassword@controller/nova
	```

- Trong `[DEFAULT]` section:
	```sh
	[DEFAULT]
	# ...
	use_neutron = True
	firewall_driver = nova.virt.firewall.NoopFirewallDriver
	my_ip = 192.168.237.129
	transport_url = rabbit://openstack:lxcpassword@controller
	```

- Trong  `[api]` và `[keystone_authtoken]`, cấu hình dịch vụ identity:
	```sh
	[api]
	# ...
	auth_strategy = keystone
	
	[keystone_authtoken]
	# ...
	auth_uri = http://controller:5000
	auth_url = http://controller:35357
	memcached_servers = controller:11211
	auth_type = password
	project_domain_name = default
	user_domain_name = default
	project_name = service
	username = nova
	password = lxcpassword
	```

- Trong `[vnc]`:
	```sh
	[vnc]
	enabled = true
	# ...
	vncserver_listen = $my_ip
	vncserver_proxyclient_address = $my_ip
	```

- Trong `[glance]`:
	```sh
	[glance]
	# ...
	api_servers = http://controller:9292
	```

- Trong `[oslo_concurrency]`:
	```sh
	[oslo_concurrency]
	# ...
	lock_path = /var/lib/nova/tmp
	```

- **TỔNG HỢP LẠI TA CÓ NHƯ SAU:**
```
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
vncserver_listen = $my_ip  
vncserver_proxyclient_address = $my_ip  
[glance]
```  
***Note: Nhớ sửa IP**



-  Tạo database cho `nova_api`
	```sh
	su -s /bin/sh -c "nova-manage api_db sync" nova
	```

- Đăng ký cell0 database:
	```sh
	su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
	```

- Create the cell1 cell:
	```sh
	su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
	```

- Tạo database cho `nova`
	```sh
	su -s /bin/sh -c "nova-manage db sync" nova
	```

- Kiểm tra lại nova cell0 và cell1 đã được đăng ký đúng hay chưa:
	```sh
	nova-manage cell_v2 list_cells
	```

	<img src = "../Images/II.3.1. Cài đặt Nova/2.png">  

## 3. Kết thúc bước cài đặt và cấu hình `nova`
- Khởi động lại các dịch vụ của `nova` sau khi cài đặt & cấu hình `nova`
	```sh
	service nova-api restart
	service nova-consoleauth restart
	service nova-scheduler restart
	service nova-conductor restart
	service nova-novncproxy restart 
	```  

- Cài đặt nova-compute
	```
	apt install nova-compute
	```  

- Sửa lại file /etc/nova/nova.conf
```sh
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
```  
*** NOTE: NHỚ SỬA IP**

- Sửa file /etc/nova/nova-compute.conf
```
[DEFAULT]  
compute_driver=libvirt.LibvirtDriver  
[libvirt]  
virt_type=kvm
```  
- Khởi động lại nova-compute
```
service nova-compute restart
```  
- Khai báo biến môi trường: `. rc.admin`
- Kiểm tra lại xem nova có hoạt động tốt hay không, thực hiện một số lệnh như trong các hình sau:
	-	```openstack compute service list```
	<img src = "../Images/II.3.1. Cài đặt Nova/3.png">  
	- **LƯU Ý: ĐOẠN NÀY NẾU STATE DOWN THÌ NHỚ ADD USER RABBITMQ.**
	- **LƯU Ý 2: NẾU CONSOLEAUTH DOWN THÌ THAY PASSWORD USER RABBITMQ**

	- ``` openstack catalog list```  
	<img src = "../Images/II.3.1. Cài đặt Nova/4.png">   

	- ``` openstack image list ```

		<img src = "../Images/II.3.1. Cài đặt Nova/5.png">   

	- Kiểm tra tiến trình ``` pgrep -lf nova | uniq -f1 ```

	- <img src = "../Images/II.3.1. Cài đặt Nova/6.png">   


