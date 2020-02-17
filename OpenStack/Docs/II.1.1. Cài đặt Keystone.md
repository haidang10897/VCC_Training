# I. Chuẩn bị các thành phần
## 1. Cài đặt phần chung
- Chạy lệnh để cập nhật các gói phần mềm
```sh
	apt-get -y update
```  
- Cấu hình hostname
- Sửa file `/etc/hostname` với tên là `controller`

```sh
	controller
```

- Cập nhật file `/etc/hosts` để phân giải từ IP sang hostname và ngược lại, nội dung như sau

```sh
	127.0.0.1      localhost controller
	192.168.237.129    controller
```
<img src = "../Images/II.1.1. Cài đặt Keystone/1.png">  

 **LƯU Ý: PHẢI THAY HOSTNAME GIỐNG TÊN DOMAIN KHÔNG TẸO NỮA SẼ KHÔNG TÌM THẤY DOMAIN. TRONG BÀI NÀY THÌ ĐỊA CHỈ IP LÀ ĐỊA CHỈ IP CỦA CARD MẠNG MÁY ẢO LUÔN.**

## 2. Cài đặt repos để cài OpenStack Newton

- Cài đặt gói để cài OpenStack Newton
	```sh
	 apt-get install software-properties-common -y
	 add-apt-repository cloud-archive:newton -y
	```

- Cập nhật các gói phần mềm
	```sh
	apt-get -y update && apt-get -y dist-upgrade
	```

- Cài đặt các gói client của OpenStack
	```sh
	apt-get -y install python-openstackclient
	```

- Khởi động lại máy chủ
	```sh
	init 6
	```
	
## 3. Cài đặt SQL database

- Cài đặt MariaDB
	```sh
	apt-get -y install mariadb-server python-pymysql
	```

- Thiết lập mật khẩu cho tài khoản **root** (tài khoản root của mariadb)
	```sh
	mysql_secure_installation
	```

	- Ngay đoạn đầu tiên nó sẽ hỏi bạn nhập mật khẩu root hiện tại, nhưng chúng ta chưa có mật khẩu thì hãy Enter để bỏ qua, kế tiếp chọn gõ Y để bắt đầu thiết lập mật khẩu cho **root** và các tùy chọn sau vẫn Y hết.
	- Nhập mật khẩu root là: `lxcpassword`

- Cấu hình cho Mariadb, tạo file `/etc/mysql/mariadb.conf.d/99-openstack.cnf` với nội dung sau:
```sh
[mysqld]
bind-address = 192.168.237.129
default-storage-engine = innodb  
innodb_file_per_table  
max_connections = 4096  
collation-server = utf8_general_ci  
character-set-server = utf8
```  

**LƯU Ý ĐỂ IP LÀ IP CỦA DB SERVER, TRƯỜNG HỢP NÀY CÓ 1 MÁY NÊN LẤY LUÔN CHÍNH NÓ.**

- Khởi động lại MariaDB
	```sh
	service mysql restart
	```

- Đăng nhập bằng tài khoản `root` vào `MariaDB` để kiểm tra lại. Sau đó gõ lệnh `exit` để thoát.
	```sh
	root@controller:~# mysql -u root -p
	```
	
	- Nhập mật khẩu `lxcpassword`
<img src = "../Images/II.1.1. Cài đặt Keystone/2.png">  


## 4. Cài đặt RabbitMQ
## Giới thiệu

