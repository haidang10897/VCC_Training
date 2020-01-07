# Giới thiệu OpenStack

# I. **Ảo hóa (Virtualization)**

Đa số khi nói đến Virtualization thì mọi người đều hiểu là Ảo hóa. Ảo hóa là kỹ thuật tạo ra phần cứng, thiết bị mạng, thiết bị lưu trữ,… ảo – không có thật (cũng có thể là giả lập hoặc mô phỏng). Hiểu đơn giản thì là nhìn thấy nhưng không sờ được, cầm được.

Đi kèm với Ảo hóa thường có các cụm từ _Hardware Virtualization, Platform Virtualization_: các cụm từ này ám chỉ việc tạo ra các thành phần phần cứng (ảo) để tạo ra các máy ảo (_Virtual Machine_), chúng gần như có đầy đủ các thành phần như máy vật lý (physical machine ) và có thể cài đặt hệ điều hành (Linux, Windows,….) trong network thì có thể có các Router ảo và Switch ảo. Tất nhiên người dùng có thể sử dụng và khai thác được các máy ảo, thiết bị ảo này. Thường gặp nhất trong hiện tại có thể là khi các bạn học về Microsoft, Cisco, Juniper,… cần sử dụng các chương trình giả lập, hay phần mềm để tạo ra các thiết bị ảo này.

Nếu đứng trên góc độ của người dùng thì có vài điểm lợi sau:

-   Tiết kiệm: Kỹ thuật ảo hóa giúp tiết kiệm tiền bạc và tận dụng được tài nguyên phần cứng. Ví dụ khi cần có một máy tính chạy hệ điều hành, thay vì mua thì ta có thể cài đặt và tạo ra các máy ảo trên máy vật lý của chúng ta.
-   Linh hoạt trong khi sử dụng: Với các phần mềm để tạo ra các máy ảo, bạn có thể tạo, xóa, hủy các máy ảo này một cách nhanh chóng và tiện lợi (tùy các nền tảng khác nhau và kỹ năng sử dụng của người dùng khác nhau).
-   Nhanh chóng và thuận tiện: Đối với các môi trường thử nghiệm và phòng thí nghiệm thì kỹ thuật ảo hóa giúp sao lưu và khôi phục hệ thống, khôi phục máy ảo nhanh chóng và thuận tiện.

# II. Cloud Computing
Điện toán đám mây là bước kế tiếp của Ảo hóa. Ảo hóa phần cứng, ảo hóa ứng dụng. là thành phần quản lý và tổ chức, vận hành các hệ thống ảo hóa trước đó.

Để hiểu rõ thì chúng ta cần nắm được 5 – 4 – 3 trong Cloud Computing: đó là 5 đặc tính, 4 mô hình dịch vụ và 3 mô hình triển khai.

**_5 đặc điểm:_**

-   Khả năng thu hồi và cấp phát tài nguyên (Rapid elasticity)
-   Truy nhập qua các chuẩn mạng (Broad network access)
-   Dịch vụ sử dụng đo đếm được (Measured service,) hay là chi trả theo mức độ sử dụng pay as you go.
-   Khả năng tự phục vụ (On-demand self-service).
-   Chia sẻ tài nguyên (Resource pooling).

**_4 mô hình dịch vụ (mô hình sản phẩm):_**

-   Public Cloud: Đám mây công cộng (là các dịch vụ trên nền tảng Cloud Computing để cho các cá nhân và tổ chức thuê, họ dùng chung tài nguyên).
-   Private Cloud: Đám mây riêng (dùng trong một doanh nghiệp và không chia sẻ với người dùng ngoài doanh nghiệp đó)
-   Community Cloud: Đám mây cộng đồng (là các dịch vụ trên nền tảng Cloud computing do các công ty cùng hợp tác xây dựng và cung cấp các dịch vụ cho cộng đồng).
-   Hybrid Cloud: Là mô hình kết hợp (lai) giữa các mô hình Public Cloud và Private Cloud.

**_3 mô hình triển khai: tức là triển khai Cloud Computing để cung cấp:_**

-   Hạ tầng như một dịch vụ (Infrastructure as a Service)
-   Nền tảng như một dịch vụ (Platform as a Service)
-   Phần mềm như một dịch vụ (Software as a Service)

# III. OpenStack
OpenStack là một phần mềm mã nguồn mở, dùng để triển khai Cloud Computing, bao gồm private cloud và public cloud (_Open source software for building private and public clouds)_

OpenStack được giới thiệu trên trang chủ  [http://openstack.org](http://openstack.org/)  như sau:

_OpenStack is a cloud operating system that controls large pools of compute, storage, and networking resources throughout a datacenter, all managed through a dashboard that gives administrators control while empowering their users to provision resources through a web interface._

Hình minh họa về vị trí của OpenStack trong thực tế như sau:

![openstack-software-diagram](https://netsa.vn/wp-content/uploads/2016/04/openstack-software-diagram.png)

-   Phía dưới là phần cứng máy chủ đã được ảo hóa để chia sẻ cho ứng dụng, người dùng
-   Trên cùng là các ứng dụng của bạn, tức là các phần mềm mà bạn sử dụng
-   Và OpenStack là phần ở giữa 2 phần trên, trong OpenStack có các thành phần, module khác nhau nhưng trong hình có minh họa các thành phần cơ bản như Dashboard, Compute, Networking, API, Storage …

Sau đây, chúng tôi sẽ nêu một số thông tin vắn tắt về OpenStack:

-   OpenStack là một dự án mã nguồn mở dùng để triển khai private cloud và public cloud, nó bao gồm nhiều thành phần (tài liệu tiếng anh gọi là Project) do các công ty, tổ chức, lập trình viên tự nguyện xây dựng và phát triển.
-   Có 3 nhóm chính tham gia: Nhóm điều hành, nhóm phát triển và nhóm người dùng.
-   OpenStack hoạt động theo hướng mở: Công khai lộ trình phát triển, công khai mã nguồn …
-   Tháng 10/2010 Rackspace và NASA công bố phiên bản đầu tiên của OpenStack, có tên là OpenStack Austin, với 2 thành phần chính (Project) : Compute (tên mã là Nova) và Object Storage (tên mã là Swift)
-   Các phiên bản OpenStack có chu kỳ 6 tháng. Tức là 6 tháng một lần sẽ công bố phiên bản mới với các tính năng bổ sung.
-   Tính đến nay có 13 phiên bản của OpenStack bao gồm: Austin, Bexar, Cactus, Diablo, Essex, Folsom, Grizzly, Havana, Icehouse, Juno, Kilo, Liberty, Mitaka.
-   Tên các phiên bản được bắt đầu theo thứ tự A, B, C, D …trong bảng chữ cái.
-   Các thành phần (Project) có tên và có mã dự án đi kèm, với Havana gồm 9 thành phần sau:
    -   Compute (code-name Nova)
    -   Networking (code-name Neutron)
    -   Object Storage (code-name Swift)
    -   Block Storage (code-name Cinder)
    -   Identity (code-name Keystone)
    -   Image Service (code-name Glance)
    -   Dashboard (code-name Horizon)
    -   Telemetry (code-name Ceilometer)
    -   Orchestration (code-name Heat)
    - 
# Tài liệu tham khảo
[https://support.bizflycloud.vn/knowledge-base/openstack-la-gi-va-de-lam-gi/](https://support.bizflycloud.vn/knowledge-base/openstack-la-gi-va-de-lam-gi/)
https://vietstack.wordpress.com/2014/02/15/openstack-la-gi-va-de-lam-gi/

https://www.openstack.org/software/
