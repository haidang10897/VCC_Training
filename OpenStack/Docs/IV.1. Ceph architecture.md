﻿# Ceph Architecture and Components

Trong bài viết này, chúng ta sẽ đi tìm hiểu về kiến trúc cũng như các thành phần trong hệ thống lưu trữ Ceph

- Các hệ thống lưu trữ của Ceph
- Ceph storage architecture
-   Ceph RADOS
-   Ceph Object Storage Device (OSD)
-   Ceph monitors (MON)
-   librados
-   The Ceph block storage
-   Ceph Object Gateway

# I. Các hệ thống lưu trữ của Ceph
## I.1 Ceph Object Storage (Hệ thống lưu trữ đối tượng của Ceph)  


Ceph cung cấp khả năng truy cập liên tục tới các Object bằng cách sử dụng ngôn ngữ bản địa: binding hoặc radosgw, giao diện REST tương thích với các ứng dụng được viết cho S3 và Swift.

Thư viện phần mềm của Ceph cung cấp các ứng dụng cho khách hàng với khả năng truy cập trực tiếp tới hệ thống lưu trữ dựa trên RADOS Object và cung cấp một nền tảng cho một số tính năng cao cấp của Ceph, bao gồm RADOS Block Device (RBD), RADOS Gateway và Ceph File System.

## I.2. Ceph Block Storage (Hệ thống lưu trữ khối dữ liệu của Ceph)

RADOS Block Device (RBD) cung cấp truy cập tới trạng thái "block device images", được đồng bộ hóa và sao chép trên toàn bộ storage cluster.

Hệ thống lưu trữ Object của Ceph không giới hạn native binding hoặc RESTful APIs. Người dùng có thể mount Ceph như một lớp cung ứng mỏng Block Device. Khi người dùng viết dữ liệu trên Ceph bằng cách sử dụng Block Device, Ceph tự động hóa đồng bộ và tạo bản sao dữ liệu trên Cluster, RADOS Block Device (RBD) của Ceph cũng tích hợp với Kernel Virtual Machine (KVM), mang lại việc lưu trữ ảo hóa không giới hạn tới KVM chạy trên Ceph client của người dùng.

<img src = "../Images/IV.1. Ceph architecture/1.png">   



## I.3. Ceph File System (Hệ thống lưu trữ file dữ liệu của Ceph)

Ceph cung cấp một POSIX-compliant network file system, nhằm mang lại hiệu suất cao, lưu trữ dữ liệu lớn và tương thích tối đa với các ứng dụng hiện tại.

Object storage system của Ceph cung cấp một số tính năng vượt trội hơn so với nhiều hệ thống lưu trữ Object hiện nay: Ceph cung cấp giao diện File System truyền thống với POSIX. Object storage system là một cải tiến đáng kể, nhưng chúng vẫn còn phải thực hiện nhiều hơn so với các File System truyền thống. Khi các yêu cầu về lưu trữ tăng lên cho các ứng dụng hiện tại, tổ chức cỏ thể cấu hình các ứng dụng hiện tại để sử dụng Ceph File System. Có nghĩa là người dùng có thể chạy một Storage Cluster cho Object, Block và lưu trữ dữ liệu dựa trên File.
# II. Ceph storage architecture

Ceph là giải pháp mã nguồn mở để xây dựng hạ tâng lưu trữ phân tán, ổn định, độ tin cậy và hiệu năng cao cũng như dễ dàng mở rộng. Với hệ thống lưu trữ được điều khiển bằng phần mềm, Ceph cung cấp giải pháp lưu trữ theo object, block và file trong một nền tảng đơn nhất.

Dưới đây là sơ đồ mô tả kiến trúc và các thành phần chính trong hệ thống Ceph.

<img src = "../Images/IV.1. Ceph architecture/2.png">   

<img src = "../Images/IV.1. Ceph architecture/3.png">   

