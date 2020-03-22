# Migrate volumes

Openstack có khả năng migrate volume giữa các backend mà có cùng loại volume. Migrate volume sẽ di chuyển dữ liệu 1 cách trong suốt với người dùng từ backend hiện tại sang cái mới. Đây là tính năng chỉ có của admin.

# Cách thực hiện
Ở đây chúng ta sẽ migrate block storage có backend là LVM. Cách cấu hình LVM xem lại ở phần "thực hành cài cinder" bên trên.
## Tóm tắt cài đặt Node Block Storage 5 (LVM2)
- **Sửa file `/etc/host` trên tất cả node**
	```sh
	10.0.0.45	block5
	```
	<img src = "../Images/II.6.8. Migrate volumes/1.png">  
- **Sửa file trong `/etc/netplan` để nhận IP `10.0.0.45`**
<img src = "../Images/II.6.8. Migrate volumes/2.png">  
- **Sửa file `/etc/cinder/cinder.conf`. LƯU Ý HÌNH CHỤP NHẦM, THAY MỤC `[LVM]` thành `[LVM2]` và `enabled_backend: LVM2`**
<img src = "../Images/II.6.8. Migrate volumes/3.png">  

	<img src = "../Images/II.6.8. Migrate volumes/4.png">  

## Migrate Volume
- **Xem các service hoạt động tốt chưa**
	```sh
	# openstack volume service list
	```  
	<img src = "../Images/II.6.8. Migrate volumes/5.png">  
- **Hiển thị danh sách các backend có sẵn**
	```sh
	# cinder get-pools
	```  
	<img src = "../Images/II.6.8. Migrate volumes/6.png">  
	
	```sh
	# cinder-manage host list
	```  
	<img src = "../Images/II.6.8. Migrate volumes/7.png">  
	
- **Xem chi tiết volume cần migrate**
	- os-vol-host-attr:host: Backend hiện tại của volume
	- os-vol-mig-status-attr:migstat: Trạng thái migration
	- os-vol-mig-status-attr:name_id: volume ID mà tên của tên của volume đó trên backend mà dựa trên nó.
	```sh
	openstack volume show
	```  
	<img src = "../Images/II.6.8. Migrate volumes/8.png">  
	<br>
	<img src = "../Images/II.6.8. Migrate volumes/9.png">  
	<br>
	<img src = "../Images/II.6.8. Migrate volumes/10.png">  
- **Migrate volume**
	```sh
	openstack volume migrate 6088f80a-f116-4331-ad48-9afb0dfb196c --host block5@lvm2#LVM
	```  
	<img src = "../Images/II.6.8. Migrate volumes/12.png">  

- **Xem thông tin volume sau khi migrate**
	- os-vol-host-attr:host: Backend hiện tại của volume giờ đã ở bên node mới.
	```sh
	<img src = "../Images/II.6.8. Migrate volumes/13.png">  
	```  
- **Xem volume trên Block Storag1 ( giờ đã mất ) và xuất hiện trên Block Storage 5.**
<img src = "../Images/II.6.8. Migrate volumes/14.png">  

	<img src = "../Images/II.6.8. Migrate volumes/15.png">  

