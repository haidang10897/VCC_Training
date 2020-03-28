# 1. Giới thiệu


Ceph là dự án mã nguồn mở, cung cấp giải pháp lưu trữ dữ liệu. Ceph cung cấp giải pháp lưu trữ phân tán mạnh mẽ, đáp ứng các yêu cầu về khả năng mở rộng, hiệu năng, khả năng chịu lỗi cao. Xuất phát từ mục tiêu ban đầu, Ceph được thiết kết với khả năng mở rộng không giới hạn, hỗ trợ lưu trữ tới mức exabyte, cùng với khả năng tương thích cao với các phần cứng có sẵn. Và từ đó, Ceph trở nên nổi bật trong ngành công nghiệp lưu trữ đang phát triển và mở rộng. Hiện nay, các nền tảng hạ tầng đám mây công cộng, riêng và lai dần trở nên phổ biến và to lớn. Bên cạnh đó, phần cứng - thành phần quyết định hạ tầng đám mây đang dần gặp các vấn đề về hiệu năng, khả năng mở rộng. Ceph đã và đang giải quyết được các vấn đề doanh nghiệp đang gặp phải, cung cấp hệ thống, hạ tầng lưu trữ mạnh mẽ, độ tin cậy cao.

Nguyên tắc cơ bản của Ceph: - Khả năng mở rộng tất cả thành phần; - Khả năng chịu lỗi cao; - Giải pháp dựa trên phần mềm, hoàn toàn mở, tính thích nghi cao; - Chạy tương thích với mọi phần cứng;

Ceph xây dựng kiến trúc mạnh mẽ, khả năng mở rộng không giới hạn, hiệu năng cao, cung cấp giải pháp thống nhất, nền tảng mạnh mẽ cho doanh nghiệp, giảm bớt sự phụ thuộc vào phần cứng đắt tiền. Hệ sinh thái Ceph cung cấp giải pháp lưu trữ dựa trên block, file, object, và cho phép tùy chỉnh theo ý muốn. Nền tảng Ceph xây dựng dựa trên các object, tổ chức trên các block. Tất cả các kiểu dữ liệu, block, file đều được lưu dưới dạng object, quản trị bởi Ceph cluster. Object storage hiện đã trở thành giải pháp cho hệ thống lưu trữ truyền thống, cho phép xây dựng kiến trúc hạ tầng độc lập với phần cứng.

Ceph xây dựng giải pháp dựa trên Object, Các object được tổ chức, nhân bản trên toàn cluster, nâng cao tính bảo đảm dữ liệu. Tại Ceph, Object sẽ không tồn tại đường dẫn vật lý, toàn bộ Object được quản trị dưới dạng Key Object, tạo nền tảng mở với khả năng lưu trữ tới hàng petabyte-exabyte.

<img src = "../Images/IV. Giới thiệu Ceph/1.png">   

**Tính năng:**

-   Thay thế lưu trữ trên ổ đĩa server thông thường
-   Backup, dự phòng
-   Triển khai các dịch vụ High Avaibility như Load Balancing for Web Server, DataBase Replication…
-   Giải quyết bài toán lưu trữ cho điện toán đám mây
-   Khả năng mở rộng, sử dụng nhiều phần cứng khác nhau
-   Ko tồn tại "single point of failure"
# 2. Tóm lược về từ khóa CEPH

Từ khóa đầu tiên chắc hẳn là từ CEPH, từ này khiến mọi người khó hình dung việc liên quan tới lưu trữ và tra từ điển thì không ra cái gì cả :). Tuy nhiên, điểm cần ghi nhớ lại thì “CEPH là một nền tảng storage được xây dựng bằng phần mềm và triển khai trên các máy chủ phổ thông (thay vì phải mua thiết bị SAN chuyên dụng của các hãng thì mua máy chủ và triển khai CEPH lên).

Trên trang chủ hoặc wikipedia đều nói rằng CEPH là nền tảng để cung cấp hạ tầng lưu trữ, nó coi và nhìn data (dữ liệu) là các đối tượng (object) và quản lý dữ liệu này trên một hệ thống cluster (cụm gồm nhiều máy chủ hoạt động với 1 mục tiêu cụ thể) duy nhất, nó cung cấp đầy đủ các giao diện để người dùng, để ứng dụng có thể thao tác với data theo các dạng (đầy đủ nhất hiện nay) là object, block và file. Một số loại giải pháp lưu trữ cứng hoặc lưu trữ mềm chỉ cung cấp 1 hoặc 2 dạng (đa số là block hoặc là object hoặc là file).

> Chốt lại là “CEPH được sinh ra với mục tiêu cung cấp hạ tầng lưu trữ hợp nhất (gồm đẩy đủ các kiểu lưu trữ),  **xử lý dữ liệu phân tán** trên nhiều máy chủ, thiết kế hệ thống khi triển khai CEPH là  **không có điểm gây nghẽn**  (single point of failure), có **khả năng mở rộn**g tới exabyte và  **miễn phí**.
> 
> TRÍCH WIKIPEDIA

Tới đây hẳn bạn vẫn lăn tăn với từ CEPH nhỉ! Để không gây tò mò thì mình xin cung cấp thông tin về tên các phiên bản của CEPH. Cụ thể như sau.

