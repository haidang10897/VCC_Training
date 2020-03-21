# Back up Block Storage service disks

- Chúng ta không những dùng LVM Snapshot để tạo snapshot mà ta còn có thể dùng nó để backup volume. Với việc dùng LVM Snapshot, ta có thể giảm dung lượng backup. Chỉ có những dữ liệu tồn tại được backup thay vì backup toàn bộ volume
- Để backup volume, trước tiên ta phải tạo snapshot cho nó đã. LVM snapshot là môt bản copy của logical volume - thứ mà chứa dữ liệu ở trạng thái đóng băng (frozen state). Điều này sẽ giúp ngăn ngừa việc dữ liệu bị hỏng vì dữ liệu không được di chuyển hoàn chỉnh trong quá trình tạo volume mới. 
- **HÃY NHỚ THÁO VOLUME RA RỒI MỚI BACKUP**
- **NHỚ ĐẢM BẢO ĐỦ DUNG LƯỢNG TRỐNG ĐỂ LƯU BACKUP**
- Chúng ta sẽ dùng các lệnh sau để thực hiện:
	- Lệnh LVM để tạo backup
	- Lệnh kpartx để xem các partition đã tạo trong instance.
	- Lệnh tar để nén lại cho nhẹ
	- Lệnh sha1sum để kiểm tra tính toàn vẹn.

## Cách thực hiện
- **Tạo snapshot của Volume**
	- Hiển thị danh sách Logical Volume
		```sh
		# lvdisplay
		```  

		<img src = "../Images/II.6.7. Back up Block Storage service disks/1.png">  
		<br>
		<img src = "../Images/II.6.7. Back up Block Storage service disks/2.png">  

	- Tạo snapshot
		```sh
		lvcreate --size 100M --snapshot --name volume1-snapshot /dev/cinder-volumes/volume...
		```  
		<img src = "../Images/II.6.7. Back up Block Storage service disks/3.png">  
	- Xem danh sách Logical Volume xem tạo thành công chưa
		```sh
		# lvdisplay
	  ```  
	  <img src = "../Images/II.6.7. Back up Block Storage service disks/4.png">  

- **Xem Partition table**
	- Lệnh **kpartx** discovers và map các table partitions
		```sh
		# kpartx -av /dev/cinder-volumes/volume-00000001-snapshot
		```  
		<img src = "../Images/II.6.7. Back up Block Storage service disks/5.png">  
	- Xem partition table map
		```sh
		$ ls /dev/mapper/
		```  
		<img src = "../Images/II.6.7. Back up Block Storage service disks/6.png">  
	- Mount vào /mnt
		```sh
		mount /dev/mapper/volume1-snapshot1 /mnt
		```  
		
- **Dùng lệnh **Tar** để nén lại.** 
	- NOTE: DÙNG THÊM OPTION `--exclude="lost+found" --exclude="some/data/to/exclude"` ĐỂ CHỈ BACKUP NHỮNG NƠI CẦN THIẾT, ĐỂ TIẾT KIỆM DUNG LƯỢNG.
	```sh
	tar -czf volume-00000001.tar.gz -C /mnt/ /dang_backup
	```   
	<img src = "../Images/II.6.7. Back up Block Storage service disks/7.png">  

- **Tính hàm băm và ghi lại hàm băm này để nếu có chuyển đi đâu thì có thể kiểm tra tính toàn vẹn**
	```sh
	sha1sum volume-00000001.tar.gz
	```  
	<img src = "../Images/II.6.7. Back up Block Storage service disks/8.png">  
- **Unmount Volume, Delete partition table, Remove snapshot.**
	```sh
	$ umount /mnt
	$ kpartx -dv /dev/cinder-volumes/volume-00000001-snapshot
	$ lvremove -f /dev/cinder-volumes/volume-00000001-snapshot
	```  
	<img src = "../Images/II.6.7. Back up Block Storage service disks/9.png">  

# REF
[https://docs.openstack.org/cinder/train/admin/blockstorage-backup-disks.html](https://docs.openstack.org/cinder/train/admin/blockstorage-backup-disks.html)




