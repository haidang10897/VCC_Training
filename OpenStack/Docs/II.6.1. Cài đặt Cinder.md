# Cài đặt Cinder
# I. Cài đặt và cấu hình trên Controller node
## I.1. Chuẩn bị
- **Tạo database**
	- Đăng nhập database
		```sh
		mysql -u root -pdang
		```  
	- Tạo database cinder
		```sh
		MariaDB [(none)]> CREATE DATABASE cinder;
		```  
	- Gán quyền truy cập vào database `cinder`, nhớ thay pass
		```sh
		MariaDB [(none)]> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' \
		 IDENTIFIED BY 'dang';
		MariaDB [(none)]> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' \
		 IDENTIFIED BY 'dang';
		```  
	- Thoát database
		```sh
		MariaDB [(none)]> exit
		```  
<img src = "../Images/II.6.1. Cài đặt Cinder/3.png">  

- Truy cập Openstack với tư cách admin
	```sh
	$ . admin-openrc
	```  
- **Tạo các chứng chỉ dịch vụ**
	- Tạo user `cinder`
		```sh
		$ openstack user create --domain default --password-prompt cinder
		```  
		<img src = "../Images/II.6.1. Cài đặt Cinder/4.png">  
	- Gán role `admin` vào user `cinder`
		```sh
		$ openstack role add --project service --user cinder admin
		```  
	- Tạo dịch vụ `cinderv2` và `cinderv3`
		- **LƯU Ý BLOCK STORAGE CẦN 2 THỰC THỂ DỊCH VỤ**
		```sh
		$ openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2

		$ openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3
		```  
		<img src = "../Images/II.6.1. Cài đặt Cinder/5.png">  
	- Tạo các API Endpoint cho `Block Storage`
		```sh
		$ openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(project_id\)s

		$ openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(project_id\)s

		$ openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(project_id\)s
		```  
		<img src = "../Images/II.6.1. Cài đặt Cinder/6.png">  
		<br>
		<img src = "../Images/II.6.1. Cài đặt Cinder/7.png">  
		<br>
		<img src = "../Images/II.6.1. Cài đặt Cinder/8.png">  

		```sh
		$ openstack endpoint create --region RegionOne volumev3 public http://controller:8776/v3/%\(project_id\)s

		$ openstack endpoint create --region RegionOne volumev3 internal http://controller:8776/v3/%\(project_id\)s

		$ openstack endpoint create --region RegionOne volumev3 admin http://controller:8776/v3/%\(project_id\)s
		```  
		<img src = "../Images/II.6.1. Cài đặt Cinder/9.png">  
		<br>
		<img src = "../Images/II.6.1. Cài đặt Cinder/10.png">  
		<br>
		<img src = "../Images/II.6.1. Cài đặt Cinder/11.png">  

## I.2. Cài đặt và cấu hình
- Cài đặt các gói
	```sh
	# apt install cinder-api cinder-scheduler
	```  
- Sửa file `/etc/cinder/cinder.conf`
	- Trong mục `[database]`, cấu hình truy cập đến database, nhớ thay pass
		```sh
		[database]
		# ...
		connection = mysql+pymysql://cinder:dang@controller/cinder
		```  
	- Trong mục `[DEFAULT]`, cấu hình truy cập đến `RabbitMQ message queue`, nhớ thay pass
		```sh
		[DEFAULT]
		# ...
		transport_url = rabbit://openstack:dang@controller
		```  

	- Trong mục `[DEFAULT]` và `[keystone_authtoken]`, cấu hình truy cập dịch vụ định danh
		```sh
		[DEFAULT]
		# ...
		auth_strategy = keystone

		[keystone_authtoken]
		# ...
		www_authenticate_uri = http://controller:5000
		auth_url = http://controller:5000
		memcached_servers = controller:11211
		auth_type = password
		project_domain_name = default
		user_domain_name = default
		project_name = service
		username = cinder
		password = dang
		```  
	- Trong mục `[DEFAULT]`, cấu hình `my_ip`
		```sh
		[DEFAULT]
		# ...
		my_ip = 10.0.0.11
		```  
	- Trong mục `[oslo_concurrency]`, cấu hình lock_path
		```sh
		[oslo_concurrency]
		# ...
		lock_path = /var/lib/cinder/tmp
		```  
