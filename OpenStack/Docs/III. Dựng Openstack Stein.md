# Mục lục
I. Chuẩn bị môi trường
I.1. Chuẩn bị môi trường mạng
I.2. Cài đặt chung cơ bản
II. Cài đặt các dịch vụ của Openstack
II.1. Keystone
II.2. Glance
II.3. Placement
II.4. Nova
II.5. Neutron
II.6. Horizon
III. Khởi tạo và chạy Instance






# I. Chuẩn bị môi trường
## I.1. Chuẩn bị môi trường mạng 

### I.1.1. Mô hình mạng
<img src = "../Images/III. Dựng Openstack Stein/Overview/1.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/2.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/5.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/6.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/3.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/4.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/7.png">  

### I.1.2. Thiết lập VMWARE

-   Tiến hành cài đặt trên hệ điều hành  **Ubuntu Server 18.04 64bit**.
    
-   Các nodes đều là máy ảo chạy trên VMware Workstation
    
-   Node controller và compute đều có các card mạng như sau

<img src = "../Images/III. Dựng Openstack Stein/Overview/8.png">  

-   NIC 1 (NAT): có dải địa chỉ  `10.0.0.0/24`
	- Đây là mạng quản lý (management network) theo như sơ đồ bên trên.
	- Dải mạng này đi qua NAT nên chúng ta chọn NAT trong VMWARE và để dải địa chỉ NAT là như trên.
-   NIC 2 (Bridge): có dải địa chỉ  `192.168.1.0/24`
	- Đây là dải mạng dùng để cung cấp dịch vụ (Provider Network)
	- Dải mạng này gắn trực tiếp cùng dải mạng mà nhà mạng cung cấp nên để dải mạng trên và trong VMWARE đặt là Bridge
	- Lưu ý: Do làm ở nhà nên dải mạng sau modem của FPT cung cấp nó là 192.168.1.0/24 và gateway là 192.168.1.1. 

## I.2. Cài đặt chung cơ bản
## I.2.1. Thiết lập IP và DNS
### I.2.1.1. Thiết lập IP và DNS trên Controller
- **Đặt địa chỉ IP:**
	- Vào `/etc/netplan/` chỉnh sửa như sau:
	- ```sh ens33:				
      ens33
	      dhcp4: no
	      dhcp6: no
	      addresses: [10.0.0.11/24, ]
	      gateway4:  10.0.0.1
	      nameservers:
              addresses: [10.0.0.1]
        ```
	- `netplan apply` (nếu cần thiết reset lại service mạng)

- **Phân giải tên miền**
	- Vào /etc/hosts chỉnh sửa như sau:
	```sh 
	10.0.0.11	controller
	10.0.0.31	compute
	```

### I.2.1.2. Thiết lập IP và DNS trên Compute
- **Đặt địa chỉ IP:**
	- Vào `/etc/netplan/` chỉnh sửa như sau:
	- ```sh ens33:				
      ens33
	      dhcp4: no
	      dhcp6: no
	      addresses: [10.0.0.31/24, ]
	      gateway4:  10.0.0.1
	      nameservers:
              addresses: [10.0.0.1]
        ```
	- `netplan apply` (nếu cần thiết reset lại service mạng)

- **Phân giải tên miền**
	- Vào /etc/hosts chỉnh sửa như sau:
	```sh 
	10.0.0.11	controller
	10.0.0.31	compute
	```
### I.2.1.3. Test kết nối
- **Thử ping từ controller sang compute và ngược lại**

- **Ở 2 node, thử ping ra mạng bên ngoài (google.com)**


## I.2.2. Network Time Protocol (NTP)
### I.2.2.1. Cài đặt NTP trên Controller node
 
- **Cài đặt gói**
	```sh
	apt install chrony
	```

- **Sửa file `/etc/chrony/chrony.conf` , thêm dòng sau:**
	```sh
	allow 10.0.0.0/24
	```  

- **Restart dịch vụ**
	```sh
	service chrony restart
	```  


### I.2.2.2. Cài đặt NTP trên Compute node

- **Cài đặt gói**
	```sh
	apt install chrony
	```

- **Sửa file `/etc/chrony/chrony.conf` , thêm dòng sau:**
	```sh
	server controller iburst
	```  
- **Restart dịch vụ**
	```sh
	service chrony restart
	```  

## I.2.3. Cài đặt Ubuntu Package
***Note: Cài đặt chung trên tất cả các node**

### I.2.3.1. Enable the repository for Ubuntu Cloud Archive. 

