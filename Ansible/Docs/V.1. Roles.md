# Ansible Roles
## Role là gì?

Trong Ansible, Role là một cơ chế để tách 1 playbook ra thành nhiều file. Việc này nhằm đơn giản hoá việc viết các playbook phức tạp và có thể tái sử dụng lại nhiều lần (như keo dính chuột)

**Role không phải là playbook**. Role là **một bộ khung (framework)** để chia nhỏ playbook thành nhiều files khác nhau. Mỗi role là một thành phần độc lập, bao gồm nhiều **_variables, tasks, files, templates, và modules_** bên dưới.

Việc tổ chức playbook theo role cũng giúp người dùng dễ chia sẻ và tái sử dụng lại playbook với người khác. Đặc biệt trong môi trường doanh nghiệp khi có từ vài trăm tới vài ngàn playbook thì Role chính là cách quản lý các playbook này.

Nhưng mà….Role là gì mới được….không phải playbook thì nó là gì…? Mình vẫn chưa hiểu…?

Ok, nói hơi dông dài rồi, trăm nói không bằng một thấy, mình sẽ cung cấp một số ví dụ bên dưới cho các bạn.

### Ví dụ về Role

Sau đây là ví dụ về 1 role đơn giản để cài đặt Prometheus.  
– Trong folder _**./roles/prometheus**_
<img src = "../Images/V.1. Roles/Anh_1.png">  

Một role sẽ có 7 folder với các chức năng khác nhau gồm: _**vars, templates, handlers, files, meta, tasks**_ và _**defaults**_. Mỗi một thư mục cần phải chứa 1 file _**main.yml**_. Trong đó thì tasks thường là folder quan trọng nhất, thường dùng để chứa những playbook

Trong đó:

-   **tasks** – chứa danh sách các task chính được thực thi trong role này.
-   **handlers** – chứa các handler, có thể được dùng trong role này hoặc các role khác.
-   **defaults** – chứa các biến được dùng default cho role này
-   **vars** – chứa thông tin các biến dùng trong role, biến trong vars sẽ override biến trong default
-   **files** – chứa các file cần dùng để deploy trong role này, cụ thể như file binary, file cài đặt…
-   **templates** – chứa các file template theo jinja format đuôi ***.j2** (có thể là file config, file systemd…).
-   **meta** – định nghĩa 1 số metadata của role này, như là dependencies

Một role phải chứa **ít nhất 1** trong 7 thư mục này để Ansible có thể hiểu được đó là 1 role. Nếu có những thư mục nào không cần dùng thì ta có thể bỏ ra. Thường thì mình hay dùng nhất là các thư mục _**tasks, vars, templates, files**_. Ngoài ra còn có thêm tests nếu bạn muốn viết unit test cho playbook nhưng không bắt buộc và không nằm trong phạm vi bài viết này.  

```
alertmanager
├── README.md
├── defaults
│   └── main.yml
├── files
│   ├── alertmanager.service
│   └── notifications.tmpl
├── handlers
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
│   └── alertmanager.yml.j2
└── vars
    └── main.yml
```  

Cây thư mục của 1 role

Để dùng 1 role thì ta có thể liệt kê role cần dùng trong 1 play, cụ thể như sau:  

```
---
- name: Setup Monitoring Services
  hosts: prometheus_group
  become: yes
  become_user: root

  roles:
      - prometheus
      - alertmanager
      - pushgateway
```  

Trong ví dụ trên, ta sẽ setup 3 role lần lượt là _**prometheus**_, _**alertmanager**_ và _**pushgateway**_ cho host _**prometheus_group**_

