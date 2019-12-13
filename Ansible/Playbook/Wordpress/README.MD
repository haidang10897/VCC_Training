# Deploy Wordpress on Ubuntu 19

Bước 1: Vào file hosts để chỉnh sửa ip, domain các máy cần cài wordpress  
Bước 2: vào roles/wordpress/default/main.yml chỉnh sửa các mục trong phần wordpress thành tài khoản cá nhân  
Bước 3: Ra ngoài thư mục chứa file site.tml chạy playbook  
``` ansible-playbook -i hosts site.yml ```  

# Các lỗi gặp phải khi làm bài này

Khi cai database phai thay doi database root user password khong se gap phai loi "can't connect to database root@localhost"  

ref: https://www.digitalocean.com/community/tutorials/how-to-reset-your-mysql-or-mariadb-root-password  
https://stackoverflow.com/questions/40050219/rootlocalhost-password-set-with-ansible-mysql-user-module-doesnt-work  
https://wordpress.org/support/article/editing-wp-config-php/  

cach sua thu 2 ( ko an toan) : trong module mysql_db, login_password: '' ( khong co password )  