- **OpenStack Stein for Ubuntu 18.04 LTS:**
	```sh
	add-apt-repository cloud-archive:stein
	```  

### I.2.3.2. Kết thúc quá trình cài đặt
- **Update ubuntu**
	```sh
	apt update && apt dist-upgrade
	```  

- **Cài đặt OpenStack client:**
	```sh
	apt install python3-openstackclient
	```  

## I.2.4. Cài đặt SQL database
**Note: Cài đặt trên Controller node**

### I.2.4.1. Cài đặt và config
- **Cài đặt gói:**
	```sh
	apt install mariadb-server python-pymysql
	```  

- **Tạo và sửa file `/etc/mysql/mariadb.conf.d/99-openstack.cnf` như sau:**
	- Bind-address thay bằng IP của controller node, còn lại giữ nguyên.
		```sh
		[mysqld]
		bind-address = 10.0.0.11

		default-storage-engine = innodb
		innodb_file_per_table = on
		max_connections = 4096
		collation-server = utf8_general_ci
		character-set-server = utf8
		```  

### I.2.4.2. Kết thúc quá trình cài đặt
- **Restart dịch vụ mysql:**
	```sh
	service mysql restart
	```  
- **Cấu hình tài khoản root mysql:**
	```sh
	mysql_secure_installation
	```  

## I.2.5. Message queue
* **Note: Cấu hình trên Controller node**
### I.2.5.1. Cài đặt và cấu hình
- **Cài đặt gói:**
	```sh
	apt install rabbitmq-server
	```  

- **Add thêm `openstack` user:**
	- Thay password tuỳ chọn, ở đây là `dang`
		```sh
		# rabbitmqctl add_user openstack dang

		Creating user "openstack" ...
		```  

- **Set quyền config, write, read cho user `openstack`:**
	```sh
	# rabbitmqctl set_permissions openstack ".*" ".*" ".*"

	Setting permissions for user "openstack" in vhost "/" ...
	```   

## I.2.6. Memcache
* **Note: Cấu hình trên Controller node**
### I.2.6.1. Cài đặt và cấu hình
- **Cài đặt gói:**
	```sh
	apt install memcached python-memcache
	```  

- **Sửa file `/etc/memcached.conf`:**
	- Sửa dòng `-l 127.0.0.1` thành IP của controller node như sau:
		```sh
		-l 10.0.0.11
		```  

### I.2.6.2. Kết thúc cài đặt
- **Khởi động lại dịch vụ:**
	```sh
	service memcached restart
	```  

## I.2.7. Etcd
* **Note: Cấu hình trên Controller node**
### I.2.7.1. Cài đặt và cấu hình
- **Cài đặt gói:**
	```sh
	apt install etcd
	```  

- **Sửa file ``/etc/default/etcd`` như sau:**
	- Thay các dòng 10.0.0.11 bằng địa chỉ IP controller node
	```sh
	ETCD_NAME="controller"
	ETCD_DATA_DIR="/var/lib/etcd"
	ETCD_INITIAL_CLUSTER_STATE="new"
	ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
	ETCD_INITIAL_CLUSTER="controller=http://10.0.0.11:2380"
	ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.11:2380"
	ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.11:2379"
	ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
	ETCD_LISTEN_CLIENT_URLS="http://10.0.0.11:2379"
	```   
### I.2.7.2. Kết thúc cài đặt
- **Restart và enable dịch vụ:**
	```sh
	# systemctl enable etcd
	# systemctl restart etcd
	```  

# II. Cài đặt các dịch vụ của Openstack Stein
## II.1. Identity service - Keystone
## II.1.1. Cài đặt và cấu hình
### II.1.1.1. Chuẩn bị
- **Đăng nhập mysql với quyền root:**
	```sh
	mysql -u root -pdang
	```  
- **Tạo database có tên `keystone`:**
	```sh
	MariaDB [(none)]> CREATE DATABASE keystone;
	```  

