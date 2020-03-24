# Swift
# 1. Giới thiệu

Swift trong bài viết nhắc tới, không phải là ngôn ngữ lập trình cho iOS, cũng không phải tên hiệp hội tổ chức liên ngân hàng quốc tế. Đây là tên 1 project của OpenStack (dự án mã nguồn mở để triển khai Cloud Computing ), theo đó OpenStack sẽ gồm rất nhiều project, tùy thuộc vào mục đích xây dựng hệ thống gì mà sẽ kết hợp sử dụng các project khác nhau. Một số core project:

-   Nova: compute service
-   Neutron: network service
-   Keystone: identity service  
    ...  
    Swift là project cung cấp giải pháp lưu trữ dữ liệu theo kiến trúc Object Storage, giống S3 của Amazon.
    Swift là 1 hệ thống object storage theo kiểu multi tenant
> The OpenStack Object Storage is a multi-tenant object storage system

## 1.1. Multi-tenant
### Multi tenant là gì ?  
<img src = "../Images/II.7. Swift/0.1.png">  
  
Multi-Tenant - Multi-tenancy có nghĩa là một phiên bản duy nhất của phần mềm và cơ sở hạ tầng hỗ trợ của nó phục vụ nhiều khách hàng. Mỗi khách hàng chia sẻ ứng dụng phần mềm và cũng chia sẻ một cơ sở dữ liệu. Dữ liệu của mỗi người khách hàng bị cô lập và vẫn vô hình đối với những khách hàng khác.  
  
### Lợi ích của Multi tenant  
  
Chi phí thấp hơn thông qua tính kinh tế theo quy mô: Với nhiều khách hàng, nhân rộng có ý nghĩa cơ sở hạ tầng ít hơn nhiều so với giải pháp lưu trữ vì khách hàng mới có quyền truy cập vào cùng một phần mềm cơ bản.  
  
Hơn nữa, người dùng không cần bận tâm về việc cập nhật các tính năng và cập nhật mới, họ cũng không cần phải trả phí bảo trì hoặc chi phí khổng lồ. Các bản cập nhật là một phần của đăng ký hoặc, nếu phải trả bất kỳ khoản phí bảo trì nào, nó được chia sẻ bởi nhiều người thuê, do đó làm cho nó trở thành danh nghĩa (nhân tiện, bao gồm các bản cập nhật).  
  
Kiến trúc Multi tenant phục vụ hiệu quả tất cả mọi người từ các khách hàng nhỏ, có quy mô có thể không đảm bảo cơ sở hạ tầng chuyên dụng. Chi phí phát triển và bảo trì phần mềm được chia sẻ, giảm chi tiêu, dẫn đến tiết kiệm được chuyển cho bạn, khách hàng.  

Hỗ trợ dịch vụ tốt hơn.  
  
Mang lại lợi ích lâu dài cho các nhà cung cấp cũng như người dùng, có thể là về mặt bảo trì, chi phí đầu tư hoặc phát triển.  
  
### Khuyết điểm Multi tenant:  
Khó backup database riêng lẻ từng tenant  
Dữ liệu phìm to nhanh chóng Khó khăn khi scale hệ thống.  
  
<img src = "../Images/II.7. Swift/0.2.png">  

# 2. Lưu trữ dữ liệu dạng Object Storage

Sơ khai của mô hình lưu trữ dữ liệu là lưu trữ local, tức lưu trữ trực tiếp trên chính máy tính sử dụng nó, sau đó khi nhu cầu chia sẻ dữ liệu giữa các máy tính tăng lên, thì xuất hiện mô hình NFS (Network File Share – dữ liệu được chia sẻ giữa các máy tính cùng mạng)… Tuy nhiên, các kiến trúc lưu trữ cũ này không thể đáp ứng được các bài toán hiện tại về việc lưu trữ khối lượng dữ liệu rất lớn, và đặc biệt có khả năng co giãn linh hoạt. Chính vì vậy, Object Storage ra đời như một tất yếu, một giải pháp cho việc lưu trữ dữ liệu hướng đối tượng trong các hệ thống phân tán.  
Theo đó mỗi object sẽ bao gồm dữ liệu của chính nó, meta data và id định danh.  
_Bảng sau so sánh 3 dạng lưu trữ dữ liệu_  
<img src = "../Images/II.7. Swift/1.png">  

# 3. Kiến trúc tổ chức dữ liệu của Swift

Swift cho phép người dùng lưu trữ dữ liệu phi cấu trúc theo không gian gồm: account, container, object.  