- **Đồng bộ database**
	```sh
	# su -s /bin/sh -c "cinder-manage db sync" cinder
	```  

## I.3. Cấu hình Compute để dùng Block Storage

- **Sửa file `/etc/nova/nova.conf`, thêm như sau:**
	```sh
	[cinder]
	os_region_name = RegionOne
	```  

## I.4. Kết thúc cài đặt
- **Restart Compute API**
	```sh
	# service nova-api restart
	```  
- **Restart dịch vụ Block Storage**
	```sh
	# service cinder-scheduler restart
	# service apache2 restart
	```  
# II. Cài đặt và cấu hình trên Storage node
## II.1. Chuẩn bị
- **Sửa file `/etc/hosts` và `netplan`**
	<img src = "../Images/II.6.1. Cài đặt Cinder/1.png">  
	<img src = "../Images/II.6.1. Cài đặt Cinder/2.png">  
- **Cài đặt các gói** 
	```sh
	# apt install lvm2 thin-provisioning-tools
	```  
	<img src = "../Images/II.6.1. Cài đặt Cinder/12.png">  
- **Tạo LVM physical Volume /dev/sdb**
	```sh
	# pvcreate /dev/sdb

	Physical volume "/dev/sdb" successfully created
	```  
- **Tạo volume group**
	```sh
	# vgcreate cinder-volumes /dev/sdb

	Volume group "cinder-volumes" successfully created
	```  
	- **Cinder sẽ tự tạo logical volume trong này**

	<img src = "../Images/II.6.1. Cài đặt Cinder/13.png">  
	
- **Cấu hình chỉ cho phép instance có quyền truy cập Block Storage volume**
	```sh
	devices {
	...
	filter = [ "a/sdb/", "r/.*/"]
	```  
## II.2. Cài đặt và cấu hình
- **Cài đặt gói**
	```sh
	# apt install cinder-volume
	```  
- **Sửa file `/etc/cinder/cinder.conf`**
	- Trong mục `[database]`, cấu hình truy cập đến database:
		```sh
		[database]
		# ...
		connection = mysql+pymysql://cinder:dang@controller/cinder
		```  
	- Trong mục `[DEFAULT]`, cấu hình truy cập đến `RabbitMQ message queue`, nhớ thay pass
		```sh
		[DEFAULT]
		# ...
		transport_url = rabbit://openstack:dang@controller
		```  

	- Trong mục `[DEFAULT]` và `[keystone_authtoken]`, cấu hình truy cập dịch vụ định danh
		```sh
		[DEFAULT]
		# ...
		auth_strategy = keystone

		[keystone_authtoken]
		# ...
		www_authenticate_uri = http://controller:5000
		auth_url = http://controller:5000
		memcached_servers = controller:11211
		auth_type = password
		project_domain_name = default
		user_domain_name = default
		project_name = service
		username = cinder
		password = dang
		```  
	- Trong mục `[DEFAULT]`, cấu hình `my_ip`
		```sh
		[DEFAULT]
		# ...
		my_ip = 10.0.0.41
		```  
	- Trong mục `[lvm]`, cấu hình lvm backend với lvm driver
		```sh
		[lvm]
		# ...
		volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
		volume_group = cinder-volumes
		target_protocol = iscsi
		target_helper = tgtadm
		```  
		
	- Trong mục `DEFAULT`, kích hoạt lvm backend, thêm ví trí `Image service API`
		```sh
		[DEFAULT]
		# ...
		enabled_backends = lvm
		```  
		```sh
		[DEFAULT]
		# ...
		glance_api_servers = http://controller:9292
		```

	- Trong `[oslo_concurrency]`, cấu hình lock_path
		```sh
		[oslo_concurrency]
		# ...
		lock_path = /var/lib/cinder/tmp
		```  
## II.3. Kết thúc cài đặt
- **Khởi động lại các dịch vụ**
	```sh
	# service tgt restart
	# service cinder-volume restart
	```  

# III. Kiểm tra vận hành
- **Xem trạng thái các dịch vụ**
	```sh
	$ openstack volume service list
	```  
<img src = "../Images/II.6.1. Cài đặt Cinder/14.png">  