**Reliable Autonomic Distributed Object Store (RADOS)**  là nền tảng của Ceph storage cluster. Mọi dữ liệu trong Ceph đều được lưu dưới dạng các  **object**  và RADOS sẽ chịu trách nhiệm lưu trữ các  **object**  này, bất kể kiểu dữ liệu của chúng. RADOS layer đảm bảo dữ liệu sẽ luôn ở trong trạng thái nhất quán và tin cậy. Để làm được điều này, nó thực hiện replicate dữ liệu, phát hiện lỗi và hồi phục cũng như data migration và rebalancing giữa các node trong cluster.

**Object Storage Device (OSD)**: đây là thành phần duy nhất trong Ceph cluster có nhiệm vụ store data và retrieve khi có một hành động write hoặc read data. Thông thường, một OSD deamon được gắn với một ổ đĩa vật lí.

**Ceph monitors (MONs)**  theo dõi trạng thái của toàn bộ cluster bằng cách duy trì một  **cluster map**  bao gồm OSD, MON, PG, CRUSH và MDS  **map**. Tất cả các node trong cluster gửi thông tin về cho monitor node khi có thay đổi trạng thái. Một monitor duy trì thông tin của mỗi thành phần trong một  **map**  riêng biệt. Monitor node không có nhiệm vụ lưu trữ dữ liệu, đây là nhiệm vụ của OSD.

**librados**: là một thư viện cung cấp các API truy cập tới RADOS hỗ trợ các ngôn ngữ PHP, Ruby, Java, C và C++. Nó cung cấp một native interface tới Ceph storage cluster, RADOS và các services khác như RBD, RGW VÀ CephFS.

**Ceph Block Device**  hay còn gọi là  **RADOS block device (RBD)**  cung cấp giai pháp lưu trữ block storage, có khả năng mapped, formated và mounted như là một ổ đĩa tới server. RDB được trang bị các tính năng lưu trữ doanh nghiệp như  **thin provisioning**  và  **snapshot**.

**Ceph Object Gateway**  hay còn gọi là  **RADOS gateway (RGW)**  cung cấp RESTful API interface, tương thích với Amazon S3 (Simple Storage Service) và Openstack Object Storage API (Swift). RGW cũng hỗ trợ dịch vụ xác thực Openstack Keystone.

# II.1. Ceph RADOS

**RADOS (Reliable Autonomic Distributed Object Store)**  là thành phần trung tâm trong hệ thống Ceph storage, cũng được gọi như  **Ceph storage cluster**. RADOS cung cấp tất cả các tính năng quan trọng trong Ceph, bao gồm distributed object store, high availability, reliablity, no single point of failure, self-healing, self-managing... Các phương thức truy cập dữ liệu của Ceph như RBD, CephFS, RADOSGW và librados , tất cả đều nằm trên top của RADOS layer.

Khi Ceph cluster nhận được yêu cầu  **write**  từ phía client, thuật toán CRUSH tính toán và quyết định vị trí dữ liệu nên lưu trữ trong cluster. Thông tin này sau đó được truyền tới RADOS layer để xử lí tiếp. Dựa vào các ruleset của CRUSH, RADOS phân phối dữ liệu tới tất cả các node trong cluster dưới định dạng các  **object**. Cuối cùng, các  **object**  này được lưu trong các OSD.

RADOS đảm bảo dữ liệu luôn tin cậy. Tại cùng một thời điểm, RADOS replicate các object, tạo ra các bản copy và lưu chúng trong các failure zone khác nhau, tránh lưu chúng trên cùng một failure zone. Ngoài lưu trữ và replicate các object trên toàn bộ cluster, RADOS cũng đảm bảo các object luôn trong trạng thái nhất quán. Trong trường hợp các object không nhất quán, hành động  **recover**  được thực hiện trên các bản sao object còn lại. Hoạt động này được thực hiện tự động và trong suốt với người dùng, cung cấp khả năng self-managing và self-healing cho hệ thống Ceph.

## II.2. Ceph Object Storage Device

