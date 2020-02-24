# Switch layer 2

## Định nghĩa – Switch layer 2 là gì?

**Bộ chuyển mạch switch layer 2**  là một loại  **switch mạng**  hoặc thiết bị hoạt động trên lớp liên kết dữ liệu (OSI Layer 2) và sử dụng địa chỉ MAC để xác định đường dẫn thông qua nơi các khung sẽ được chuyển tiếp.

Switch layer 2  Là các thiết bị Ethernet không cần phải có kết nối trực tiếp với nhau mới có thể truyền được tin mà nó có thể thực hiện điều đó bằng nhiều cách khác nhau. Ưu điểm nổi bật của bộ chuyển mạch này là giúp các host có thể hoạt động ở chế độ song công — có nghĩa là có thể đọc — ghi — nghe — nói cùng lúc. Đặc biệt, thiết bị thực hiện đường truyền mà không cần phải chia băng thông, đồng thời cũng có thể giới hạn lưu lượng truyền ở mức nào đó.

**Giải thích Switch layer 2**:

Chuyển mạch lớp 2 chịu trách nhiệm chính về việc truyền dữ liệu trên lớp vật lý và thực hiện kiểm tra lỗi trên mỗi khung được truyền và nhận. Một chuyển mạch lớp 2 yêu cầu địa chỉ MAC của NIC trên mỗi nút mạng để truyền dữ liệu.

Nó tự động tìm địa chỉ MAC bằng cách sao chép địa chỉ MAC của mỗi khung nhận được hoặc nghe các thiết bị trên mạng và duy trì địa chỉ MAC của chúng trong bảng chuyển tiếp. Điều này cũng cho phép chuyển đổi lớp 2 gửi nhanh khung đến các nút đích.

Tuy nhiên, giống như các công tắc lớp khác (3,4 trở đi), một chuyển mạch lớp 2 không thể truyền tải gói tin trên địa chỉ IP và không có bất kỳ cơ chế nào để ưu tiên các gói dựa trên ứng dụng gửi / nhận.

## Nguyên lý hoạt động và chức năng của switch layer 2 

### Nguyên lý hoạt động

Chuyển mạch switch lớp 2 là thiết bị mạng chuyển tiếp lưu lượng dựa trên địa chỉ lớp MAC (Ethernet hoặc Token Ring).

Công nghệ cầu nối đã được khoảng từ những năm 1980 (và thậm chí có thể sớm hơn). Bridge liên quan đến việc phân đoạn các mạng cục bộ (LAN) ở cấp lớp 2. Một bridge thường tìm hiểu về các địa chỉ điều khiển truy cập phương tiện (MAC) trên mỗi cổng của nó và chuyển các khung MAC một cách minh bạch đến các cổng đó.

Những bridge này cũng đảm bảo rằng các frame được đặt cho các địa chỉ MAC nằm trên cùng một cổng với trạm gốc không được chuyển tiếp đến các cổng khác. Vì mục đích của cuộc thảo luận này, chúng tôi chỉ xem xét các mạng LAN Ethernet.

Thiết bị chuyển mạch lớp 2 có hiệu quả cung cấp chức năng tương tự. Chúng tương tự như các bridge đa dạng ở chỗ chúng học và chuyển tiếp các frame trên mỗi cổng. Sự khác biệt chính là sự tham gia của phần cứng đảm bảo rằng nhiều đường dẫn chuyển đổi bên trong switch có thể hoạt động cùng một lúc.


### Chức năng của switch layer 2

**Có ba chức năng riêng biệt của chuyển mạch switch lớp 2**

1.  địa chỉ – address learning
2.  các quyết định chuyển tiếp/lọc – forward/filter decisions
3.  tránh vòng lặp – loop avoidance

**Địa chỉ**

Switch layer 2 và bridge nhớ địa chỉ phần cứng nguồn của mỗi khung nhận được trên một giao diện và chúng nhập thông tin này vào cơ sở dữ liệu MAC được gọi là bảng chuyển tiếp / bộ lọc.

**Chuyển tiếp / quyết định lọc**

Khi một frame được nhận trên một giao diện, switch sẽ nhìn vào địa chỉ phần cứng đích và tìm thấy giao diện thoát trong cơ sở dữ liệu MAC. Khung chỉ được chuyển tiếp ra cổng đích được chỉ định.

**Tránh vòng lặp**

Nếu nhiều kết nối giữa các switch được tạo cho mục đích dự phòng, các vòng lặp mạng có thể xảy ra. Giao thức cây spanning (STP) được sử dụng để ngăn chặn các vòng lặp mạng trong khi vẫn cho phép dự phòng.

# Switch Layer 3 

Switch layer 3  có tên gọi là Switch với 24, 48… ports Ethernet, được gắn thêm bảng định tuyến IP thông minh vào bên trong và hình thành lên các Broadcast Domain. Vậy chính xác  [**Switch layer 3 là gì**] ? Các Switch Layer 3 chính là các router tốc độ cao không có cổng kết nối mạng WAN. Tuy là vậy nhưng Switch layer 3  vẫn có chức năng định tuyến như router để thực hiện liên thông với các mạng con hay mạng VLANs Campus hay các LAN nhỏ trong mạng LAN lớn. Thường Switch layer 3 là  loại Switch công nghiệp, nó có tốc độ xử lý cực kỳ nhanh từ bên trong Switch này đến Switch khác.

**So sánh Switch layer 2 và Switch layer 3**

<img src = "../Images/Tìm hiểu Switch/1.png"> 

# Ref
[https://medium.com/@totolinkvn/switch-layer-3-l%C3%A0-g%C3%AC-switch-layer-3-kh%C3%A1c-g%C3%AC-so-v%E1%BB%9Bi-switch-layer-2-e74bc70e5744](https://medium.com/@totolinkvn/switch-layer-3-l%C3%A0-g%C3%AC-switch-layer-3-kh%C3%A1c-g%C3%AC-so-v%E1%BB%9Bi-switch-layer-2-e74bc70e5744)

[https://netsystem.vn/switch-layer-2-la-gi-nguyen-ly-hoat-dong-va-chuc-nang-cua-switch-layer-2/](https://netsystem.vn/switch-layer-2-la-gi-nguyen-ly-hoat-dong-va-chuc-nang-cua-switch-layer-2/)

[https://www.slideshare.net/hongocan/virtual-lanviet](https://www.slideshare.net/hongocan/virtual-lanviet)


