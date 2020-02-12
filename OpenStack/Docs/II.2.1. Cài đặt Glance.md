# Chuẩn bị
**Để làm được bài thực hành này thì phải làm phần "Cài Đặt Keystone" trước.**

`Glance`  là dịch vụ cung cấp các image (các hệ điều hành đã được đóng gói sẵn), các image này sử dụng để tạo ra các máy ảo. )

-   Lưu ý: Thư mục chứa các file images trong hướng dẫn này là  `/var/lib/glance/images/`

# I. Tạo database và endpoint cho `glance`


## 1. Tạo database cho `glance`

- Đăng nhập vào mysql
	```sh
	mysql -u root -plxcpassword
	```

- Tạo database và gán các quyền cho user `glance` trong database glance
```sh
	root@controller:~# mysql -u root -plxcpassword  
MariaDB [(none)]> CREATE DATABASE glance;  
Query OK, 1 row affected (0.00 sec)  
MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'lxcpassword';  
Query OK, 0 rows affected (0.00 sec)  
MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'lxcpassword';  
Query OK, 0 rows affected (0.00 sec)  
MariaDB [(none)]> exit  
Bye
```  

## 2. Cấu hình xác thực cho dịch vụ `glance`

- Khai báo biến môi trường `admin`: **. rc.admin** (Xem lại phần cuối bài thực hành Keystone)

- Tạo user `glance` nhập lệnh sau, sau đó nhập mật khẩu cho user glance là `lxcpassword`
	```sh
	openstack user create --domain default --password-prompt glance
	```

<img src = "../Images/II.2.1. Cài đặt Glance/1.png">  
	

- Thêm role `admin` cho user `glane` và project `service`
	```sh
	openstack role add --project service --user glance admin
	```

- Kiểm tra lại xem user `glance` có role là gì

    ```sh
    openstack role list --user glance --project service
    ```
<img src = "../Images/II.2.1. Cài đặt Glance/2.png">  

- Tạo dịch vụ có tên `glance`
```sh 
openstack service create --name glance --description  
"OpenStack Image" image
```
<img src = "../Images/II.2.1. Cài đặt Glance/3.png">  

- Tạo các endpoint cho dịch vụ `glance`
```
openstack endpoint create --region RegionOne image public http://controller:9292
```  

```
openstack endpoint create --region RegionOne image internal http://controller:9292
```  
```
openstack endpoint create --region RegionOne image admin http://controller:9292
```  
<img src = "../Images/II.2.1. Cài đặt Glance/4.png">  


# II. Cài đặt các gói và cấu hình cho dịch vụ `glance`

- Cài đặt gói `glance`
	```sh
	apt-get -y install glance
	```


- Sao lưu các file `/etc/glance/glance-api.conf` và file `/etc/glance/glance-registry.conf` trước khi cấu hình
	```sh
	cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.orig
	cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.orig
	```

- Sửa các mục dưới đây ở cả file `/etc/glance/glance-api.conf` và file `/etc/glance/glance-registry.conf`
	- Trong section `[DEFAULT]`  thêm hoặc tìm và thay thế dòng cũ bằng dòng dưới để cho phép chế độ ghi log với `glance`
	 ```sh
	 verbose = true
	 ```

	- Trong section `[database]` :
 
 	- Comment dòng 
	 ```sh
	 #sqlite_db = /var/lib/glance/glance.sqlite
	 ```
 	- Thêm dòng dưới 
	 ```sh
	 connection = mysql+pymysql://glance:lxcpassword@controller/glance
	 ```
	
	- Trong section `[keystone_authtoken]` và `[paste_deploy]`, cấu hình truy cập dịch vụ Identity:
	```sh
	[keystone_authtoken]
	# ...
	auth_uri = http://controller:5000
	auth_url = http://controller:35357
	memcached_servers = controller:11211
	auth_type = password
	project_domain_name = default
	user_domain_name = default
	project_name = service
	username = glance
	password = lxcpassword
	
	[paste_deploy]
	# ...
	flavor = keystone
	```

	- Trong section `[glance_store]`, cấu hình lưu trữ file hệ thống cục bộ (local file system store) và vị trí của file `image` (mục này không phải làm trong file `/etc/glance/glance-registry.conf`):
	```sh
	[glance_store]
	# ...
	stores = file,http
	default_store = file
	filesystem_store_datadir = /var/lib/glance/images/
	```


- Đồng bộ database cho glance
	```sh
	su -s /bin/sh -c "glance-manage db_sync" glance
	```

- Khởi động lại dịch vụ `Glance`
	```sh
	service glance-registry restart
	service glance-api restart
	```
	* Note: Nếu không có service tên glance-registry thì restart dịch vụ glances. Chắc ăn nhất thì tìm trong /etc/init.d các service liên quan đến glance rồi restart lại hết.
- **Nội dung file /etc/glance/glance-api.conf**
```sh
[DEFAULT]  
[cors]  
[cors.subdomain]  
[database]  
connection = mysql+pymysql://glance:lxcpassword@controller/glance  
[glance_store]  
stores = file,http  
default_store = file  
filesystem_store_datadir = /var/lib/glance/images/  
[image_format]  
disk_formats = ami,ari,aki,vhd,vhdx,vmdk,raw,qcow2,vdi,iso,root-tar  
[keystone_authtoken]  
auth_uri = http://controller:5000  
auth_url = http://controller:35357  
memcached_servers = controller:11211  
auth_type = password  
project_domain_name = default  
user_domain_name = default  
project_name = service  
username = glance  
password = lxcpassword  
[matchmaker_redis]  
[oslo_concurrency]  
[oslo_messaging_amqp]  
[oslo_messaging_notifications]  
[oslo_messaging_rabbit]  
[oslo_messaging_zmq]  
[oslo_middleware]  
[oslo_policy]  
[paste_deploy]  
flavor = keystone  
[profiler]  
[store_type_location_strategy]  
[task]  
[taskflow_executor]
```  
**- Nội dung file /etc/glance/glance-registry.conf**
```sh
[DEFAULT]  
[database]  
connection = mysql+pymysql://glance:lxcpassword@controller/glance  
[keystone_authtoken]  
auth_uri = http://controller:5000  
auth_url = http://controller:35357  
memcached_servers = controller:11211  
auth_type = password  
project_domain_name = default  
user_domain_name = default  
project_name = service  
username = glance  
password = lxcpassword  
[matchmaker_redis]  
[oslo_messaging_amqp]  
[oslo_messaging_notifications]  
[oslo_messaging_rabbit]  
[oslo_messaging_zmq]  
[oslo_policy]  
[paste_deploy]  
flavor = keystone  
[profiler]
```  

# III. Kiểm chứng lại việc cài đặt `glance`


- Khai báo biến môi trường cho dịch vụ `glance`
	```sh
	. rc.admin
	```

- Tải file image cho `glance`
	```sh
	wget https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img
	```

- Add file image vừa tải về
```sh
openstack image create "ubuntu_16.04" --file ubuntu-16.04-server-cloudimg-amd64-disk1.img --disk-format qcow2 --container-format bare --public
```

<img src = "../Images/II.2.1. Cài đặt Glance/5.png">  

- Kiểm tra lại image đã có hay chưa
	```sh
	openstack image list
	```

- Nếu kết quả lệnh trên hiển thị như bên dưới thì dịch vụ `glance` đã cài đặt thành công.

	<img src = "../Images/II.2.1. Cài đặt Glance/6.png">  
