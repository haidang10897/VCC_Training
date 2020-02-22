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
 