Ceph OSD là một trong những thành phần quan trọng nhất trong Ceph storage cluster. Nó lưu trữ  **actual data**  trong các ổ đĩa vật lí trên mỗi node của cluster dưới dạng các object. Phần lớn các công việc bên trọng Cẹph cluster được thực hiện bới Ceph OSD daemon. Chúng ta sẽ đi thảo luận về vai trò và trách nhiệm của Ceph OSD daemon.

Ceph OSD lưu trữ dữ liệu người dùng và trả về cùng một dữ liệu đó khi có yêu cầu của người dùng. Một Ceph cluster bao gồm nhiều OSDs. Bất kì hành động  **read**  hoặc **write **, client đều yêu cầu một  **cluster map**  từ monitors, và sau đó client sẽ trực tiếp tương tác với các OSD trong các hành động  **read/write**  mà không cần sự can thiệp của monitor. Điều này khiến qúa trình trao đổi dữ liệu diễn ra nhanh hơn, client có thế lưu trực tiếp tới OSD mà không cần thêm bất kì lớp xử lí dữ liệu nào.

Ceph cung cấp độ tin cậy cao bằng cách replicate mỗi object trên các node trong cluster, làm chúng có tính sẵn sàng cao và khả năng chống lỗi. Mỗi object trong OSD có một bản  **primary copy**  và một số  **secondary copy**  được phân bố đều trên các OSD. Mỗi OSD vừa đóng vai trò là primary OSD của một số object này, vừa có thể là secondary OSD của một số object khác. Bình thường các secondary OSD nằm dưới sự điều khiển của primary OSD, tuy nhiên chúng vẫn có khả năng trở thành primary OSD.

Trong trường hợp disk failure, Ceph OSD daemon sẽ so sánh với các OSD khác để thực hiện hành động  **recovery**. Trong thời gian này, secondary OSD giữ bản sao của object bị lỗi sẽ được đẩy lên làm primary, đồng thời các bản sao mới sẽ được tạo trong qúa trình recover. Qúa trình này là trong suốt với người dùng.

## II.3. Ceph monitors

Như tên gọi, Ceph monitor chịu trách nhiệm giám sát tình trạng của toàn bộ cluster. Chúng lưu trữ các thông tin quan trọng của cluster, trạng thái của các node và thông tin cấu hình cluster. Các thông tin này được lưu trong  **cluster map**, bao gồm monitor, OSD, PG, CRUSH và MDS  **map**.

-   **Monitor map:**  Lưu thông tin end-to-end của node monitor như Ceph cluster ID, monitor hostname, địa chỉ IP và port, thời gian cuối cùng có sự thay đổi. Để check monitor map, thực hiện command sau:
    
    ```
    # ceph mon dump
    
    ```
    
-   **OSD map:**  Lưu các thông tin chung như cluster ID, thời điểm OSD map được tạo và last-changed. Các thông tin liên quan tới  **pool**  như poll name, poll ID, type, placement group. Nó cũng lưu thông tin của OSD như count, state, weight, last clean interval... Để check OSD map, thực hiện command sau:
    
    ```
    # ceph osd dump
    
    ```
    
-   **PG map:**  Lưu PG version, time stamp, last OSD map epoch, full ratio và chi tiết của mỗi placement group như PG id, state của PG... Để check PG map, thực hiện command sau:
    
    ```
    # ceph pg dump
    
    ```
    
-   **CRUSH map:**  Lưu thông tin về các storage devices, failure domain ( host, rack, row, room, device) và các quy tắc khi lưu trữ dữ liệu .Để check CRUSH map, thực hiện command sau:
    
    ```
    # ceph osd crush dump
    
    ```
    
-   **MDS map:**  Lưu thông tin về MDS map epoch, map creation và modification time, data and metadata pool ID, cluster MDS count, MDS state .Để check MDS map, thực hiện command sau:
    
    ```
    # ceph mds dump
    
    ```
    

