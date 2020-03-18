# Multiple Storage back end

# I. Mô hình
<img src = "../Images/III. Dựng Openstack Stein/Overview/3.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/4.png">  

# II. Cài đặt.
-   Lưu ý : Trên mô hình phải được cài đặt sẵn OpenStack và Cinder, nếu chưa có tham khảo tại các phần trước.
-   Với mô hình trên LVM đã được cài đặt và thiết lập trước đó, ở bài này chỉ giới thiệu về glusterfs và nfs.
- NHỚ SỬA TẤT CẢ FILE `/etc/hosts` TRÊN TẤT CẢ CÁC NODE
- 
## II.1. Cấu hình trên node Block (Cinder)

-   Cài đặt các gói  `nfs-common`  và  `glusterfs-client`  :
	```sh
	apt-get -y install nfs-common glusterfs-client 
	```
-   Dùng trình soạn thảo  `vi`  mở file cinder config `vi /etc/cinder/cinder.conf ` :

	- Tại section [default] tìm và sửa dòng  `enabled_backends`  như sau :
		```sh
		enabled_backends = lvm,nfs,glusterfs
		```
	- Thêm section nfs với nội dung như sau :
		```sh
		[nfs]
		volume_driver = cinder.volume.drivers.nfs.NfsDriver
		volume_backend_name = NFS
		nfs_shares_config = /etc/cinder/nfs_shares
		nfs_mount_point_base = $state_path/mnt_nfs 
		```
		
	- Thêm section [glusterfs] với nội dung như sau :
		```sh
		[glusterfs]
		volume_driver = cinder.volume.drivers.glusterfs.GlusterfsDriver
		volume_backend_name = GlusterFS
		glusterfs_shares_config = /etc/cinder/glusterfs_shares
		glusterfs_mount_point_base = $state_path/mnt_glusterfs
		```
-   Dùng trình soạn thảo  `vi`  mở file  `/etc/cinder/glusterfs_shares` thêm vào nội dung :
	```sh
	# create new : specify GlusterFS volumes

	block3:/dang_gfs_shares

	# testvol2 là trên của volume mà chúng ta sẽ tạo tạo GFS server.
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
- **Gán quyền cho file `glusterfs_shares`**
	```sh
	# chown root:cinder /etc/cinder/glusterfs_shares
	```  
	```sh
	# chmod 0640 /etc/cinder/glusterfs_shares
	```  
- **Restart lại dịch vụ**
	```sh
	service cinder-volume restart
	```  

## II.2. Cấu hình trên node Compute
- **Cài đặt nfs và glusterfs**
	```sh
	apt-get -y install nfs-common glusterfs-client
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
## II.3 . Cấu hình trên Node gfs1 và gfs2 (thực hiện tương tự) 
- **Chỉnh sửa file `/etc/hosts` thêm phân giải tên miền**
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
- **Mount partition vào thư mục /dang_gfs_shares  và tạo thư mục brick1:**
	```sh
	mount /dev/sdb1 /dang_gfs_shares && mkdir -p /dang_gfs_shares/brick1
	```  
- **Cài đặt `nfs server`**
	```sh
	apt-get -y install glusterfs-server
	```  
- **Sửa file `/etc/exports` cho phép mount thư mục /dang_gfs_shares đến dải 10.0.0.0/24**
	```sh
	/dang_gfs_shares 10.10.10.0/24(rw,no_root_squash)
	```  
- **Sửa file `/etc/fstab` để tự động mount mỗi lần mở máy**
	```sh
	/dev/sdb1 /dang_gfs_shares xfs defaults 0 0
	```  
### II.3.1. Tiếp tục thực hiện trên gfs2

-   Tạo 1 pool storage với Server gfs1:
	```sh
	gluster peer probe block3
	```
-   Kiểm tra trạng thái của gluster pool
	```sh
	gluster peer status
	```
-   Khởi tạo volume :
	```sh
	gluster  volume create dang_gfs_shares replica 2 transport tcp  block3:/dang_gfs_shares/brick1  block 4:/dang_gfs_shares/brick1
	```
-   Start volume :
	```sh
	gluster volume start dang_gfs_shares
	```  

## II.4. Cấu hình trên Block2 node (Nfs)
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

# III. Kiểm tra cấu hình
# III.1. Kiểm tra cấu hình NFS
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

## III.2. Kiểm tra cấu hình GFS
- **Trên Node Block3 và 4. kiểm tra thử xem đã nhận thư mục được share chưa**
	```sh
	df -h
	```  
- **Trên node Controller, kiểm tra các dịch vụ hoạt động tốt chưa**
	```sh
	openstack volume service list
	```    

# REF
[https://docs.openstack.org/cinder/train/admin/blockstorage-multi-backend.html](https://docs.openstack.org/cinder/train/admin/blockstorage-multi-backend.html)

[https://1hosting.com.vn/glusterfs-la-gi-cau-hinh-glusterfs-nhu-nao-phan-2/](https://1hosting.com.vn/glusterfs-la-gi-cau-hinh-glusterfs-nhu-nao-phan-2/)


    

