# II. Tổng quan các thành phần của Ansible

# 1. YAML

Chúng ta hãy xem các tập tin YAML là gì. Hầu như tất cả playbooks trong Ansible được viết bằng YAML. Nếu bạn đã quen thuộc với YAML, hãy bỏ qua phần này và chuyển sang phần tiếp theo. Nếu bạn chưa từng làm việc với YAML thì khuyên bạn nên xem phần này kỹ một xíu bởi vì các phần còn lại hầu như phụ thuộc hoàn toàn vào YAML.  Playbook Ansible được viết theo định dạng cụ thể được gọi là YAML.  Nếu bạn đã làm việc với các định dạng cấu trúc dữ liệu khác như XML hoặc JSON, bạn sẽ có thể dễ dàng học nó.  Cũng đừng lo lắng nếu bạn chưa biết gì, vì nó thật sự rất đơn giản. File YAML được dùng để thể hiện dữ liệu. Dưới đây là so sánh nhanh dữ liệu mẫu ở ba định dạng khác nhau.  
<img src = "../Images/II. Tổng quan các thành phần của Ansible/Anh_1.png">  

Bên trái là dạng XML - hiển thị danh sách các máy chủ và thông tin của chúng. Cùng dữ liệu đó thì hình ở giữa được thể hiện dạng JSON và cuối cùng ở định dạng YAML ở bên phải.  
  
Trong YAML có 3 kiểu để biểu diễn giá trị.  
<img src = "../Images/II. Tổng quan các thành phần của Ansible/Anh_2.png">  

### Key Value Pair (Cặp khoá vs giá trị):  
Dữ liệu được thể hiện bởi kiểu khoá và giá trị (key và value). Trong YAML, khóa và giá trị được phân tách bằng dấu hai chấm (:). Luôn phải có khoảng trắng theo sau dấu hai chấm.  
  
###  Mảng trong YAML:  
Các phần tử trong mảng sẽ được thể hiện bởi dấu gạch ngang ( - ). Cần có khoảng trắng trước mỗi mục. Số lượng khoảng trắng cần bằng nhau trước các phần tử của một mảng. Chúng ta hãy xem xét kỹ hơn về các dấu khoảng trắng trong YAML.  

### Dạng dict trong YAML:  
Dạng này chỉ cần biểu diễn khoảng trắng trước các thuộc tính của object. Điểm khác biệt của dạng Dict và Array là các thuộc tính liệt kê dạng dict thì không có thứ tự. Trong khi Array thì ngược lại. Nên là ví dụ bạn khai báo như:  
```
Tasks:
  - install httpd
  - start httpd
```  
sẽ khác với:  

```
Tasks:
  - start httpd
  - install httpd
```  

# 2. PLAYBOOKS
Trong playbooks, chúng ta sẽ xác định những gì cần phải làm. Hay nói cách khác là nơi ta sẽ viết kịch bản cho các con server. Playbooks sẽ được viết bằng định dạng YAML. Nên là các bạn cần đảm bảo đọc hiểu được nội dung của cách viết trong YAML nhé.  Trong playbooks sẽ chứa một tập hợn các activities (hoạt động) hay các tasks (nhiệm vụ) sẽ được chạy trên một hay một nhóm servers.  Trong đó task là một hành động duy nhất được thực hiện trên server, ví dụ như cài gói service nào đó, hay bật tắt service.  
Xem thử ví dụ một playbook đơn giản:

```
# Simple Ansible Playbook1.yml
-
  name: Play 1
  hosts: localhost
  tasks:
    - name: Execute command "date"
      command: date
    - name: Execute script on server
      script: test_script.sh
    - name: Install httpd service
      yum:
        name: httpd
        state: present
    - name: Start web server
      service:
        name: httpd
        state: started

```