Ceph monitor không lưu và phục vụ dữ liệu tới client, thay vào đó nó cập nhật  **cluster map**  tới client cũng như các node trong cluster. Client và các node trong cluster sẽ định kì kiểm tra tới monitor để lấy được cluster map gần nhất.

Monitor là một  **lightweight daemon**, chúng không yêu cầu dùng nhiều tài nguyên. Các node monitor nên có không gian ổ đĩa đủ lớn để lưu cluster logs ( OSD log, MDS log và monitor log). Một Ceph cluster điển hình thường có nhiều hơn một node monitor và số lượng node monitor nên là số lẻ. Yêu cầu tối thiểu node monitor là 1 và số lượng đề nghị là 3. Điều này cung cấp tính sẵn sàng cao cho hệ thống cũng như tránh được vấn đề split brain.

## II.4. The Ceph block storage (RBD)

Block storage là một trong những định dạng phổ biến nhất để lưu trữ dữ liệu. Nó cung cấp giải pháp lưu trữ theo block tới physical hypervisor cũng như virtual machine. Ceph RBD driver được tích hợp với Linux kenel và hỗ trợ QEMU/KVM, cho phép truy cập tới Cẹph block device một cách liền mạch.

<img src = "../Images/IV.1. Ceph architecture/4.png">   

Ceph cũng được tích hợp chặt chẽ với các nền tảng đám mây như Openstack. Các service Cinder và Glance sử dụng Ceph như backend để lưu trữ virtual machine volume và OS images. Các image và volume này là  **thin provisioned**, điều này giúp giảm một lượng đáng kể không gian lưu trữ trong Openstack.

Tính năng copy-on-write và instant cloning của Ceph giúp Openstack tạo ra hàng trăm máy ảo trong thời gian ngắn. RBD cũng hỗ trợ snapshot, lưu trạng thái hiện tại của máy ảo, sử dụng để khôi phục máy ảo ở nhiều thời điểm. RBD sử dụng  **librbd**  để cung cấp khả năng lưu trữ theo block một cách tin cậy, đầy đủ và hướng đối tượng. Khi một client write dữ liệu tới RBD,  **librbd**  map data blocks trong các object và lưu chúng trong Ceph cluster đồng thời replicated chúng trên cluster, do đó cải thiện hiệu năng và độ tin cậy.

## II.5. Ceph Object Gateway (RADOS Gateway)

Ceph Object Gateway là một  **object storage ínterface**  được build trên top của  **librados**  cung cấp các applications sử dụng RESTful gateway tới Ceph Storage Cluster. Ceph Object hỗ trợ 2 ínterface:

1.  S3-compatible: cung cấp chức năng lưu trữ đối tượng với một interface tương thích với đa số RESTful API của Amazon S3.
2.  Swift-compatible: cung cấp chức năng lưu trữ đối tượng với một interface trương thích với đa số Openstack Swift API.

[![enter image description here](https://camo.githubusercontent.com/f9d38c8b8c0536fd1fe32f911b2c2d5a9ed041bd/687474703a2f2f692e696d6775722e636f6d2f397350454851572e706e67)](https://camo.githubusercontent.com/f9d38c8b8c0536fd1fe32f911b2c2d5a9ed041bd/687474703a2f2f692e696d6775722e636f6d2f397350454851572e706e67)

Ceph Object Storage sử dụng Ceph Object Gateway daemon (radosgw) - một máy chủ HTTP để tương tác với Ceph Storage Cluster. S3 và Swift API đều chia sẻ một namespace chung trong Ceph cluster, vì vậy bạn có thể write data từ một API này và retrieve từ API khác.

# Ref
[http://www.idz.vn/2018/06/tong-quan-ve-ceph.html](http://www.idz.vn/2018/06/tong-quan-ve-ceph.html)

[https://longvan.net/cong-nghe-luu-tru-ceph.html](https://longvan.net/cong-nghe-luu-tru-ceph.html)

[https://gist.github.com/vanduc95](https://gist.github.com/vanduc95)


