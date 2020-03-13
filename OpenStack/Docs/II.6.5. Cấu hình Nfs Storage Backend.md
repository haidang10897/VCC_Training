# Cấu hình Nfs Storage Backend
- Ở các phần trước, chúng ta đã cấu hình Cinder dùng LVM backend. Giờ ta sẽ cấu hình để dùng thêm Backend là NFS (Tương lai sẽ cấu hình dùng thêm Glusterfs)

# Cách cấu hình
- **Nếu các host có bật SElinux thì cho phép dùng NFS TRÊN TẤT CẢ HOST**
	```sh
	# setsebool -P virt_use_nfs on
	```  
## Cấu hình trên node Block (Cinder)
- **Cài đặt gói nfs**
	```sh
	apt-get -y install nfs-common
	```  
- **Tạo file `nfs_shares` trong `/etc/cinder` và ghi như sau. Đây là vị trí thư mục mà chúng ta sẽ share khi cấu hình NFS.:**
	```sh
	block2:/dang_nfs_shares
	```  
- **Gán quyền cho file `nfs_shares`**
	```sh
	# chown root:cinder /etc/cinder/nfs_shares
	```  
	```sh
	# chmod 0640 /etc/cinder/nfs_shares
	```  
- **Sửa file `/etc/cinder/cinder.conf`**
	-  Thêm mục `[nfs]` chứa thông tin cấu hình như đoạn sau:
		```sh
		[nfs]
		volume_driver = cinder.volume.drivers.nfs.NfsDriver
		volume_backend_name = nfsbackend
		nfs_shares_config = /etc/cinder/nfs_shares
		nfs_mount_point_base = $state_path/mnt_nfs
		```  
	- Trong mục `[DEFAULT]`, thêm kích hoạt backend nfs
		```sh
		enabled_backends = lvm,nfs
		```  
- **Restart lại dịch vụ**
	```sh
	service cinder-volume restart
	```  

## Cấu hình trên Compute node
- **Cài đặt nfs**
	```sh
	apt-get -y install nfs-common
	```  
- **Sửa file `/etc/nova/nova.conf`, thêm 2 dòng sau:**
	```sh
	osapi_volume_listen = 0.0.0.0
	volume_api_class = nova.volume.cinder.API
	```  
- **Restart dịch vụ**
	```sh
	service nova-compute restart
	```  

## Cấu hình trên Block2 node (Nfs)
- **Chỉnh sửa file `/etc/hosts`**
- **Phần vùng ổ cứng**
	```sh
	fdisk /dev/sdb
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/5.png">  
- **Format phân vùng vừa tạo với định dạng xfs:**
	```sh
	mkfs.xfs /dev/sdb1
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/6.png">  
- **Mount partition vào thư mục /dang_nfs_shares :**
	```sh
	mount /dev/sdb1 /dang_nfs_shares
	```  
- **Cài đặt `nfs server`**
	```sh
	apt-get -y install nfs-kernel-server
	```  
- **Sửa file `/etc/exports` cho phép mount thư mục /dang_nfs_shares đến dải 10.0.0.0/24**
	```sh
	/dang_nfs_shares 10.10.10.0/24(rw,no_root_squash)
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/7.png">  
- **Sửa file `/etc/fstab` để tự động mount mỗi lần mở máy**
	```sh
	/dev/sdb1 /dang_nfs_shares xfs defaults 0 0
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/8.png">  
- **Khởi động lài dịch vụ**
	```sh
	/etc/init.d/nfs-kernel-server restart
	```  
# Kiểm tra cấu hình
- **Trên Node Block. kiểm tra thử xem đã nhận thư mục được share chưa**
	```sh
	df -h
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/9.png">  
- **Trên node Controller, kiểm tra các dịch vụ hoạt động tốt chưa**
	```sh
	openstack volume service list
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/3.png">  

- **Trên Node controller, tạo 1 volume type có tên là `nfstype`**
	```sh
	openstack volume type create nfstype
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/1.png">  

- **Set backend cho `nfstype` là dùng backend `nfs` có tên mà ta cấu hình ở trên là `nfsbackend`**
	```sh
	# cinder type-key nfstype set volume_backend_name=nfsbackend
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/2.png">  
- **Tạo 1 Volume có tên là `nfsvolume` dùng backend là `nfs` có type là `nfstype`**
	```sh
	# cinder create --volume_type nfstype --display_name nfsvolume 1
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/4.png">  
- **Xem thông tin volume vừa tạo trên node controller**
	```sh
	openstack volume list
	```  
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/10.png">  
	
- **Để chi tiết hơn, ta vào Node Block2 (NFS), ls vào folder share (dang_nfs_shares) và xem volume vừa tạo ra có hay chưa.**
	<img src = "../Images/II.6.5. Cấu hình Nfs Storage Backend/11.png">  
	




# Ref
[https://docs.openstack.org/cinder/train/admin/blockstorage-nfs-backend.html](https://docs.openstack.org/cinder/train/admin/blockstorage-nfs-backend.html)
[https://access.redhat.com/articles/1323213](https://access.redhat.com/articles/1323213)
