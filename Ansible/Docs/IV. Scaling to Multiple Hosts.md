# Scaling to Multiple Hosts

Trong chương này, ta sẽ tìm hiểu:  
- Ansible inventories
- Ansible host/group variables
- Ansible loops

# 1. Working with inventory files

Inventory file là nguồn tin cậy của Ansible. Nó được viết dưới dạng file INI format và dùng để báo Ansible biết các host được cung cấp là hợp lệ.  

## Inventory file cơ bản
Trong folder của Ansible, có 1 inventory file cơ bản tên là `hosts`. Tại đây chúng ta sẽ ghi các host mà ta sẽ dùng.  
Lúc trước ta dùng lệnh với option -i để chỉ định cụ thể:
```ansible-playbook -i test01.fale.io, webserver.yaml```  

Giờ ta có thẻ thay đổi thành như sau:  
```ansible-playbook -i hosts webserver.yaml```  

## Group trong inventory file
### Cấu trúc
```
[webserver]
ws01.fale.io
ws02.fale.io
[database]
db01.fale.io
```  

Giờ nếu ta muốn chỉ định playbook chỉ chạy task trong 1 nhóm cụ thể thì chỉ việc thay đổi  `hosts: all` thành `hosts: webserver`  

# 2. Working with variables
## Host variable
```
[webserver]
ws01.fale.io domainname=example1.fale.io
ws02.fale.io domainname=example2.fale.io
[database]
db01.fale.io
```  
## Group variables
```
[webserver]
ws01.fale.io
ws02.fale.io
[webserver:vars]
https_enabled=True
[database]
db01.fale.io
```  

# 3. Working with iterates in Ansible

Hãy để ý rằng, chúng ta chưa dùng vòng lặp, nếu mà ta phải viết đi viết lại code mà thực hiện task như nhau thì thật mệt. Ví dụ:  
```
- name: Ensure HTTP can pass the firewall
firewalld:
service: http
state: enabled
permanent: True
immediate: True
become: True
- name: Ensure HTTPS can pass the firewall
firewalld:
service: https
state: enabled
permanent: True
immediate: True
become: True
```  
Như ta thấy 2 task này cùng thực hiện nhiệm vụ là mở cổng firewall mà phải viết đến 2 lần.

## 3.1. Standard iteration - with_items

Để cải thiện code trên, ta dùng vòng lặp: with_items.

```
- name: Ensure the HTTPd service is enabled and running
service:
name: httpd
state: started
enabled: True
become: True
- name: Ensure HTTP and HTTPS can pass the firewall
firewalld:
service: '{{ item }}'
state: enabled
permanent: True
immediate: True
become: True
with_items:
- http
- https
```  

Như ta thấy thì mục {{ item }} sẽ được thay thế bằng danh sách item trong `with_items` bến dưới.  

## 3.2. Nested loops - with_nested

Đôi khi, chúng ta cũng phải lặp với tất cả các item có trong nhiều list dài. Ví dụ: 
```
- hosts: all
remote_user: ansible
vars:
users:
- alice
- bob
folders:
- mail- public_html
tasks:
- name: Ensure the users exist
user:
name: '{{ item }}'
become: True
with_items:
- '{{ users }}'
- name: Ensure the folders exist
file:
path: '/home/{{ item.0 }}/{{ item.1 }}'
state: directory
become: True
with_nested:
- '{{ users }}'
- '{{ folders }}'
```  

## 3.3. Fileglobs loop - with_fileglobs
```
---
- hosts: all
remote_user: ansible
tasks:
- name: Ensure the folder /tmp/iproute2 is present
file:
dest: '/tmp/iproute2'
state: directory
become: True
- name: Copy files that start with rt to the tmp folder
copy:
src: '{{ item }}'
dest: '/tmp/iproute2'
remote_src: True
become: True
with_fileglob:
- '/etc/iproute2/rt_*'
```  

## 3.4. Integer loop - with_sequence
```
---
- hosts: all
remote_user: ansible
tasks:
- name: Create the folders /tmp/dirXY with XY from 1 to 10
file:
dest: '/tmp/dir{{ item }}'
state: directory
with_sequence: start=1 end=10
become: True
```  