<img src = "../Images/II.7. Swift/2.png">   
 
Mỗi account sẽ có nhiều container, mỗi container chứa nhiều object. Bằng việc sử dụng 1, 2 hay cả 3 thành phần sẽ giúp hệ thống tìm ra vị trí lưu dữ liệu.  
Có thể so sánh khập khiễng với lưu trữ file trên window như sau:

-   Account = tài khoản pc
-   Container = folder
-   Object = file

**Account**: địa chỉ lưu trữ account là duy tên duy nhất bao gồm metadata về chính account đó, và danh sách các containers bên trong.  
**Container**: địa chỉ lưu trữ container là người dùng định danh bên trong account, nơi này sẽ chứa thông tin về container đó và tập hợp các object.  
**Object**: địa chỉ lưu trữ object là nơi lưu trữ dữ liệu object và metadata của nó. Object có thể có tên giống nhau trong cùng 1 cluster.

# 4. Cơ chế quản lý và điều phối

Cơ chế hoạt động của Swift gồm 2 thành phần chính: điều phối dữ liệu (proxy node), và lưu trữ dữ liệu trực tiếp (storage node). Việc quản lý và điều phối được thực hiện dựa trên Ring.  
Ring là thành phần để xác định được chuỗi hash của dữ liệu, và từ chuỗi hash sẽ xác định được vị trí của object.  
Danh sách các thiết bị, sẽ được tạo trong file ring builder. Mỗi phần tử sẽ bao gồm: ID number, zone, weight, IP, port và tên của driver.  
Để đảm bảo dữ liệu ở trạng thái luôn khả dụng và an toàn trong các nguy cơ mất dữ liệu, thì Swift luôn tạo ra các bản copies và phân phối ra nhiều zones, region trong cluster, để chống lỗi. → tính bền vững.  

<img src = "../Images/II.7. Swift/3.png">  
  
Regions: được định nghĩa như là khoanh vùng khu vực địa lý. Ví dụ với hệ thống lưu trữ mail của Google, Region1 ở Mỹ, Region2 ở Anh, Region3 ở Việt Nam.  
Zones: Bên trong region, Ví dụ tại Region3 có Zone1 tại Hà Nội, Zone2 tại Hồ Chí Minh.  
Một zone được xác định bằng tập hợp các server riêng biệt khi có lỗi xảy ra sẽ được phân tách với các zones khác. Cần ít nhất một zone trong một region.  
Swift sẽ tìm region được sử dụng ít nhất. Nếu các region đều bao gồm vùng, nó sẽ tìm đến zone sử dụng ít nhất, tiếp theo là server, cuối cùng là tìm đến disk sử dụng ít nhất và đặt partion vào đó. Thuật toán này cũng đảm bảo dữ liệu sẽ đặt xa nhau nhất có thể để chịu lỗi. Tên của thuật toán là “unique-as-possible placement”.  
Sau khi tính toán nó sẽ ghi lại vị trí để đặt dữ liệu.  
Swift phát hiện lỗi bằng 2 cơ chế: auditor và replicators.

-   Auditor: chạy trên mỗi node, nếu có lỗi trên node nào thì node đó sẽ được cách ly riêng.
-   Replicators: thường xuyên so sánh các account, contain, object giữa các node trong cùng zone. Nếu 1 version bị lỗi, thì sẽ được thay thế.

<img src = "../Images/II.7. Swift/4.png">  

Không có cơ chế mã hóa dữ liệu trên Swift, việc bảo mật dữ liệu chủ yếu được thông qua quyền truy cập tới object đó. Việc này được thực hiện bởi một project khác của Openstack, đó là Keystone – project để định danh người dùng.

# 5. Khả năng của Swift

-   Việc quản lý và điều phối dữ liệu được thực hiện qua ring → bằng việc bổ sung, thay đổi cấu hình khai báo ring mà việc lưu trữ sẽ trở nên linh hoạt, mở rộng dễ dàng.
-   Swift cung cấp Restful API → thuận tiện cho developer, tích hợp với các ứng dụng, dịch vụ khác dễ dàng.  
    _Sơ đồ hệ thống Swift cơ bản_  
    <img src = "../Images/II.7. Swift/5.png">  

# Ref
[https://techblog.vn/to-chuc-du-lieu-voi-swift-object-storage](https://techblog.vn/to-chuc-du-lieu-voi-swift-object-storage)

[http://dangthanhphongtech.blogspot.com/2019/03/tong-quan-multi-tenancy.html](http://dangthanhphongtech.blogspot.com/2019/03/tong-quan-multi-tenancy.html)


