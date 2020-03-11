# Increase Block Storage API service throughput
- Mặc định `Block Storage API service` chỉ chạy 1 tiến trình. Điều này sẽ giới hạn số `API request` mà Block Storage service có thể xử lý trong cùng 1 lúc. Vậy nên ta phải tăng thông lượng để Block Storage service có thể xử lý nhiều hơn. 

#  Cấu hình
- **Cách 1**: Vào `/etc/cinder/cinder.conf` và sửa dòng `osapi_volume_workers` thành số lượng core mà ta muốn dùng.
- **Cách 2**: Gõ lệnh và thay `CORES` bằng số core cpu mà ta muốn dùng.
	```sh
	# openstack-config --set /etc/cinder/cinder.conf DEFAULT osapi_volume_workers CORES
	```  

# Rèf

[https://docs.openstack.org/cinder/train/admin/blockstorage-api-throughput.html](https://docs.openstack.org/cinder/train/admin/blockstorage-api-throughput.html)
