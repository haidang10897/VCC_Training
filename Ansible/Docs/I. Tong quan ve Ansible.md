# I. Tổng quan về Ansible
## Giới thiệu

_**Ansible**_ _đang là công cụ_ _Configuration Management_ _khá nổi bật hiện nay._

-   Là công cụ mã nguồn mở dùng để quản lý cài đặt, cấu hình hệ thống một cách tập trung và cho phép thực thi câu lệnh điều khiển.
-   Sử dụng SSH (hoặc Powershell) và các module được viết bằng ngôn ngữ Python để điểu khiển hệ thống.
-   Sử dụng định dạng JSON để hiển thị thông tin và sử dụng YAML (Yet Another Markup Language) để xây dựng cấu trúc mô tả hệ thống.

## Đặc điểm của Ansible

-   Không cần cài đặt phần mềm lên các agent, chỉ cần cài đặt tại master.
-   Không service, daemon, chỉ thực thi khi được gọi
-   Bảo mật cao ( do sử dụng giao thức SSH để kết nối )
-   Cú pháp dễ đọc, dễ học, dễ hiểu

##  Kiến trúc
<img src = "../Images/I. Tong quan ve Ansible/Anh_1.png">  

Ansible sử dụng kiến trúc agentless để giao tiếp với các máy khác mà không cần agent. Cơ bản nhất là giao tiếp thông qua giao thức SSH trên Linux, WinRM trên Windows hoặc giao tiếp qua chính API của thiết bị đó cung cấp.  
Ansible có thể giao tiếp với rất nhiều platform, OS và loại thiết bị khác nhau. Từ Ubuntu, CentOS, VMware, Windows cho tới AWS, Azure, các thiết bị mạng Cisco và Juniper.  
Chính cách thiết kế này làm tăng tính tiện dụng của Ansible do không cần phải setup bảo trì agent trên nhiều host. Có thể coi đây là một thế mạnh của Ansible so với các công cụ có cùng chức năng  

## Ứng dụng

Ansible có rất nhiều ứng dụng trong triển khai phần mềm và quản trị hệ thống.

-   **Provisioning:**  Khởi tạo VM, container hàng loạt trong môi trường cloud dựa trên API (OpenStack, AWS, Google Cloud, Azure…)
-   **Configuration Management:** Quản lý cấu hình tập trung các dịch vụ tập trung, không cần phải tốn công chỉnh sửa cấu hình trên từng server.
-   **Application Deployment:**  Deploy ứng dụng hàng loạt, quản lý hiệu quả vòng đời của ứng dụng từ giai đoạn dev cho tới production.
-   **Security & Compliance:**  Quản lý các chính sách về an toàn thông tinmột cách đồng bộ trên nhiều môi trường và sản phẩm khác nhau (deploy policy, cấu hình firewall hàng loạt trên nhiều server…).

## Một số thuật ngữ cơ bản

-   **Controller Machine**: Là máy cài Ansible, chịu trách nhiệm quản lý, điều khiển và gởi task tới các máy con cần quản lý.
-   **Inventory**: Là file chứa thông tin các server cần quản lý. File này thường nằm tại đường dẫn /etc/ansible/hosts.
-   **Playbook**: Là file chứa các task của Ansible được ghi dưới định dạng YAML. Máy controller sẽ đọc các task trong Playbook và đẩy các lệnh thực thi tương ứng bằng Python xuống các máy con.
-   **Task**: Một block ghi tác vụ cần thực hiện trong playbook và các thông số liên quan. Ví dụ 1 playbook có thể chứa 2 task là: yum update và yum install vim.
-   **Module**: Ansible có rất nhiều module, ví dụ như moduel yum là module dùng để cài đặt các gói phần mềm qua yum. Ansible hiện có hơn ….2000 module để thực hiện nhiều tác vụ khác nhau, bạn cũng có thể tự viết thêm các module của mình nếu muốn.
-   **Role**: Là một tập playbook được định nghĩa sẵn để thực thi 1 tác vụ nhất định (ví dụ cài đặt LAMP stack).
-   **Play**: là quá trình thực thi của 1 playbook
-   **Facts**: Thông tin của những máy được Ansible điều khiển, cụ thể là thông tin về OS, network, system…
-   **Handlers**: Dùng để kích hoạt các thay đổi của dịch vụ như start, stop service.  
- 
# Tài liệu tham khảo
Learning Ansible 2 Second Edition  

[https://cloudcraft.info/gioi-thieu-ve-ansible/](https://cloudcraft.info/gioi-thieu-ve-ansible/)  

[https://blog.vietnamlab.vn/2019/01/04/phan-1-ansible-khai-niem-co-ban/](https://blog.vietnamlab.vn/2019/01/04/phan-1-ansible-khai-niem-co-ban/)

