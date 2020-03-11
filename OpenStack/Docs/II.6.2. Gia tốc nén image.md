# Accelerate image compression
- Một General Framework chứa các hardware compression accelerators ( gia tốc nén phần cứng ) để nén các volume mà upload lên dịch vụ Image (Glance) thành image và giải nén để tạo thành volume được giới thiệu từ bản Train trở đi
- Máy gia tốc duy nhất hỗ trợ tính năng này là Intel QuickAssist Technology (QAT), và nén dưới dạng gzip. 
- Image được nén của Volume sẽ được lưu trữ trong Image serivce (glance) với thuộc tính image `container_format`. Xem [https://docs.openstack.org/glance/latest/](https://docs.openstack.org/glance/latest/) để biết thêm chi tiets về `container format`. 
# Cấu hình nén Image
- **Edit file `cinder.conf` để kích hoạt tính năng nén**
	```sh
	allow_compression_on_image_upload = True
	```  
- **Cấu hình định dạng nén là `gzip`**
	```sh
	compression_format = gzip
	```  

# Cấu hình yêu cầu
- Intel  QuickAssist  Technology  (QAT): Phải có phần cứng hỗ trợ QAT ( ví dụ chipset 89xx trở lên ) và Driver
- Gzip

# Ref
[https://docs.openstack.org/cinder/train/admin/blockstorage-accelerate-image-compression.html](https://docs.openstack.org/cinder/train/admin/blockstorage-accelerate-image-compression.html)
[https://www.slideshare.net/MichelleHolley1/intelr-quick-assist-technology-overview](https://www.slideshare.net/MichelleHolley1/intelr-quick-assist-technology-overview)

