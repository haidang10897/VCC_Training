# III. Automating simple task

# 1. Hello ansible
Về phần cài đặt, chúng ta có thể xem ở docs của ansible trên trang chủ, hoặc thích có thể xem ở đây:
[https://tech.bizflycloud.vn/ansible-phan-1-cai-dat-va-cau-hinh-412.htm](https://tech.bizflycloud.vn/ansible-phan-1-cai-dat-va-cau-hinh-412.htm)  

Chúng ta sẽ bắt đầu với việc xem các máy đã được kết nối tốt chưa.
```ansible all -i HOST, -m ping```  

<img src = "../Images/III. Automating simple task/Anh_1.png">  

Giờ ta sẽ phân tích hoạt động của ansible:

```
1. We invoked Ansible.
2. We instructed Ansible to run on all hosts.
3. We specified our inventory (also known as the list of the hosts).
4. We specified the module we wanted to run (ping).
```  

1. Chúng ta gọi ansible
2. Chúng ta hướng dẫn ansible chạy trên mọi host.
3. Chúng ta chỉ định -i iventory chứa các host
4. Chúng ta dùng module mà mình muốn.  

Như vậy, chúng ta đã cài đặt và chạy thành công ansible.

# 2. Working with playbooks
Playbook là 1 trong những tính năng cốt lõi của Ansible và sẽ báo cho Ansible biết phải thực thi cái gì. Nó giống như to do list chứa các danh sách task, mỗi tash sẽ link đến code thực thi (gọi là module).  
Playbook rất đơn giản, được viết băngf ngôn ngữ YAML. Ta có thể có nhiều task trong playbook và mỗi task này sẽ được thực thi lần lượt.  
Tóm lại, ta có thể hiểu đơn giản playbook cũng giống như một cuốn sách hướng dẫn - chúng cho phép ta viết list task hoặc command mà ta muốn thực thi trên các remote system.  

## 2.1. Anatomy of playbook (cấu trúc của playbook)
Playbook có thể chứa danh sách các host, biến người dùng, task, handler, ... Ta hãy xem cấu trúc của playbook qua ví dụ sau:
```
---
- hosts: all
  remote_user: fale
  tasks:
  - name: Ensure the HTTPd package is installed
    yum:
      name: httpd
      state: present
      become: True
   - name: Ensure the HTTPd service is enabled and running
service:
      name: httpd
      state: started
      enabled: True
    become: True
```  
Playbook này sẽ đảm bảo rằng httpd package sẽ được cài và dịch vụ sẽ được bật. Playbook này có tên setup_apache.yaml  
Giờ ta sẽ phân tích. File này sẽ có 3 phần chính: host, remote_user và task.  
- hosts: Phần này sẽ liệt kê danh sách host hoặc host group mà ta muốn chạy task. Trường host này là bắt buộc và mỗi playbook nên cần nó. Nó sẽ báo Ansible rằng sẽ chạy task trên host nào. Khi ta cung cấp host group, Ansible sẽ lấy host group từ playbook và sẽ tìm trong inventory file. Nếu không tìm thấy, Ansible sẽ skip tất cả task dành cho host group đó.  
- remote_user: Đây là 1 trong những tham số cần thiết lập để báo cho Ansible biết sẽ dùng user nào (trường hợp này là TOM) để log vào hệ thống.  
- tasks: Cuối cùng là mục task. Tất cả các playbook đều có task. Task là danh sách các hành động mà ta muốn thực hiện. Trường task gồm tên task (để giúp ta dễ hiểu), module để thực thi, và các argument cần thiết cho module đó. Giờ ta sẽ đi phân tích tiếp cấu trúc của task.

### Cấu trúc của task
- name: Đây là tham số thể hiện rằng task đang làm là gì, ta có thể tùy ý đặt tên task. Các module như `yum`, `service` đều có bộ tham số riêng của chúng để xác định xem phải thực hiện cái gì. Giờ ta sẽ đi phân tích các tham số này:  
- - Trong module của `yum`, tham số `state` là `present` thể hiện rằng sẽ install package mới nhất. ĐIều này tương đương `yum install httpd`.  
- - Trong module của service, `state` lại là `started` thể hiện rằng service cần phải được bắt đầu, việc này tương đương dùng lệnh để bắt đầu service `/etc/init.d/httpd start`. Tham số `enabled` là `true` thể hiện là khởi động dịch vụ này lúc boot hệ thống.  
- -- Tham số `become: True` thể hiện ta sẽ chạy các task dưới quyền sudo.  

## 2.2. Chạy playbook

Ta sẽ chạy playbook bên trong bằng câu lệnh sau:  
```
ansible-playbook -i HOST, setup_apache.yaml
```  

Kết quả sẽ ra như sau:  
```
PLAY [all] *******************************************************
TASK [setup] *****************************************************
ok: [test01.fale.io]

TASK [Ensure the HTTPd package is installed] *********************
changed: [test01.fale.io]

TASK [Ensure the HTTPd service is enabled and running] ***********
changed: [test01.fale.io]

PLAY RECAP *******************************************************
test01.fale.io
: ok=3
changed=2
unreachable=0
failed=0
```  

Như vậy là mọi thứ đã hoàn thành. Ta có thể kiểm tra xem httpd đã có chưa và service đã hoạt động chưa bằng các lênh:  
```
rpm -qa | grep httpd  
systemctl status httpd
```  

Giờ ta sẽ phân tích các thông báo:  
- `PLAY [all]`: Phần này báo cho ta biết rằng playbook sẽ thực thi trên **`ALL HOST`**  
-  `TASK [setup]`: Phần task setup này tuy ta không viết ra nhưng vẫn có là vì trước khi thực thi các task thi Ansible phải connect được đến các remote host và kiểm tra các yêu cầu cần thiết. Nếu đủ yêu cầu sẽ báo OK.  
- ` 2 Task tiếp theo ta viết`: Hai task này sẽ có dòng `chaged` thông báo cho ta biết rằng task đã được thực thi và thành công VÀ THAY ĐỔI GÌ ĐÓ trên máy.  
- `PLAY RECAP` : Dòng này sẽ thông báo tổng kết lại xem thành công hay chưa. ( Nếu ta thử rerun lại playbook trên sẽ thấy changed đổi từ 2 thành 0 là vì các task đã được thực thi lúc trước rồi nên sẽ không có thay đổi gì nữa).  

***`Note: Để hiện thij chi tiết quá trình thực thi các lệnh, ta có thể dùng option -v, -vv, -vvv, -vvv. Điều này rất giúp ích cho quá trình tìm lỗi, debug, ...`***  

# 3. Variables in playbooks 
Đôi khi, ta phải dùng các biến set và get để đặt và lấy giá trị trong playbook. Ta hãy xem 1 ví dụ sau:  
```
- hosts: all
  remote_user: fale
  tasks:
  - name: Set variable 'name'
    set_fact:
      name: Test machine
  - name: Print variable 'name'
    debug:
      msg: '{{ name }}'
```  

Kết quả khi chạy sẽ thành như sau:  
```
PLAY [all] **********************************************************
TASK [setup] ********************************************************
ok: [test01.fale.io]

TASK [Set variable 'name'] ******************************************
ok: [test01.fale.io]

TASK [Print variable 'name'] ****************************************
ok: [test01.fale.io] => {
"msg": "Test machine"
}

PLAY RECAP **********************************************************
test01.fale.io
: ok=3
changed=0
unreachable=0
failed=0
```  

Như trên, ta dễ thấy ta sẽ set biến (trong Ansible gọi là facts) và in ra màn hình dùng hàm debug.  

### Lấy thông tin hệ điều hành và version  

Ta lại thử 1 ví dụ nữa:  
```
- hosts: all
  remote_user: fale
  tasks:
   - name: Print OS and version
     debug:
       msg: '{{ ansible_distribution }} {{
ansible_distribution_version }}'
```  

Ta sẽ được như sau:  
```
TASK [Print OS and version] **************************************
ok: [test01.fale.io] => {
"msg": "CentOS 7.2.1511"
}
```  
**`Note: Các biến có sẵn mà ansible định nghĩa có thể dễ dàng tìm thấy trên docs của Ansible.`**  

**`Note 2: Ta cũng có thể truyền tham số vào với option -e. VÍ dụ: -e 'name=dang'`**  

# 4. Tạo Ansible user

Khi ta có 1 hệ thống mới, hệ thống đó đương nhiên chỉ có root user. Giờ ta bắt buộc phải tạo 1 playbook để đảm bảo Ansible user sẽ được tạo ra và có thể truy cập được thông qua SSH key, và có thể thực hiện sudo mà không cần password. Dưới đây là ví dụ:  
```
---
- hosts: all
  user: root
  tasks:
  - name: Ensure ansible user exists
    user:
     name: ansible
     state: present
     comment: Ansible
  - name: Ensure ansible user accepts the SSH key
    authorized_key:
     user: ansible
     key: https://github.com/fale.keys
   state: present
- name: Ensure the ansible user is sudoer with no password
required
  lineinfile:
   dest: /etc/sudoers
   state: present
   regexp: '^ansible ALL\='
   line: 'ansible ALL=(ALL) NOPASSWD:ALL'
   validate: 'visudo -cf %s'
```  

Chúng ta sẽ đi phân tích chút. 
- Module `user` cho phép chúng ta tạo user mới, và xem đã có chưa `present`  
- Module `authorized_key` cho phép chúng ta đảm bảo rằng SSH key sẽ được dùng để login với user chỉ định trên máy đó.  
- Module `lineinfile` cho phép chúng ta thay đổi nội dung file. Trước tiên ta xem file đó có chưa `present` rồi tìm chuỗi xem có chưa, nếu chưa có sẽ add `line` đó vào cuối file.  







