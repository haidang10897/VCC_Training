# Handling Complex Deployment

# 1. Working with conditionals

Giả sử ta có điều kiện như sau:  
```
If os = "redhat"
Install httpd
Else if os = "debian"
Install apache2
End
```  

Trong playbook, ta sẽ viết như sau:  
```
- hosts: webserver
remote_user: ansible
tasks:
- name: Print the ansible_os_family value
debug:
msg: '{{ ansible_os_family }}'
- name: Ensure the httpd package is updated
yum:
name: httpd
state: latest
become: True
when: ansible_os_family == 'RedHat'
- name: Ensure the apache2 package is updated
apt:
name: apache2
state: latest
become: True
when: ansible_os_family == 'Debian'
```  
Kết quả sẽ như sau:  
<img src = "../Images/V. Handling complex deployment/Anh_1.png">  

## 1.1. Boolean conditionals
```
---
- hosts: all
remote_user: ansible
vars:
backup: True
tasks:
- name: Copy the crontab in tmp if the backup variable is true
copy:
src: /etc/crontab
dest: /tmp/crontab
remote_src: True
when: backup
```  
Ở code trên sẽ luôn thực thi vì giá trị backup là true.  
Giờ nếu ta thay đổi giá trị backup là `false` thì task sẽ skip không thực thi nữa.  

## 1.2. Checking if a variable is set

```
---
- hosts: all
remote_user: ansible
vars:
backup: True
tasks:
- name: Check if the backup_folder is set
fail:
msg: 'The backup_folder needs to be set'
when: backup_folder is not defined
- name: Copy the crontab in tmp if the backup variable is true
copy:
src: /etc/crontab
dest: '{{ backup_folder }}/crontab'
remote_src: True
when: backup
```  

với đoạn code này, ta thêm code như dưới, với cách này thì ta sẽ bắt buộc phải set biến backup_folder thì playbook mới thực thi task.  
```
fail:
msg: 'The backup_folder needs to be set'
when: backup_folder is not defined
```  

# 2. Working with include

`Include` giúp ta đơn giản hóa khi viets task. Để thực hiện một playbook trong 1 file khác, ta chỉ cần thêm dòng sau:  
```
include: FILENAME.yaml
```  
Ta cũng có thể truyền tham số vào included file bằng cách sau:  
```
include: FILENAME.yaml variable1="value1" variable2="value2"
```  
Ví dụ:
```
- name: Include the file only for Red Hat OSes
include: redhat.yaml
when: ansible_os_family == "RedHat"
```  

# 3. Working with handlers
Trong nhiều trường hợp, sau khi thực hiện các task xong, ta phải trigger 1 event nào đó xong thì dịch vụ đó mới có tác dụng. Ví dụ khi ta thay đổi config 1 dịch vụ nào đó thì phải restart xong mới tác dụng.  

Ví dụ dưới đây ta sẽ upgrade Httpd và cuối cùng sẽ trigger sự kiện khởi động lại dịch vụ để dịch vụ có thể hoạt động bình thường.  
```
- name: Ensure HTTPd configuration is updated
copy:
src: website.conf
dest: /etc/httpd/conf.d
become: True
notify: Restart HTTPd
handlers:
- name: Restart HTTPdservice:
name: httpd
state: restarted
become: True
```  
# Tài liệu tham khảo 
https://cloudcraft.info/ansible-huong-dan-su-dung-va-quan-ly-role-trong-ansible/


