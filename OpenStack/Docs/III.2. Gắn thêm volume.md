# Gắn thêm Volume vào instance
Nếu có sử dụng Block Storage  Cinder thì ta có thể gắn thêm Volume vào instance theo các bước sau.
# I. Tạo Volume
- **Đăng nhập với quyền admin ( thực tế sẽ là user demo )**
	```sh
	$ . admin-openrc
	```  
- **Tạo Volume có dung lượng 1GB tên là `volume1`**
	```sh
	$ openstack volume create --size 1 volume1
	```  
	<img src = "../Images/III.2. Gắn thêm volume/1.png">   
	
- **Chờ tạo xong, xem trạng thái volume vừa tạo**
	```sh
	$ openstack volume list
	```  
	<img src = "../Images/III.2. Gắn thêm volume/2.png">   

# II. Gắn Volume vào Instance
- **Gắn thêm Volume1 vào instance `selfservice-instance`**
	```sh
	$ openstack server add volume provider-instance volume1
	```  
- **Xem trạng thái Volume vừa gắn**
	```sh
	$ openstack volume list
	```  
	<img src = "../Images/III.2. Gắn thêm volume/3.png">   
- **Truy cập vào trong VM `selfservice-instance` xem gắn thành công chưa**
	```sh
	fdisk -l
	```  
	<img src = "../Images/III.2. Gắn thêm volume/4.png">   