```
Trong Openstack, RabbitMQ sẽ nhận message đến từ các thành phần khác nhau trong hệ thống, lưu trữ chúng an toàn trước khi đẩy đến đích.
```  
> [https://techblog.vn/tim-hieu-rabbitmq-phan-1](https://techblog.vn/tim-hieu-rabbitmq-phan-1)


## Cài đặt
- Cài đặt gói
	```sh
	apt-get -y install rabbitmq-server
	```

- Cấu hình RabbitMQ, tạo user `openstack` với mật khẩu là `lxcpassword`
	```sh
	rabbitmqctl add_user openstack lxcpassword
	```

- Gán quyền read, write cho tài khoản `openstack` trong `RabbitMQ`
	```sh
	rabbitmqctl set_permissions openstack ".*" ".*" ".*"
	```

## 5. Cài đặt Memcached
- Cài đặt các gói cần thiết cho `memcached`
	```sh
	apt-get -y install memcached python-memcache
	```

- Sửa file `/etc/memcached.conf`, thay dòng `-l 127.0.0.1` bằng dòng dưới.

	```sh
	-l 192.168.237.129
	```

- Khởi động lại `memcache`
	```sh
	service memcached restart
	```

# II. Cài đặt và cấu hình Keystone

## 1. Tạo database cài đặt các gói và cấu hình keystone
- Đăng nhập vào MariaDB

	```sh
	mysql -u root -plxcpassword
	```
- Tạo user, database cho keystone

```sh
	root@controller:~# mysql -u root -plxcpassword  
MariaDB [(none)]> CREATE DATABASE keystone;  
Query OK, 1 row affected (0.01 sec)  
MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO  
'keystone'@'localhost' IDENTIFIED BY 'lxcpassword';  
Query OK, 0 rows affected (0.00 sec)  
MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO  
'keystone'@'%' IDENTIFIED BY 'lxcpassword';  
Query OK, 0 rows affected (0.01 sec)  
MariaDB [(none)]> exit
```  

## 2. Cài đặt và cấu hình keystone
- Cài đặt gói keystone
	```sh
	apt-get -y install keystone
	```
- Sao lưu file cấu hình của dịch vụ keystone trước khi chỉnh sửa.

	```sh
	cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.orig
	```

- Dùng lệnh `vi` để mở và sửa file `/etc/keystone/keystone.conf`.
	- Trong section `[database]` thêm dòng dưới
		```sh
		connection = mysql+pymysql://keystone:lxcpassword@controller/keystone
		```

	- Trong section `[token]`, cấu hình Fernet token provider:

		```sh
		[token]

		provider = fernet
		```

- Đồng bộ database cho keystone
	```sh
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	```

	- Lệnh trên sẽ tạo ra các bảng trong database có tên là keysonte

- Thiết lập `Fernet` key

	```sh
	keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
	keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
	```

- Bootstrap the Identity service:
	```sh
	keystone-manage bootstrap --bootstrap-password lxcpassword \
  	--bootstrap-admin-url http://controller:35357/v3/ \
  	--bootstrap-internal-url http://controller:35357/v3/ \
  	--bootstrap-public-url http://controller:5000/v3/ \
  	--bootstrap-region-id RegionOne
	```

- Cấu hình apache cho `keysonte`
	- Dùng `vi` để mở và sửa file `/etc/apache2/apache2.conf`. Thêm dòng dưới ngay sau dòng `# Global configuration`

		 ```sh
		 # Global configuration
		 ServerName controller
		 ```
- LƯU Ý XEM TRONG /etc/apache/site-availabled/keystone.conf XEM ĐÃ ADD PORT 35357 và 5000 NHƯ DƯỚI CHƯA
- tạo file /etc/apache2/sites-available/wsgi-keystone.conf chứa nội dung dưới
```sh
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    LimitRequestBody 114688

    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>

    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
	WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
	WSGIProcessGroup keystone-admin
	WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
	WSGIApplicationGroup %{GLOBAL}
	WSGIPassAuthorization On
	<IfVersion >= 2.4>
	  ErrorLogFormat "%{cu}t %M"
	</IfVersion>
	ErrorLog /var/log/apache2/keystone.log
	CustomLog /var/log/apache2/keystone_access.log combined

	<Directory /usr/bin>
		<IfVersion >= 2.4>
			Require all granted
		</IfVersion>
		<IfVersion < 2.4>
			Order allow,deny
			Allow from all
		</IfVersion>
	</Directory>
</VirtualHost>

Alias /identity /usr/bin/keystone-wsgi-public
<Location /identity>
    SetHandler wsgi-script
    Options +ExecCGI

    WSGIProcessGroup keystone-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
</Location>

```  
- Tạo link để cấu hình virtual host cho dịch vụ keysonte trong apache
```ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled```  

- Khởi động lại `apache`
	```sh
	service apache2 restart
	```

- Xóa file database mặc định của `keysonte` 
	```sh
	rm -f /var/lib/keystone/keystone.db
	```

- Tạo tài khoản quản trị bằng cách đặt biến môi trường:
	```sh
	export OS_USERNAME=admin
	export OS_PASSWORD=lxcpassword
	export OS_PROJECT_NAME=admin
	export OS_USER_DOMAIN_NAME=Default
	export OS_PROJECT_DOMAIN_NAME=Default
	export OS_AUTH_URL=http://controller:35357/v3
	export OS_IDENTITY_API_VERSION=3
	```

## 3. Tạo domain, projects, users, và roles
- Tạo project `service`
	```sh
	openstack project create --domain default
  	--description "KVM Project" service
	```  
	Tạo thành công sẽ như hình dưới:
	<img src = "../Images/II.1.1. Cài đặt Keystone/3.png">  

- Tạo thêm 1 project không có quyền gì được dùng bởi client thường:
```sh
openstack project create --domain default --description "KVM User Project" kvm
```  
<img src = "../Images/II.1.1. Cài đặt Keystone/4.png">  

- Tạo user `kvm`:
	```
	openstack user create --domain default --password-prompt kvm
	```  
	- Nhập mật khẩu `lxcpassword` cho user
	
	<img src = "../Images/II.1.1. Cài đặt Keystone/5.png">  

- Tạo role `user`:
	```sh
	openstack role create user
	```
	<img src = "../Images/II.1.1. Cài đặt Keystone/6.png">  

- ADD role `user` cho project `kvm` và user `kvm`:
	```sh
	openstack role add --project kvm --user kvm user
	```
- Cài Web Service Gateway Interface (WSGI) middleware  
pipeline chô Keystone: 
	- Tạo file /etc/keystone/keystone-paste.ini
```sh
# Keystone PasteDeploy configuration file.  
[filter:debug]  
use = egg:oslo.middleware#debug  
[filter:request_id]  
use = egg:oslo.middleware#request_id  
[filter:build_auth_context]  
use = egg:keystone#build_auth_context  
[filter:token_auth]  
use = egg:keystone#token_auth  
[filter:admin_token_auth]  
use = egg:keystone#admin_token_auth  
[filter:json_body]  
use = egg:keystone#json_body  
[filter:cors]  
use = egg:oslo.middleware#cors  
oslo_config_project = keystone  
[filter:http_proxy_to_wsgi]  
use = egg:oslo.middleware#http_proxy_to_wsgi  
[filter:ec2_extension]  
use = egg:keystone#ec2_extension  
[filter:ec2_extension_v3]  
use = egg:keystone#ec2_extension_v3  
[filter:s3_extension]  
use = egg:keystone#s3_extension  
[filter:url_normalize]  
use = egg:keystone#url_normalize  
[filter:sizelimit]  
use = egg:oslo.middleware#sizelimit  
[filter:osprofiler]  
use = egg:osprofiler#osprofiler  
[app:public_service]  
use = egg:keystone#public_service  
[app:service_v3]  
use = egg:keystone#service_v3  
[app:admin_service]  
use = egg:keystone#admin_service  
[pipeline:public_api]  
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize  
request_id build_auth_context token_auth json_body ec2_extension  
public_service  
[pipeline:admin_api]  
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize  
request_id build_auth_context token_auth json_body ec2_extension  
s3_extension admin_service  
[pipeline:api_v3]  
pipeline = cors sizelimit http_proxy_to_wsgi osprofiler url_normalize  
request_id build_auth_context token_auth json_body ec2_extension_v3  
s3_extension service_v3  
[app:public_version_service]  
use = egg:keystone#public_version_service  
[app:admin_version_service]  
use = egg:keystone#admin_version_service  
[pipeline:public_version_api]  
pipeline = cors sizelimit osprofiler url_normalize  
public_version_service  
[pipeline:admin_version_api]  
pipeline = cors sizelimit osprofiler url_normalize admin_version_service  
[composite:main]  
use = egg:Paste#urlmap  
/v2.0 = public_api  
/v3 = api_v3  
/ = public_version_api  
[composite:admin]  
use = egg:Paste#urlmap  
/v2.0 = admin_api  
/v3 = api_v3  
/ = admin_version_api
```  

## 4. Kiểm chứng lại các bước cài đặt keystone

- Vô hiệu hóa cơ chế xác thực bằng token tạm thời trong `keystone` bằng cách xóa `admin_token_auth` trong các section `[pipeline:public_api]`,  `[pipeline:admin_api]`  và `[pipeline:api_v3]` của file `/etc/keystone/keystone-paste.ini`

- Gõ lệnh như dưới, lệnh này có tác dụng để request và nhận token cho 2 user admin và kvm:
```
openstack --os-auth-url http://controller:35357/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name admin --os-username admin token issue
```  
```
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name kvm --os-username kvm token issue
```  
<img src = "../Images/II.1.1. Cài đặt Keystone/7.png">  
<img src = "../Images/II.1.1. Cài đặt Keystone/8.png">  

## 5. Tạo script biến môi trường cho client 
- Tạo file `rc.admin` với nội dung sau: 
	```sh
	export OS_PROJECT_DOMAIN_NAME=default  
	export OS_USER_DOMAIN_NAME=default  
	export OS_PROJECT_NAME=admin  
	export OS_USERNAME=admin  
	export OS_PASSWORD=lxcpassword  
	export OS_AUTH_URL=http://controller:35357/v3  
	export OS_IDENTITY_API_VERSION=3  
	export OS_IMAGE_API_VERSION=2
	```

- Tạo file `rc.kvm` với nội dung sau:
	```sh
	export OS_PROJECT_DOMAIN_NAME=default  
	export OS_USER_DOMAIN_NAME=default  
	export OS_PROJECT_NAME=kvm  
	export OS_USERNAME=kvm  
	export OS_PASSWORD=lxcpassword  
	export OS_AUTH_URL=http://controller:5000/v3  
	export OS_IDENTITY_API_VERSION=3  
	export OS_IMAGE_API_VERSION=2
	```
- Chạy script `rc.admin`
	```sh
	. rc.admin
	```
-  Kết quả sẽ như bên dưới (Lưu ý: giá trị sẽ khác nhau)

	```sh
	root@controller:~# openstack token issue
	```
<img src = "../Images/II.1.1. Cài đặt Keystone/9.png">  

