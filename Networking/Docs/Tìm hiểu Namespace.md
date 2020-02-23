# LINUX NETWORK NAMESPACES

### ***Mục lục***

[1. Giới thiệu Linux namespace](#1)

- [1.1. Linux namespace là gì?](#1.1)

- [1.2.	Một số thao tác quản lý làm việc với linux network namespace](#1.2)

	- [1.2.1. List namespace](#1.2.1)

	- [1.2.2.	Add namespaces](#1.2.2)

	- [1.2.3.	Executing commands trong namespaces](#1.2.3)

	- [1.2.4.	Gán interface vào một network namespace](#1.2.4)

	- [1.2.5.	Xóa namespace](#1.2.5)



<a name = '1'></a>
# 1.	Giới thiệu Linux namespace

<a name = '1.1'></a>
## 1.1.	Linux namespace là gì?

- Chuyển mạch trên phần mềm trong hệ thống linux là một trong những phần quan trọng khi sử dụng các công nghệ ảo hóa như KVM hay LXC. Các host thông thường không cung cấp một hoặc nhiều hơn một bộ chuyển đổi adapter vật lý cho mỗi giao diện mạng NIC trên một máy ảo VM trong KVM hay mỗi container sử dụng LXC. 

- **Network namspace** là khái niệm cho phép bạn cô lập môi trường mạng network trong một host. Namespace phân chia việc sử dụng các khác niệm liên quan tới network như devices, địa chỉ addresses, ports, định tuyến và các quy tắc tường lửa vào trong một hộp (box) riêng biệt, chủ yếu là ảo hóa mạng trong một máy chạy một kernel duy nhất. 

- Mỗi network namespaces có bản định tuyến riêng, các thiết lập iptables riêng cung cấp cơ chế NAT và lọc đối với các máy ảo thuộc namespace đó. Linux network namespaces cũng cung cấp thêm khả năng để chạy các tiến trình riêng biệt trong nội bộ mỗi namespace.

- Network namespace được sử dụng trong khá nhiều dự án như Openstack, Docker và Mininet. 

<a name = '1.2'></a>
## 1.2.	Một số thao tác quản lý làm việc với linux network namespace


Ban đầu, khi khởi động hệ thống Linux, bạn sẽ có một namespace mặc định đã chạy trên hệ thống và mọi tiến trình mới tạo sẽ thừa kế namespace này, gọi là root namespace. Tất cả các quy trình kế thừa network namespace được init sử dụng (PID 1).


<img src = "../Images/Tìm hiểu Namespace/7.1.png"> 

<a name = '1.2.1'></a>
### 1.2.1.	List namespace

- Cách để làm việc với network namespace là sử dụng câu lệnh ip netns (tìm hiểu thêm tại [man ip netns](http://manpages.ubuntu.com/manpages/xenial/en/man8/ip-netns.8.html)) 

- Để liệt kê tất cả các network namespace trên hệ thống sử dụng câu lệnh: 

	```
	ip netns
	# or
	ip netns list
	```
- Nếu chưa thêm bất kì network namespace nào thì đầu ra màn hình sẽ để trống. root namespace sẽ không được liệt kê khi sử dụng câu lệnh ip netns list.

<a name = '1.2.2'></a>
### 1.2.2.	Add namespaces

- Để thêm một network namespace sử dụng lệnh `ip netns add <namespace_name>` 

- Ví dụ: tạo thêm 2 namespace là ns1 và ns2 như sau:

	``` 
	ip netns add ns1
	ip netns add ns2
	```

	<img src = "../Images/Tìm hiểu Namespace/7.2.png"> 

- Sử dụng câu lệnh ip netns hoặc ip netns list để hiển thị các namespace hiện tại:

	```
	root@controller:~#
	root@controller:~# ip netns
	ns2
	ns1
	root@controller:~#
	root@controller:~# ip netns list
	ns2
	ns1
	root@controller:~#
	```

- Mỗi khi thêm vào một namespace, một file mới được tạo trong thư mục `/var/run/netns` với tên giống như tên namespace. (không bao gồm file của root namespace).

	```
	root@controller:~# ls -l /var/run/netns
	total 0
	-r--r--r-- 1 root root 0 Aug  1 09:14 ns1
	-r--r--r-- 1 root root 0 Aug  1 09:14 ns2
	root@controller:~#
	```

<a name = '1.2.3'></a>
### 1.2.3.	Executing commands trong namespaces

- Để xử lý các lệnh trong một namespace (không phải root namespace) sử dụng `ip netns exec <namespace> <command>`

	Tham khảo thêm tại: [man ip netns](http://manpages.ubuntu.com/manpages/xenial/en/man8/ip-netns.8.html) 

- Ví dụ: chạy lệnh `ip a` liệt kê địa chỉ các interface trong namespace ns1.

	<img src = "../Images/Tìm hiểu Namespace/7.3.png"> 

- Kết quả đầu ra sẽ khác so với khi chạy câu lệnh ip a ở chế độ mặc định (trong root namespace). Mỗi namespace sẽ có một môi trường mạng cô lập và có các interface và bảng định tuyến riêng.

- Để liệt kê tất các các địa chỉ interface của các namespace sử dụng tùy chọn `–a` hoặc `–all` như sau: 

	```
	root@controller:~# ip -a netns  exec ip a

	netns: ns2
	1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
	    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

	netns: ns1
	1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
	    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
	root@controller:~#
	root@controller:~#
	root@controller:~# ip --all netns  exec ip a

	netns: ns2
	1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
	    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

	netns: ns1
	1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
	    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
	root@controller:~#
	```
- Để sử dụng các câu lệnh với namespace ta sử dụng command bash để xử lý các câu lệnh trong riêng namespace đã chọn: 

	```
	ip netns exec <namespace_name> bash
	ip a #se chi hien thi thong tin trong namespace <namespace_name> 
	```

	Thoát khỏi vùng làm việc của namespace gõ exit

- Ví dụ:

	<img src = "../Images/Tìm hiểu Namespace/7.4.png"> 

<a name = '1.2.4'></a>
### 1.2.4.	Gán interface vào một network namespace

- Sử dụng câu lệnh sau để gán interface vào namespace:

	`ip link set <interface_name> netns <namespace_name>`

- Gán một interface if1 vào namespace ns1 sử dụng lệnh sau: 

	`ip link set <interface_name> netns <namespace_name>`

- Các thao tác khác tương tự như các câu lệnh bình thường, thêm `ip netns exec <namespace_name> <command>`

<a name = '1.2.5'></a>
### 1.2.5.	Xóa namespace

Xóa namespace sử dụng câu lệnh: 

`ip netns delete <namespace_name>`
