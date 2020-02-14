# Sử dụng keystone cơ bản để liệt kê ra users, projects, domains,... có trong openstack

# Mục lục
- [Lấy Token](#token)
- [I. Liệt kê ra các thông tin.](#I)
  - [1. Liệt kê các users](#1)
  - [2. Liệt kê Projects](#2)
  - [3. Liệt kê Groups](#3)
  - [4. Liệt kê Roles](#4)
  - [5. Liệt kê Domains](#5)
- [II. Tạo domain, project](#II)
  - [1. Tạo một domain mới](#a)
  - [2. Tạo một project bên trong domain đã tạo](#b)
  - [3. Tạo User trong domain](#c)
  - [4. Gán quyền cho user](#d)
---

# Chuẩn bị
## Khai báo biến
Để sử dụng các lệnh với keystone, khai báo các biến môi trường để thuận lợi trong việc xác thực

```sh
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=haidang
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```
Lưu file này lại và khi dùng thì gõ ". rc.admin"

<a name=token></a>

## Lấy Token
-  Sau khi khai báo các biến môi trường, chúng ta chỉ cần dùng lệnh `openstack token issue` là có thể lấy token về.

  ```sh
  root@controller:~# openstack token issue
  +------------+-------------------------------------------------------------------------------------------------------------------------------------+
  | Field      | Value                                                                                                                               |
  +------------+-------------------------------------------------------------------------------------------------------------------------------------+
  | expires    | 2017-04-28T04:19:17+0000                                                                                                            |
  | id         | gAAAAABZArS1Qgi_MMYf6J4odgU-tU9eoBfD44Ob149egIzNrK_XpnovPkzh9xWp0wWiR4BDM-Vke76EFmk7dDoFtXIQtVksde-                                 |
  |            | 8uCJSgDJNIVAsgW_pLVR28qQ3DHIhSrcRXHGw8MLSdhMyPJjJrDYqKKhNh6iczBnLN4k9YoB3A52IZUrP9ug                                                |
  | project_id | 1667a274e14647ec8f2c0dd593e661de                                                                                                    |
  | user_id    | 3ce3ca843dc7458bb61c851d3a654b8b                                                                                                    |
  +------------+-------------------------------------------------------------------------------------------------------------------------------------+

  ```


<a name=I></a>
## I. Liệt kê ra các thông tin.
<a name=1></a>
### 1. Liệt kê các users
Trong quá trình cài đặt openstack, chúng ta đã tạo một số user trùng tên với từng dịch vụ. Dùng lệnh `openstack user list` để liệt kê ra danh sách các user có trong openstack.

  ```sh
  root@controller:~# openstack user list
  +----------------------------------+-----------+
  | ID                               | Name      |
  +----------------------------------+-----------+
  | 0dbfa2b697d24b0cb3aaad815d72799a | nova      |
  | 116522ee479c4cc7a7dc9c81691d5a9b | demo      |
  | 3ce3ca843dc7458bb61c851d3a654b8b | admin     |
  | 9424c28abcbd494bb2cd241184dffec7 | placement |
  | f00f9e4d49d54cbca319d9075e502127 | neutron   |
  | fe1d690b18df406d9b2aa500ce808346 | glance    |
  +----------------------------------+-----------+
  ```

<a name=2></a>
### 2. Liệt kê Projects

- Để liệt kê ra các project, đơn giản chỉ cần dùng lệnh `openstack project list`.
  ```sh
  root@controller:~# openstack project list
  +----------------------------------+---------+
  | ID                               | Name    |
  +----------------------------------+---------+
  | 142a2e061eac4845beefc265b037ddea | service |
  | 1667a274e14647ec8f2c0dd593e661de | admin   |
  | f102c6f6308e4e7ba5378954363c7ad6 | demo    |
  +----------------------------------+---------+
  ```


<a name=3></a>
### 3. Liệt kê Groups

- Dùng lệnh `openstack group list`


<a name=4></a>
### 4. Liệt kê Roles
- dùng lệnh
  ```sh
  root@controller:~# openstack role list
  +----------------------------------+----------+
  | ID                               | Name     |
  +----------------------------------+----------+
  | 846e4b17fde047e98c13ca941f9b0d3b | user     |
  | 9577b0c1837b430cabfd7d20e548e8fe | admin    |
  | 9fe2ff9ee4384b1894a90878d3e92bab | _member_ |
  +----------------------------------+----------+
  ```

<a name=5></a>
### 5. Liệt kê Domains
- dùng lệnh
  ```sh
  root@controller:~# openstack domain list
  +---------+---------+---------+--------------------+
  | ID      | Name    | Enabled | Description        |
  +---------+---------+---------+--------------------+
  | default | Default | True    | The default domain |
  +---------+---------+---------+--------------------+
  ```


<a name=II></a>
## II. Tạo domain, project
<a name=a></a>
### 1. Tạo một domain mới
- Dùng lệnh
  ```sh
  root@controller:~# openstack domain create new_domain
  +-------------+----------------------------------+
  | Field       | Value                            |
  +-------------+----------------------------------+
  | description |                                  |
  | enabled     | True                             |
  | id          | 9cbb9d6749f14776bb6c3e4a10e1469b |
  | name        | new_domain                       |
  +-------------+----------------------------------+
  ```

<a name=b></a>
### 2. Tạo một project bên trong domain đã tạo
- Dùng lệnh, tạo project trong domain `new_domain`
  ```sh
  root@controller:~# openstack project create --domain new_domain --description "New project in domain new_domain" new_project
  +-------------+----------------------------------+
  | Field       | Value                            |
  +-------------+----------------------------------+
  | description | New project in domain new_domain |
  | domain_id   | 9cbb9d6749f14776bb6c3e4a10e1469b |
  | enabled     | True                             |
  | id          | 67fb750b2923427fb7631c7267a42ebe |
  | is_domain   | False                            |
  | name        | new_project                      |
  | parent_id   | 9cbb9d6749f14776bb6c3e4a10e1469b |
  +-------------+----------------------------------+
  ```


<a name=c></a>
### 3. Tạo User trong domain
- Dùng lệnh để tạo
  ```sh
  root@controller:~# openstack user create --domain new_domain --password 123 demo
  +---------------------+----------------------------------+
  | Field               | Value                            |
  +---------------------+----------------------------------+
  | domain_id           | 9cbb9d6749f14776bb6c3e4a10e1469b |
  | enabled             | True                             |
  | id                  | fc9c94e9f7764bbe90b84d2745e7c00d |
  | name                | demo                             |
  | options             | {}                               |
  | password_expires_at | None                             |
  +---------------------+----------------------------------+
  ```


<a name=d></a>
### 4. Gán quyền cho user
- dùng lệnh 

  `openstack role add --project new_project --project-domain new_domain --user demo --user-domain new_domain user`


### 5. Xác thực user `demo` trong domain `new_domain`
- Khai báo các biến môi trường
  ```sh
  export OS_PASSWORD=123 
  export OS_IDENTITY_API_VERSION=3 
  export OS_AUTH_URL=http://10.10.10.61:5000/v3 
  export OS_USERNAME=demo 
  export OS_PROJECT_NAME=new_project
  export OS_USER_DOMAIN_NAME=new_domain 
  export OS_PROJECT_DOMAIN_NAME=new_domain
  ```

- Lấy về token của user demo
  ```sh
  root@controller:~# openstack token issue
  +------------+-------------------------------------------------------------------------------------------------------------------------------------+
  | Field      | Value                                                                                                                               |
  +------------+-------------------------------------------------------------------------------------------------------------------------------------+
  | expires    | 2017-04-28T05:30:24+0000                                                                                                            |
  | id         | gAAAAABZAsVgooJZ1Dcpy52N-vN8Iwln3t-bGupwkLcqCCApv2Mo3LpSbHnJeLaRCfXycT9nDE7U6I6AuYn3c2cx9hp6OveTSWGKGM6_GoQ3kW6Bb5gfWX5C734FiMWvr55 |
  |            | HIFzPMADHTt_YZxL86ZERXPKgLyvTlsHeik0OCqck9lbqJyi7eys                                                                                |
  | project_id | 67fb750b2923427fb7631c7267a42ebe                                                                                                    |
  | user_id    | fc9c94e9f7764bbe90b84d2745e7c00d                                                                                                    |
  +------------+-------------------------------------------------------------------------------------------------------------------------------------+
  ```



