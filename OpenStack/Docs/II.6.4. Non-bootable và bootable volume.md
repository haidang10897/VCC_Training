# Boot from image
- Cách này là cách thường thấy, ta sẽ để mặc định boot từ image và gắn thêm ổ cứng (volume) vào. 
- Ngoài đời giống với việc đút đĩa CD vào máy và ngồi bấm F12 hoặc vào bios chọn boot from cd first.
## Cách thực hiện
- **Tạo 1 Volume non-boot (vì boot từ CD)**
	```sh
	openstack volume create --size 8 my-volume
	```  
	<img src = "../Images/II.6.4. Boot from volume/1.png">  

- **Hiển thị danh sách Volume**
	```sh
	$ openstack volume list
	```  
	<img src = "../Images/II.6.4. Boot from volume/2.png">  

- **Tạo 1 máy ảo mới mà máy ảo đấy boot from image và gắn thêm volume trống vào máy.**
	- Lưu ý thay option --image bằng ID của image muốn chọn, --block-device bằng ID của volume vừa tạo. NHỚ THÊM --nic netid=... để tạo vào mạng mình chọn.
	```sh
	$ nova boot --flavor 2 --image 98901246-af91-43d8-b5e6-a4506aa8f369 --block-device source=volume,id=d620d971-b160-4c4e-8652-2513d74e2080,dest=volume,shutdown=preserve --nic netid=... myInstanceWithVolume
	```  
	<img src = "../Images/II.6.4. Boot from volume/3.png">  


# Tạo Volume từ Image và boot từ Volume
- Cái này giống với ngoài đời thực bình thường là boot from HDD, HDD có sẵn hệ điều hành rồi ta chỉ việc cắm vào máy và boot.

## Cách làm
- Hiển thị danh sách Image
	- Lưu ý chọn Image nào có khả năng boot được , có thuộc tính _cinder_img_volume_type_
	```sh
	$ openstack image list
	```  

- Tạo volume với image đã chọn
	```sh
	$ openstack volume create --image IMAGE_ID --size SIZE_IN_GB bootable_volume
	```  
	<img src = "../Images/II.6.4. Boot from volume/4.png">  

- Tạo instance mới và gắn volume có thể boot được vào ( không cần gắn image nữa ). Nhớ chọn --nic option
	```sh
	$ openstack server create --flavor 0 --volume VOLUME_ID myInstanceFromVolume
	```  
	<img src = "../Images/II.6.4. Boot from volume/5.png">  

# Ref
[https://docs.openstack.org/nova/latest/user/launch-instance-from-volume.html](https://docs.openstack.org/nova/latest/user/launch-instance-from-volume.html)
