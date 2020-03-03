# I. Tạo Virtual Network
## I.1. Tạo Provider Network
- **Truy cập Openstack với quyền admin**
	```sh
	$ . admin-openrc
	```  
- **Tạo network**
	```sh
	$ openstack network create  --share --external --provider-physical-network provider --provider-network-type flat provider
	```  
	- *`--share`: Cho phép tất cả các Project dùng Virtual Network*
	- *`--external`: Chỉ cho virtunal network biết là mạng external (mặc định là internal)* 
	- *`--provider-physical-network  provider` và `--provider-network-type  flat`: Kết nối flat virtual network vào flat physical network ở interface `ens38`*
		- `ml2_conf.ini`:
			```sh
			[ml2_type_flat]
			flat_networks = provider
			```  
		- `linuxbridge_agent.ini`:
			```sh
			[linux_bridge]
			physical_interface_mappings = provider:ens38
			```  
<img src = "../Images/III. Dựng Openstack Stein/deploy/1.png">   

<img src = "../Images/III. Dựng Openstack Stein/deploy/2.png">   

- **Tạo subnet trên network**
```sh
openstack subnet create --network provider --allocation-pool start=192.168.1.101,end=192.168.1.250 --dns-nameserver 192.168.1.1 --gateway 192.168.1.1 --subnet-range 192.168.1.0/24 provider
```  
<img src = "../Images/III. Dựng Openstack Stein/deploy/3.png">   

<img src = "../Images/III. Dựng Openstack Stein/deploy/4.png">   

## I.2. Tạo Self-service Network
### I.2.1. Tạo Self-service Network
- **Truy cập Openstack với quyền admin**
	```sh
	$ . admin-openrc
	```  
- **Tạo Network** 
	```sh
	openstack network create selfservice
	```  
	- *Hệ thống sẽ tự chọn thông số mà ta cấu hình từ trước*
		```sh
		`ml2_conf.ini`:
		[ml2]
		tenant_network_types = vxlan

		[ml2_type_vxlan]
		vni_ranges = 1:1000
		```  
<img src = "../Images/III. Dựng Openstack Stein/deploy 2/1.png">   

<img src = "../Images/III. Dựng Openstack Stein/deploy 2/2.png">   

- **Tạo subnet cho network**
	```sh
	$ openstack subnet create --network selfservice --dns-nameserver 8.8.8.8 --gateway 172.16.1.1 --subnet-range 172.16.1.0/24 selfservice
	```  
<img src = "../Images/III. Dựng Openstack Stein/deploy/5.png">   


### I.2.2. Tạo Router
Self-service network kết nối với provider network bằng cách dùng 1 virtual router. Mỗi router chứa 1 interface ở ít nhất mỗi self-service network và 1 gateway ở provider network.
Provider network cần phải có option `router:external` để kích hoạt self-service router dùng nó để kết nối tới external network (internet). `admin` hoặc người có thẩm quyền phải mở tuỳ chọn này trong lúc tạo network hoặc sau đó cũng được. Trong trường hợp này. option `router:external` đã được chọn `--external` trong lúc tạo `provider` network.
- **Truy cập Openstack với quyền admin**
	```sh
	$ . admin-openrc
	```  
- **Tạo router**
	```sh
	$ openstack router create router
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/6.png">   
	
- **Add subnet của self-service network làm 1 interface của router**
	```sh
	$ openstack router add subnet router selfservice
	```  
-  **Set gateway trên provider network trên router**
	```sh
	$ openstack router set router --external-gateway provider
	```  
### I.2.3. Kiểm tra vận hành
- **Truy cập Openstack với quyền admin**
	```sh
	$ . admin-openrc
	```  
- **Hiện danh sách namespace**
	```sh
	$ ip netns
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/7.png">   
- **Hiện danh sách port trên router**
	```sh
	$ openstack port list --router router
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/8.png">   
	
- **Ping ra ngoài mạng internet**
	```sh
	$ ping -c 4 google.com
	```  

# II. Tạo Flavor
Flavor là lượng tài nguyên chỉ định cho VM
- **Tạo flavor**
	```sh
	$ openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/9.png">   
	
# III. Tạo khoá công khai
- **Truy cập Openstack với quyền user demo**
	```sh
	$ . demo-openrc
	```  

- **Tạo khoá công khai và add khoá public**
	```sh
	$ ssh-keygen -q -N ""
	$ openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/10.png">   
- **Hiện danh sách khoá**
	```sh
	$ openstack keypair list
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/11.png">   

# IV. Thêm luật vào security group
Mặc định thì security group sẽ áp dụng tất cả luật default lên instance và bao gồm cả luật firewall là chặn ssh và ping. Chúng ta sẽ bỏ 2 luật đó
- **Cho phép gửi gói tin ICMP**
	```sh
	$ openstack security group rule create --proto icmp default
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/12.png">   
- **Cho phép SSH**
	```sh
	$ openstack security group rule create --proto tcp --dst-port 22 default
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/13.png">   
	
# V. Tạo máy ảo self-service network
## V.1. Khởi tạo máy ảo
- **Xem list flavor**
	```sh
	$ openstack flavor list
	```  
- **Xem list image**
	```sh
	$ openstack image list
	```  
- **Xem list network**
	```sh
	$ openstack network list
	```  
- **Xem list security group**
	```sh
	security group
	``` 
	<img src = "../Images/III. Dựng Openstack Stein/deploy/14.png">   
- **Tạo máy ảo**
	```sh
	openstack server create --flavor m1.nano --image cirros \
	  --nic net-id=b0bd... --security-group default \
	  --key-name mykey selfservice-instance
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/15.png">   
- **Xem danh sách máy ảo**
	```sh
	$ openstack server list
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/16.png">   
## V.2. Truy cập máy ảo dùng virtual console
- **Lấy url**
	```sh
	$ openstack console url show selfservice-instance
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/17.png">   
- **Dùng trình duyệt web truy cập vào url vừa lấy được**
	<img src = "../Images/III. Dựng Openstack Stein/deploy/18.png">   
- **Ping gateway để kiểm tra**
	```sh
	$ ping -c 4 172.16.1.1
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/19.png">   
- **Ping ra ngoài internet để kiểm tra**
	```sh
	$ ping -c 4 google.com
	```  
	
<img src = "../Images/III. Dựng Openstack Stein/deploy/20.png">   

<img src = "../Images/III. Dựng Openstack Stein/deploy/21.png">   

## V.3. Truy cập máy ảo từ xa
- **Tạo `float ip address` trên `provider virtual network`**
	```sh
	$ openstack floating ip create provider
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/22.png">   
- **Gán `IP adress` vừa tạo vào instance**
	```sh
	$ openstack server add floating ip selfservice-instance 192.168.1.229
	```  
- **Xem trạng thái của instance**
	```sh
	$ openstack server list
	```  
	<img src = "../Images/III. Dựng Openstack Stein/deploy/23.png">   
- **Từ máy cùng dải mang provider network, ping đến máy ảo xem kết nối được chưa**
	<img src = "../Images/III. Dựng Openstack Stein/deploy/24.png">   
- **SSH đến máy ảo**
	<img src = "../Images/III. Dựng Openstack Stein/deploy/25.png">   
	<img src = "../Images/III. Dựng Openstack Stein/deploy/26.png">   




