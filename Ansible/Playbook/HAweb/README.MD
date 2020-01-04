# HA deploy Ver. 2
<img src = "HA-2.png">  

**LƯU Ý: PLAYBOOK NÀY CHỈ ÁP DỤNG MÔ HÌNH TRÊN VÀ CÀI MỚI, NẾU CÀI ĐÈ SẼ MẤT DATA VÀ GÂY LỖI**  

## Hướng dẫn sử dụng

### Folder GLusterfs
Sửa trong phần folder default, lưu ý để đúng interface LAN.  

### Folder keep alived
Sửa trong folder default,  
```
master_interface: interface sẽ gán VIP vào ở master
slave_interface: interface sẽ gán VIP vào ở slave.
percona_master_node: Node master ip
percona_sst_user: user tài khoản sync
percona_sst_pass: pass tài khoản sync
root_user: user root của database 
root_pass: pass root của database
```  
### Folder percona_cluster
Sửa trong default.  
```
percona_bind_address: Lấy địa chỉ IP từ file hosts
percona_bind_interface: đi cùng cái trên, để chọn interface lấy ip

```  
### Folder load_balancer

Vào trong này chỉnh sửa các thông số.  

** Một số thông số cần lưu ý :**

```
name_1: Tên web server 1
name_2: Tên web server 2
name_3: Tên web server 3
ip_1: IP web server 1
ip_2: IP web server 2
ip_3: IP web server 3
```  
### Folder wordpress
Sửa trong default, lưu ý tài khoản root database phải giống config ở phần percona xtradb cluster. Nhớ thay salt.


# Một số lỗi
Note:


- load balancer ko truy cập được: bỏ option: forwardfor  
- file config của mysql nằm ở /etc/mysql/mysqld....  
- để remote mysql cần phải bỏ option bind-address  
- phải thêm option cookie session ở load balancer thì mới ko bị lệch phiên.
- Cài đặt đến 95% lỗi PID hoặc gì đó ( Xem tại Networking/2.1. Cách cài đặt percona xtradb ... )
- Thi thoảng sẽ lỗi percona xtradb cluster lúc cài, cố gắng sửa tay.
- 
# Tài liệu tham khảo
[https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps](https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps)

[https://www.linode.com/docs/uptime/loadbalancing/how-to-use-haproxy-for-load-balancing/](https://www.linode.com/docs/uptime/loadbalancing/how-to-use-haproxy-for-load-balancing/)

Loi khong dong bo DB
https://dba.stackexchange.com/questions/34940/adding-a-user-to-mysql-with-name-fails-with-error-1396

check: https://stackoverflow.com/questions/27606119/make-ansible-check-if-database-is-present-on-a-remote-host

HA deploy  
  
[https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps](https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps)  
  
master master db:  
[http://chichio.com/vi/thanks/c%E1%BA%A5u-h%C3%ACnh-mysql-master-master-replication](http://chichio.com/vi/thanks/c%E1%BA%A5u-h%C3%ACnh-mysql-master-master-replication)  
[https://www.linode.com/docs/databases/mysql/configure-master-master-mysql-database-replication/](https://www.linode.com/docs/databases/mysql/configure-master-master-mysql-database-replication/)  
  
remove:  
[https://oofloo.com/uninstall-mysql-ubuntu/](https://oofloo.com/uninstall-mysql-ubuntu/)  
  
ansible replica  
[https://github.com/VitaliiMichailovich/Ansible-MySQL-Master-Master/blob/master/4.yml](https://github.com/VitaliiMichailovich/Ansible-MySQL-Master-Master/blob/master/4.yml)  
[https://topic.alibabacloud.com/a/managing-mysql-replication-with-ansible_1_41_30026734.html](https://topic.alibabacloud.com/a/managing-mysql-replication-with-ansible_1_41_30026734.html)  
[https://docs.ansible.com/ansible/latest/modules/mysql_replication_module.html](https://docs.ansible.com/ansible/latest/modules/mysql_replication_module.html)  
[https://github.com/ekeih/setup-mysql-slave](https://github.com/ekeih/setup-mysql-slave)