Trên đây là một playbook đơn giản chứa một kịch bản có tên Play 1 (name: Play 1).  
Kịch bản này sẽ được chạy trên server localhost (hosts: localhost). Nếu bạn muốn thực hiện cùng các nhiệm vụ đó trên nhiều con server thì bạn chỉ cần liệt kê tên server hay tên group server. Khai báo tên server hay group server sẽ nằm trong phần inventory nhé.  
Có tổng cộng 4 nhiệm vụ cần được chạy cho server. Nhiệm vụ lần lượt là:

-   chạy lệnh date
-   chạy file test_script.sh
-   cài đặt dịch vụ httpd
-   start dịch vụ httpd vừa cài trên

Các tasks trong playbooks được liệt kê dạng array. Phần trên đã có nói đến, nếu đổi chỗ thứ tự các tasks thì sẽ gây ảnh hưởng không nhỏ nếu những task đó có mối liên quan với nhau. Như ta thấy task thứ 3 và task thứ 4 có mối liên hệ với nhau. Nếu để task start httpd lên trước task install thì sẽ có lỗi xảy ra nếu server hoàn toàn chưa được cài httpd.  
  
Bạn để ý các thuộc tính command, script, yum, service là những module có sẵn do ansible cung cấp. Module hỗ trợ bạn viết và thực thi các nhiệm vụ một cách đơn giản hơn. Nếu muốn tự tạo một module riêng thì ansible vẫn hỗ trợ và cho phép bạn viết module riêng để chạy bằng python. Ngoài những module đơn giản trên, ansible còn cung cấp hằng trăm module khác, bạn có thể tham khảo thêm ở document của ansible.  
  