Để dùng role thì ta cần liệt kê role đó trong 1 play. Các lệnh như copy, script, template trong 1 role có thể tham chiếu tới **roles/x/{files,templates,tasks}/** trong role đó mà không cần phải ghi rõ đường dẫn tuyệt đối ra

Một role thường thì cần phải:

-   Chạy được trong check mode **_ansible-playbook –check targets.yml_**
-   Không chạy lại lần 2 nếu playbook không thay đổi (Idempotent!!)
-   Nên dùng lệnh _**assert**_ trong playbook để kiểm tra các điều kiện khi chạy playbook
-   Các file config trong folder template nên dùng lệnh _**validate**_ trước khi copy file
-   Chỉ nên trigger các handler khi file config thay đổi
-   Nên có sẵn nhiều biến trong defaults nhất có thể
-   Dùng một tool _**version control**_ (git, svm…) để theo dõi sự thay đổi của role

## Hướng dẫn viết Role

Sau đây là các bước để viết 1 role trong ansible

1.  Tạo folder role trước, nếu chưa có. Folder này phải có tên là **roles**
2.  Tạo 1 folder trước một role cụ thể, ví dụ như prometheus
3.  Tạo folder tasks để chứa playbook setup prometheus
4.  Tạo folder vars để chứa các biến cần dùng trong khi setup prometheus
5.  Tạo folder files để chứa các file cho role (file .rpm, .deb hoặc file binary…)
6.  Tạo folder handlers để chứa các handler cần thiết
7.  Và cuối cùng nhưng không kém phần quan trọng đó là….viết Readme để dễ dàng chia sẻ role này với mọi người :3

Sau đây là hướng dẫn các bước viết từng folder cụ thể

### Tasks
<img src = "../Images/V.1. Roles/Anh_2.png">  

Tasks là nơi ta viết các bước setup cụ thể cho role của chúng ta. Viết như 1 playbook bình thường.

### Defaults/Vars

Defaults/Vars là nơi để chứa các biến cần thiết cho role. Lưu ý là các biến trong vars sẽ override các biến trong defaults.  
<img src = "../Images/V.1. Roles/Anh_3.png">  

### Templates

Templates là nơi bạn chứa các file config cần điểu chỉnh biến, Ansible sẽ lấy các biến có trong defaults/vars để điền vào file template của các bạn. Dùng folder template bằng module **template**  
<img src = "../Images/V.1. Roles/Anh_4.png">  

Ví dụ ta có file **./vars/main.yml** chứa các biến cần thiết để bỏ vào template.  
```
---

PROMETHEUS_VERSION:  "2.12.0"

RETENTION_TIME:  "90d"

CONSUL_SERVER:  "10.0.0.18"

ALERTMANAGER_SERVER:  "10.0.0.180"

THANOS_TEAM:  "cloudcraft-devops"

THANOS_ENV:  "live"

THANOS_REPLICA_TAG:  "C"
```  

Và đây là file **./templates/prometheus.yml.j2** (chú ý đuôi .j2 để Ansible nhận diện được Jinja template)  

```
global:

external_labels:

thanos_team:  '{{ THANOS_TEAM }}'

thanos_env:  '{{ THANOS_ENV }}'

replica:  '{{ THANOS_REPLICA_TAG }}'

scrape_interval:  15s

evaluation_interval:  15s

scrape_configs:

-  job_name:  prometheus

file_sd_configs:

-  files:

-  targets/*.json

-  targets/*.yml

refresh_interval:  5m

-  job_name:  pushgateway

honor_labels:  true

file_sd_configs:

-  files:

-  pushgw_targets/*.json

refresh_interval:  5m

-  job_name:  test-sd

consul_sd_configs:

-  server:  '{{ CONSUL_SERVER }}:8500'
```  

### Files

Ta dùng module copy trong playbook để copy các file cần thiết trong folder files mà không cần phải liệt kê đường dẫn tuyệt đối ra (Ansible tự nhận diện đường dẫn).  

<img src = "../Images/V.1. Roles/Anh_5.png">  

### Handlers

Handlers dùng để trigger một số thao tác như reload/restart/start stop service khi thực hiện một task nào đó trong playbook bằng lệnh **notify**  

<img src = "../Images/V.1. Roles/Anh_6.png">  

### Meta

Chứa các thông tin về metadata của role, thường chỉ dùng khi bạn publish role của mình lên Ansible Galaxy. Đây là một nơi mọi người upload và chia sẻ các role mình viết được. Coi thêm tại: [https://galaxy.ansible.com/](https://galaxy.ansible.com/)  

### Readme

Nơi chứa các thông tin cần thiết để người khác có thể hiểu và sử dụng lại role của bạn/  

<img src = "../Images/V.1. Roles/Anh_7.png">  

Mặc định thì ansible sẽ kiếm role mà các bạn đã viết trong folder _**/etc/ansible/roles**_. Hoặc nếu bạn chạy playbook tại _**/home/cloudcraft/run_task.yml**_ và trong file playbook này có gọi 1 số roles, Ansible sẽ dò các role cần dùng trong _**/home/cloudcraft/roles**_. Nếu không có thì Ansible mới dò trong _**/etc/ansible/roles**_
