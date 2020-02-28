# I. Các thông số cơ bản

## I.1. Mô hình mạng
<img src = "../Images/III. Dựng Openstack Stein/Overview/3.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/4.png">  

<img src = "../Images/III. Dựng Openstack Stein/Overview/6.png">  

## I.2. Thông số cơ bản của máy ảo Cirros
### I.2.1. Địa chỉ IP
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/1.png">  

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/2.png">  

### I.2.2. Port và Virtual NIC

- Dùng lệnh `openstack port list` trên máy `Controller`

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/3.png">  

- Dùng lệnh `brctl show` trên máy `Compute`

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/4.png">  

- Xem trong file `/etc/libvirt/qemu/` trên máy `Compute`

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/4a.png">  

## I.3. Thông số cơ bản của máy Controller
### I.3.1. Virtual NIC
- Dùng lệnh `brctl show` trên máy `Controller` để xem các bridge

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/9.png">  

### I.3.2. Namespace
- Dùng lệnh `ip netns` trên máy `Controller` để xem các namespace

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/11.png">  

### I.3.3. Net list
- Dùng lệnh `neutron net-list` trên máy `Controller` để xem các mạng hiện có.

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/14.png">  

- Dùng lệnh `neutron net-show selfservice` trên máy `Controller` để xem chi tiết mạng có tên `selfservice`. Để ý rằng mạng này có segment của vxlan là 91

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/15.png">  

## I.4. Thông số cơ bản của máy Compute
### I.4.1. Virtual NIC
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/4.png">  


# II. Phân tích đường đi gói tin
## II.1. Sơ đồ đường đi
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/osog_1202.png">  

**LƯU Ý: CHÚNG TA SẼ KẾT HỢP XEM CẢ 2 SƠ ĐỒ NÀY VÀ SƠ ĐỒ `Selfservice network` Ở PHẦN I ĐỂ THẤY RÕ HƠN.**

**LƯU Ý 2: BÀI NÀY DÙNG MECHANISM DRIVER LÀ LINUXBRIDGE NÊN SẼ THEO ĐƯỜNG 4a 5a**

## II.2. Tracert và Ping
Trước hết, ta sẽ thử dùng 2 lệnh tracert và ping để xem gói tin icmp đi từ máy ảo Cirros ra ngoài thế nào.

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/16.png">  

Như ta thấy thì 2 vị trí quan trọng ta cần lưu ý là 1 và 2. Vị trí 1 là ta đã đi qua gateway của mạng selfservice network. Sau đó vị trí 2 là ta đã đi qua gateway của mạng thật chính để ra ngoài mạng WAN ngoài kia. Các vị trí đằng sau ta không cần quá tâm, và cuối cùng kết quả thành công.

<img src = "../Images/II.4.2. Phân tích đường đi gói tin/7.png">  

Thử ping `bizflycloud.vn` và kết quả cũng thành công.

Tiếp theo ta sẽ đi phân tích rõ hơn đường đi gói tin theo sơ đồ bên trên.

## II.3. Đường đi gói tin
Theo 2 sơ đồ mạng. Ta có thể hình dung gói tin sẽ đi như sau (áp dụng vào bài chúng ta đang làm):
- **Từ card eth0 có ip 172.16.1.83 của instance cirros sẽ đi đến port tap ngoài compute node có tên là tapa315a574-09**
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/4.png">  
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/4a.png">  

-  **Tiếp tục từ Port tapa315a574-09 thuộc bridge có tên brqb0bd46a3-5f trên compute sẽ đi qua Vlan trunk ( trong sơ đồ selfservice ghi là VXLAN TUNNEL và ở đây là VXLAN 91) đến 1 cái bridge có tên tương tự ở trên controller node.**
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/4.png">  
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/9.png">  

- **Tiếp theo, gói tin đi lên số 6, 7, 8, kết hợp với sơ đồ selfservice network thì đây là router namespace và có tên là qrouter-ee536d55... và xem thông tin namespace trên kia thì sẽ có 2 interface qr-f943a777 và qg-3bd34b9c.**
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/11.png">  

- **Trước hết, gói tin sẽ đi qua qr rồi sau đó đi qua qg và cuối cùng đi ra mạng bên ngoài.**

# III. Bắt gói tin
Theo như đường đi đã phân tích bên trên, giờ chúng ta sẽ bắt gói tin ở 5 điểm là:
- Điểm số 1: Tap port ( 2 )
- Điểm số 2: VXLAN 91 trên compute (4a)
- Điểm số 3: VXLAN 91 trên controller (5a) 
- Điểm số 4: QR Interface (6)
- Điểm số 5: QG Interface (8)


Chúng ta sẽ thử gửi gói tin icmp từ VM Cirros đến `bizflycloud.vn` có địa chỉ ip là`103.92.34.130`
Tiếp đến chúng ta dùng tcpdump chặn bắt cùng lúc ở 5 điểm nêu trên. Kết quả như sau:
- Điểm số 1:
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/6.png">  

- Điểm số 2:
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/8.png">  

- Điểm số 3:
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/10.png">  

- Điểm số 4:
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/12.png">  

- Điểm số 5:
<img src = "../Images/II.4.2. Phân tích đường đi gói tin/13.png">  
LƯU Ý: Ở chỗ này ip đã thay đổi, ko còn ip máy ảo nữa mà là ip từ dải mạng provier network.

# IV. Kết luận
Qua bài này, chúng ta đã cơ bản thấy được đường đi của gói tin trong Openstack Network với mechanism driver được setting là linuxbridge. 

# Ref
[https://docs.openstack.org/operations-guide/_images/osog_1202.png](https://docs.openstack.org/operations-guide/_images/osog_1202.png)
[https://docs.openstack.org/install-guide/launch-instance-networks-selfservice.html](https://docs.openstack.org/install-guide/launch-instance-networks-selfservice.html)
[https://kashyapc.fedorapeople.org/virt/openstack/neutron/neutron-diagnostics.html](https://kashyapc.fedorapeople.org/virt/openstack/neutron/neutron-diagnostics.html)