[https://docs.ansible.com/](https://docs.ansible.com/)  
  
Để hiểu rõ hơn module có nhiệm vụ gì, bạn thử nhìn vào task thứ 3 là task cài đặt dịch vụ httpd. Bình thưởng trong linux, muốn cài dịch vụ httpd, bạn phải gõ:

```
yum install httpd

```

  
Nhưng trong playbook bạn chỉ cần khai báo tên module và tên dịch vụ, module được khai báo tự khắc sẽ nhận lệnh và tự thực thi việc cài gói httpd theo yêu cầu.  
Cuối cùng, khi bạn đã viết xong một playbook, vậy làm cách nào để chạy nó. Rất đơn giản. Ansible cung cấp cho bạn cú pháp như sau:

```
ansible-playbook 

```

  
Ví dụ file playbook của bạn tên là my_playbook.yml, bạn sẽ run như sau:

```
ansible-playbook my_playbook.yml

```

  
Bên cạnh đó nếu bạn cần trợ giúp gì thì dùng lệnh:

```
ansible-playbook -help
```  

# 3. MODULES

Như đã giới thiệu ở phần trên, ansible cung cấp rất nhiều module, không thể trình bày hết các module trong bài viết này, nên mình sẽ giới thiệu một vài module phổ biến thường dùng cho những thao tác đơn giản.

-   System: Bao gồm các module như User, Group, Hostname, Systemd, Service, v.v...
-   Commands: Thường có module con như Command, Expect, Raw, Script, Shell, v.v...
-   Files: Các module làm việc với file như Copy, Find, Lineinfile, Replace, v.v...
-   Database: Ansbile cũng support mạnh mẽ những module làm việc với DB như Mongodb, Mssql, Mysql, Postgresql, Proxysql, v.v...
-   Cloud: Ansible cũng không quên kết hợp với các dịch vụ clound nổi tiếng như Amazon, Google, Docker, Linode, VMware, Digital Ocean, v.v...
-   Windows: Mạnh mẽ với những module như win_copy, win_command, win_domain, win_file, win_shell

Và còn hàng trăm module khác đã được ansible cung cấp sẵn.

# 4. INVENTORY

Đây là nơi sẽ chứa tên các con server hay địa chỉ ip mà bạn muốn thực thi. Nhìn lại file playbook ở trên, thì trong file playbook sẽ có 1 thuộc tính là hosts, đấy chính là nơi khai báo tên server. Bây giờ thử xem file inventory đơn giản:

```
#Sample Inventory File
Server1.company.com
Server2.company.com 

[mail]
Server3.company.com 
Server4.company.com 

[db]
Server5.company.com 
Server6.company.com 

[web]
Server7.company.com
Server8.company.com 

[all_servers:children]
mail
db
web

```

  
Bạn để ý cách khai báo với [mail], [db], [web]. Đây là cách khai bao 1 group các server với nhau. [mail] là tên group. Trong playbook, nếu bạn muốn file playbook đó sẽ thực thi group các server liên quan đến web, bạn chỉ cần khai báo

```
hosts: web

```

  
Còn [all_servers:children] là cách khai báo group các group với nhau.  
  
Bên cạnh đó, Ansible còn cung cấp một số params phục vụ cho việc truy cập vào server mà bạn đã khai báo trong inventory file dễ dàng hơn. Cụ thể như server nào đó muốn truy cập vào cần cung cấp user và password, hay server đó không phải là linux mà là window, thì việc login vào cũng có phần khác. Xem ví dụ để hiểu thêm về các params mà ansible đã cung cấp nhé.

```
#Sample Inventory file

# Web Servers
web_node1 ansible_host=web01.xyz.com ansible_connection=winrm ansible_user=administrator ansible_password=Win$Pass
web_node2 ansible_host=web02.xyz.com ansible_connection=winrm ansible_user=administrator ansible_password=Win$Pass
 
# DB Servers
sql_db1 ansible_host=sql01.xyz.com ansible_connection=ssh ansible_user=root ansible_ssh_pass=Lin$Pass
sql_db2 ansible_host=sql02.xyz.com ansible_connection=ssh ansible_user=root ansible_ssh_pass=Lin$Pass


```

  
Đối với server window, Ansible cung cấp kiểu connect là winrm. Bên cạnh đó cách khai báo password cũng khác với Linux. Ở window sẽ sử dụng param ansible_ssh_pass, còn linux là ansible_password. Các bạn lưu ý điều này nhé.

# 5. VARIABLES

Tiếp theo chúng ta sẽ làm quen với biến.  Vậy biến là gì? Cũng giống như các ngôn ngữ lập trình khác, biến được sử dụng để lưu trữ các giá trị và có thể thay đổi giá trị được.  
Xem ví dụ dưới đây để hiểu rõ cách khai báo biến và sử dụng biến trong ansible như thế nào nhé.

```
-
  name: Print car's information
  hosts: localhost
  vars:
    car_model: "BMW M3"
    country_name: USA
    title: "Systems Engineer"
  tasks:
    -
      name: Print my car model
      command: echo "My car's model is {{ car_model }}"

    -
      name: Print my country
      command: echo "I live in the {‌{ country_name }}"

```

  
Để khai báo biến, chúng ta sẽ sử dụng thuộc tính vars mà ansible đã cung cấp.  
car_model sẽ là key, "BMW M3" sẽ là value. Bên dưới để sử dụng biến car_model ta sử dụng cặp dấu ngoặc nhọn và tên biến {{ car_model }}

# 6. CONDITIONS

Ansible cũng cho phép bạn điều hướng lệnh chạy hay giới hạn phạm vi để run câu lệnh nào đó. Nói khác đi là nếu điều kiện thoả thì câu lệnh đó mới được thực thi. Bây giờ ta thử giải một đề bài toán như sau: Nếu tuổi trên 22 thì in ra màn hình là "Tôi đã tốt nghiệp" và ngược lại nếu tuổi dưới 22 thì in là "Tôi chưa tốt nghiệp". Lúc này chúng ta sẽ sử dụng thuộc tính when mà ansible cung cấp để giới hạn phạm vi chạy của câu lệnh.

#Simple playbook.yml `-
  name: Toi da tot nghiep chưa
  hosts: localhost
  vars:
    age: 25
  tasks:
    -
      command: echo "Toi chua tot nghiep"
      when: age < 22          
    -                     
      command: echo "Toi da tot nghiep"                     
      when: age >= 22` 

  
■ register  
Ansible còn cung cấp một thuộc tính khá mạnh mẽ là register. Register giúp nhận kết quả trả về từ một câu lệnh. Sau đó ta có thể dùng kết quá trả về đó cho những câu lệnh chạy sau đó.  
  
Ví dụ ta có bài toán như sau: kiểm tra trạng thái của service httpd, nếu start thất bại thì gửi mail thông báo cho admin.

```
#Sample ansible playbook.yml
-
  name: Check status of service and email if its down
  hosts: localhost
  tasks:
    - command: service httpd status
      register: command_output

    - mail:
        to: Admins 
        subject: Service Alert
        body: "Service is down"
      when: command_output.stdout.find("down") != -1
```  

Nhờ vào thuộc tính register, kết quả trả về sẽ được chứa vào biến command_output. Từ đó ta sử dụng tiếp các thuộc tính của biến command_output là stdout.find để tìm chữ "down" có xuất hiện trong nội dung trả về không. Nếu không tìm thấy thì kết quả sẽ là -1.

#  7. LOOPS

Bạn còn nhớ module yum không. Module yum trong ansible playbook giúp ta cài đặt hay xoá một gói service nào đó. Trong ví dụ ở phần playbook, chúng ta chỉ có cài một gói service. Nhưng nếu server yêu cầu cài thêm nhiều gói service khác như mysql, php thì sao nhĩ. Như bình thường chúng ta sẽ viết như sau:

```
# Simple Ansible Playbook1.yml
-
  name: Install packages
  hosts: localhost
  tasks:
    - name: Install httpd service
      yum:
        name: httpd
    - name: Install mysql service
      yum:
        name: mysql
    - name: Install php service
      yum:
        name: php

```

  
Ở đây mới ví dụ 3 service cần cài mà phải viết lập lại các thuộc tính name, module yum đến 3 lần. Nếu server cần cài lên đến 100 gói service thì việc ngồi copy/paste cũng trở nên vấn đề đấy. Thay vào đó, chúng ta sẽ sử dụng chức năng loops mà ansible đã cung cấp để để viết.

```
#Simple Ansible Playbook1.yml
-
  name: Install packages
  hosts: localhost
  tasks:
    - name: Install all service
      yum: name="{{ item }}" state=present
      with_items:
        - httpd
        - mysql
        - php

```

  
with_items là một lệnh lặp, thực thi cùng một tác vụ nhiều lần. Mỗi lần chạy, nó lưu giá trị của từng thành phần trong biến item.

# 8. ROLES

Nếu bạn có nhiều server hay nhiều group server và mỗi server thực thiện những tasks riêng biệt. Và khi này nếu viết tất cả vào cùng một file playbook thì khá là xấu code và khó để quản lý. Ansible đã cung cấp sẵn chức năng roles, về đơn giản nó sẽ giúp bạn phân chia khu vực với nhiệm vụ riêng biệt.  
  
Ví dụ bạn có một kịch bản như bên dưới:

```

#Simple Ansible setup_application.yml
-
  name: Set firewall configurations
  hosts: web
  vars:
    http_port: 8081
    snmp_port: 160-161
    inter_ip_range: 192.0.2.0
    
  tasks:
    - firewalld:
        service: https
        permanent: true
        state: enabled
    - firewalld:
        port: "{{ http_port }}"/tcp
        permanent: true
        state: disabled
    - firewalld:
        port: "{{ snmp_port }}"/udp
        permanent: true
        state: disabled
    - firewalld:
        source: "{{ inter_ip_range }}"/24
        zone: internal
        state: enabled

```

  
Mục tiêu của file playbook setup_application.yml này là cấu hình tường lửa cho group server về web. Bây giờ chúng ta sẽ cắt nhỏ file playbook này ra thành những file có chức năng riêng biệt như file chỉ chưa định nghĩa biến, hay file chứa định nghĩa tasks. Trước khi cắt file playbook nhỏ gọn lại, ta cần tạo cấu trúc thư mục như sau để ansible nhận biết được các thành phần ta đã khai báo.

<img src = "../Images/II. Tổng quan các thành phần của Ansible/Anh_3.png">  