# 3. Tên các phiên bản của CEPH

Phiên bản mỗi lần phát hành của CEPH gồm 2 phần, phần tên và phần đánh số thứ tự.

Tên của các phiên bản CEPH bắt đầu bởi các chữ cái trong bảng chữ cái, tính tới thời điểm bài viết này (09.2019) thì phiên bản của CEPH có tên là Nautilus (như vậy trước đó sẽ là M – Mimic).

Tên các phiên bản của CEPH nếu tra thì sẽ ra tên của các loài bạch tuộc :D. Cho nên các logo đối với các phiên bản ta sẽ nhìn thấy hình con bạch tuộc đó.

Như vậy, từ CEPH sẽ là 04 chữ cái trong tiếng Hy Lạp là  **CEPHALOPOD** – tức là động vật thân mềm hay động vật chân đầu ([tham khảo](https://vi.wikipedia.org/wiki/%C4%90%E1%BB%99ng_v%E1%BA%ADt_ch%C3%A2n_%C4%91%E1%BA%A7u))

# 4. Số thứ tự các phiên bản của CEPH

Như trong phần 3 chúng ta đã biết, bản hiện tại của CEPH có tên là Nautilus và có số thứ tự 14. Số 14 này chính là số thứ tự của chữ cái N trong bảng chữ cái.

Trong mỗi phiên bản của CEPH gồm 3 số và ngăn cách nhau bởi dấu chấm dạng X.Y.Z. Ví dụ mình đang làm việc với phiên bản Nautilus – 14.2.2. Trong đó:

-   X là số thứ tự của bản phát hành. Hiện nay là chữ cái N và số là 14.
-   Y gồm 3 giá trị là 0, 1 và 2, trong đó:
    -   0 thể hiện phiên bản đang trong quá trình phát triển, thường các dev đang làm việc với phiên bản này. Sẽ có dạng X.0.Z. Tiếng Anh gọi là DEVELOPMENT RELEASES
    -   1 thể hiện đó là phiên bản dạng “ứng cử viên” – phiên bản này sẽ được cung cấp để phục vụ mục tiêu triển khai thử nghiệm và đánh giá. Sẽ có dạng X.1.Z. Tiếng Anh gọi là RELEASE CANDIDATES.
    -   2 thể hiện đó là phiên bản ổn định (Stable), đã có thể dùng cho product (chạy cung cấp dịch vụ). Phiên bản này chỉ còn các dạng fix các bug sau khi triển khai do người dùng phản hồi hoặc hỗ trợ các vấn đề về bug bảo mật. Sẽ có dạng X.2.Z. Tiếng Anh gọi là STABLE RELEASES.

Lưu ý: Cách đánh số này chỉ được bắt đầu từ bản Infernalis trở đi và bắt đầu là số 9, tức là 9.Y.Z. Trước đó team phát triển CEPH dùng là 0.Y cho bản phát triển và 0.Y.Z cho các bản ổn định (stable).

Mỗi chu kỳ phát hành từng phiên bản sẽ có các khoảng thời gian cho các chu kỳ DEVELOPMENT , CANDIDATES và STABLE ([Tham khảo](https://docs.ceph.com/docs/master/releases/schedule/)) để đảm bảo việc phát triển và phát hành là hợp lý. Đơn vị tính sẽ là tuần.

Năm nào CEPH cũng được phát hành tùy vào tiến độ của các phiên bản trước đó và sẽ có bản stable cho tất cả các phiên bản. Trước bản Luminous các ổn định thường gắn dòng LTS (Long Time Support) nhưng kể từ sau đó team phát triển đã bỏ đi thay vào là từ stable. Bản stable của CEPH sẽ hỗ trợ trong 2 năm liên tiếp (nghĩa là sẽ hỗ trợ fixbug, cho phép upgrade. Ví dụ như Jewel sẽ được hỗ trợ tới 2018.

Dưới là liệt kê nhanh các phiên bản của CEPH.

**Phiên bản CEPH tương lai -2020**

Octopus – bản stable sẽ là 15.2.Z

#### **Các phiên bản phổ biển trong 3 năm gần nhất tính tới 2019**

-   Nautilus – March 2019 ( v14.2.0 Nautilus)
-   Mimic – May 2018
-   Luminous – October 2017
-   Kraken – October 2017 (Giới thiệu khái niệm blustore)
-   Jewel- April 2016

#### **Các phiên bản trước đó**

-   Infernalis Stable November 2015 – June 2016
-   Hammer LTS April 2015 – November 2016
-   Giant Stable October 2014 – April 2015
-   Firefly 0.80 (LTS) May 2014
-   Emperor 0.72 Release November 9, 2013
-   Dumpling 0.67 (LTS) 2013 August 14, 2005
-   Cuttlefish 0.61 version May 7, 2013
-   Bobtail 0.56 version (LTS) January 1, 2013
-   Argonaut 0.48 version (LTS) June 3, 2012

## Tham khảo

1.  [https://docs.ceph.com/docs/master/releases/schedule/](https://docs.ceph.com/docs/master/releases/schedule/)
2.  [https://en.wikipedia.org/wiki/Ceph_(software)](https://en.wikipedia.org/wiki/Ceph_(software))