- **Gán quyền truy cập cho database keystone:** 
	```sh
	GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'dang';
	GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'dang';
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone1.png">  


### II.1.1.2. Cài đặt và cấu hình
- Cài đặt Keystone package:
	```sh
	apt install keystone
	```  

- Chỉnh sửa file `/etc/keystone/keystone.conf`
	- Trong mục `[database]` thêm dòng sau, nhớ thay pass thích hợp và comment mọi dòng còn lại:

		```sh
		[database]
		# ...
		connection = mysql+pymysql://keystone:dang@controller/keystone
		```  
	- Trong mục `[section]`, cấu hình cung cấp token là `fernet`:
		```sh
		[token]
		# ...
		provider = fernet
		```  

- Đồng bộ database của dịch vụ định danh `keystone`:
	```sh
	# su -s /bin/sh -c "keystone-manage db_sync" keystone
	```  

- Cấu hình key repository của `fernet`:
	```sh
	# keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
	# keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
	```  

- Bootsrap `Keystone`, nhớ thay password:
	```sh
	# keystone-manage bootstrap --bootstrap-password dang --bootstrap-admin-url http://controller:5000/v3/ --bootstrap-internal-url http://controller:5000/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne
	```  

### II.1.1.3. Cấu hình Apache HTTP server
- Chỉnh sửa file `/etc/apache2/apache2.conf` như sau:
	```sh
	ServerName controller
	```  

### II.1.1.4. SSL
- Đây là cấu hình tuỳ chọn để thiết lập giao thức an toàn kết nối đến web server. Bài này sẽ không có.

### II.1.1.5. Kết thúc cài đặt
- Khởi động lại dịch vụ apache:
	```sh
	# service apache2 restart
	```  

- Cấu hình tài khoản admin bằng cách set biến môi trường, nhớ thay tài khoản bằng tài khoản trong keystone-manage:
	```sh
	export OS_USERNAME=admin
	export OS_PASSWORD=dang
	export OS_PROJECT_NAME=admin
	export OS_USER_DOMAIN_NAME=Default
	export OS_PROJECT_DOMAIN_NAME=Default
	export OS_AUTH_URL=http://controller:5000/v3
	export OS_IDENTITY_API_VERSION=3
	```  
	
## II.1.2. Tạo domain, projects, user, và role
### II.1.2.1. Tạo domain
- **Tạo domain tên `example` bằng lệnh sau, đây cũng chính là lệnh để tạo domain mới:**
	```sh
	openstack domain create --description "An Example Domain" example
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone2.png">  

***NOTE: Trên là domain để ví dụ, bài này sẽ dùng domain default đã được tạo trước rồi.***

### II.1.2.2. Tạo project
- Xuyên suốt bài này, ta sẽ dùng project tên `service` để làm thực hành. Tạo bằng lệnh sau:
	 ```sh
	$ openstack project create --domain default --description "Service Project" service
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone3.png">  

### II.1.2.3. Tạo user, role
Dưới đây là ví dụ về tạo user, tạo roles và gán vào user với project:
- Tạo project `myproject`:
	```sh
	$ openstack project create --domain default --description "Demo Project" myproject
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone4.png">  

- Tạo user `myuser`:
	```sh
	$ openstack user create --domain default --password-prompt myuser
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone5.png">  

- Tạo role `myroles`:
	```sh
	openstack role create myrole
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone6.png">  

- Add role `myrole` vào user `myuser` và project `myproject`:
	```sh
	openstack role add --project myproject --user myuser myrole
	```  

## II.1.3. Kiểm tra vận hành
- Unset biến môi trường
	```sh
	unset OS_AUTH_URL OS_PASSWORD
	```  

- Lấy token với tư cách là user `admin`
	```sh
	openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name admin --os-username admin token issue
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone7.png">  

- Lấy token vơi tư cách là user `myuser`:
	```sh
	openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name myproject --os-username myuser token issue
	```  
<img src = "../Images/III. Dựng Openstack Stein/Keystone/keystone8.png">  

## II.1.4. Tạo file chứa biến môi trường
### II.1.4.1. Tạo script
- Tạo file `admin-openrc` chứa nội dung sau:
	```sh
	export OS_USERNAME=admin
	export OS_PASSWORD=dang
	export OS_PROJECT_NAME=admin
	export OS_USER_DOMAIN_NAME=Default
	export OS_PROJECT_DOMAIN_NAME=Default
	export OS_AUTH_URL=http://controller:5000/v3
	export OS_IDENTITY_API_VERSION=3
	```  

### II.1.4.2. Dùng script
- Load file `admin-openrc`:
	```sh
	#. admin-openrc
	```  

- Xem token:
	```sh
	$ openstack token issue
	```  

## II.2. Image Service - Glance
## II.2.1. Cài đặt và cấu hình
### II.2.1.1. Chuẩn bị
- **Đăng nhập Mysql với quyền root**
	```sh
	mysql -u root -pdang
	```  

- **Tạo database có tên `glance`**
	```sh
	MariaDB [(none)]> CREATE DATABASE glance;
	```  

- **Gán quyền access cho database `glance`. NHỚ THAY PASSWORD**
	```sh
	MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'dang';
	MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'dang';
	```  

- **Load file `admin-openrc` để lấy quyền admin**
	```sh
	$ . admin-openrc
	```  
- **Tạo user `glance`**
	```sh
	$ openstack user create --domain default --password-prompt glance
	```  
	<img src = "../Images/III. Dựng Openstack Stein/Glance/glance1.png">   

- **Thêm role `admin` cho user `glance` và project `service`**  
	```sh
	$ openstack role add --project service --user glance admin
	```  
- **Tạo service `glance`**
	```sh
	$ openstack service create --name glance --description "OpenStack Image" image
	```  
	<img src = "../Images/III. Dựng Openstack Stein/Glance/glance2.png">   
	
- **Tạo các Endpoint cho service `glance`**
	```sh
	$ openstack endpoint create --region RegionOne image public http://controller:9292
	$ openstack endpoint create --region RegionOne image internal http://controller:9292
	$ openstack endpoint create --region RegionOne image admin http://controller:9292
	```  
<img src = "../Images/III. Dựng Openstack Stein/Glance/glance3.png">   

<img src = "../Images/III. Dựng Openstack Stein/Glance/glance4.png">   

<img src = "../Images/III. Dựng Openstack Stein/Glance/glance5.png">   

### II.2.1.2. Cài đặt và cấu hình
- **Cài đặt Glance package**
```sh
# apt install glance
```  

- **Sửa file `/etc/glance/glance-api.conf`**
	- *Trong mục `[database]`, cấu hình truy cập đến database. NHỚ THAY PASS*
		```sh
		[database]
		# ...
		connection = connection = mysql+pymysql://glance:dang@controller/glance
		```  

	- *Trong mục `[keystone_authtoken]` và `[paste_deploy]`, cấu hình truy cập dịnh vụ định danh keystone. NHỚ THAY PASS*
		```sh
		[keystone_authtoken]
		# ...
		www_authenticate_uri = http://controller:5000
		auth_url = http://controller:5000
		memcached_servers = controller:11211
		auth_type = password
		project_domain_name = Default
		user_domain_name = Default
		project_name = service
		username = glance
		password = dang

		[paste_deploy]
		# ...
		flavor = keystone
		```  
	-	*Trong mục`[glance_store]`, cấu hình vị trí lưu trữ image*
		```sh
		[glance_store]
		# ...
		stores = file,http
		default_store = file
		filesystem_store_datadir = /var/lib/glance/images/
		```  

- **Sửa file `/etc/glance/glance-registry.conf`**
	- *Trong mục `[database]`, cấu hình truy cập đến database. NHỚ THAY PASS*
		```sh
		[database]
		# ...
		connection = mysql+pymysql://glance:dang@controller/glance
		```  

	-	*Trong mục `[keystone_authtoken]` và `[paste_deploy]`, cấu hình truy cập dịch vụ định danh. Nhớ thay pass là pass truy cập vào dịnh vụ định danh keystone của user `glance`. Comment tất cả dòng cấu hình khác*
		```sh
		[keystone_authtoken]
		# ...
		www_authenticate_uri = http://controller:5000
		auth_url = http://controller:5000
		memcached_servers = controller:11211
		auth_type = password
		project_domain_name = Default
		user_domain_name = Default
		project_name = service
		username = glance
		password = dang

		[paste_deploy]
		# ...
		flavor = keystone
		```  
- **Đồng bộ database dịch vụ Image - Glance**
	```sh
	# su -s /bin/sh -c "glance-manage db_sync" glance
	```  
### II.2.1.3. Kết thúc cài đặt
- **Khởi động lại dịch vụ Image**
	```sh
	# service glance-registry restart
	# service glance-api restart
	```  

## II.2.2. Kiểm tra vận hành
- Truy cập Openstack với tư cách admin
	```sh
	$ . admin-openrc
	```  
- Download file image
	```sh
	$ wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
	```  
- Upload image vào dịch vụ Image Glance với disk format là `qcow2`, `bare container format`, và `public` để tất cả các project có thể nhìn thấy.
	```sh
	$ openstack image create "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public
	```  
	<img src = "../Images/III. Dựng Openstack Stein/Glance/glance6.png">   

- Xem list image để biết đã upload thành công chưa
	```sh
	$ openstack image list
	```  
	<img src = "../Images/III. Dựng Openstack Stein/Glance/glance7.png">   

# II.3. Dịch vụ Placement



