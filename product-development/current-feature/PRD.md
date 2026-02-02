# Product Requirements Document (PRD)
## Hệ thống Quản lý Phân phối (DMS - Distribution Management System) cho DILIGO

---

## 1. Tổng quan sản phẩm

### 1.1 Tên sản phẩm
**DILIGO DMS** - Hệ thống Quản lý Phân phối

### 1.2 Tầm nhìn sản phẩm
Xây dựng một hệ thống DMS toàn diện giúp DILIGO quản lý hiệu quả mạng lưới phân phối, giám sát hoạt động bán hàng thực địa, và tối ưu hóa quy trình từ đặt hàng đến giao hàng trên toàn quốc.

### 1.3 Mục tiêu kinh doanh
- Số hóa toàn bộ quy trình bán hàng và phân phối
- Giám sát thời gian thực hoạt động của nhân viên bán hàng (NVBH)
- Tối ưu hóa tuyến bán hàng và viếng thăm khách hàng
- Nâng cao hiệu quả quản lý kho hàng và công nợ
- Cung cấp báo cáo phân tích để hỗ trợ ra quyết định kinh doanh

---

## 2. Phân tích vấn đề

### 2.1 Vấn đề hiện tại
| Vấn đề | Tác động |
|--------|----------|
| Không giám sát được vị trí và hoạt động của NVBH thực địa | Khó đánh giá hiệu suất, không kiểm soát được thời gian làm việc |
| Quy trình đặt hàng thủ công, chậm trễ | Mất thời gian, dễ sai sót, không cập nhật tồn kho kịp thời |
| Thiếu dữ liệu trưng bày sản phẩm tại điểm bán | Không đánh giá được độ phủ thương hiệu |
| Quản lý công nợ phân tán | Rủi ro nợ xấu, khó theo dõi thanh toán |
| Báo cáo bán hàng không tập trung | Khó phân tích xu hướng, chậm ra quyết định |

### 2.2 Đối tượng người dùng

| Vai trò | Mô tả | Nhu cầu chính |
|---------|-------|---------------|
| **Nhân viên bán hàng (NVBH)** | Nhân viên thực địa đi tuyến, viếng thăm khách hàng | Ứng dụng mobile để check-in, đặt hàng, chụp hình |
| **Giám sát bán hàng (GSBH/SS)** | Quản lý trực tiếp NVBH | Giám sát vị trí, xét duyệt đơn hàng, theo dõi KPI |
| **Area Sales Manager (ASM)** | Quản lý vùng | Báo cáo tổng hợp theo khu vực, quản lý tuyến |
| **Regional Sales Manager (RSM)** | Quản lý khu vực lớn | Dashboard tổng quan, phân tích hiệu suất |
| **Admin NPP** | Quản trị viên nhà phân phối | Quản lý master data, xuất nhập kho, công nợ |

---

## 3. Phạm vi sản phẩm

### 3.1 Trong phạm vi (In Scope)

#### A. PHÂN HỆ WEB

##### Module Giám sát (cho SS, ASM, RSM)

| Chức năng | Mô tả chi tiết | Vị trí tham chiếu |
|-----------|----------------|-------------------|
| **Giám sát nhân viên bán hàng** | - Theo dõi vị trí hiện thời trên bản đồ<br>- Hiển thị thời điểm cập nhật, hoạt động (viếng thăm, chấm công, khai báo vị trí)<br>- Trạng thái di chuyển/dừng<br>- Tình trạng PIN thiết bị | 2.1 Kiểm Soát Nhân Viên |
| **Giám sát lộ trình bán hàng** | Theo dõi nhật trình di chuyển của NVBH theo tuyến | 2.1 Kiểm Soát Nhân Viên |
| **Giám sát viếng thăm khách hàng** | - Số KH viếng thăm trong tuyến/ngoại tuyến<br>- Viếng thăm có đơn/không đơn<br>- Viếng thăm có hình/không hình<br>- KH đóng cửa/chủ đi vắng<br>- Viếng thăm đúng/không đúng quy trình | 2.2 Kiểm Soát Viếng Thăm |
| **Giám sát hình ảnh khách hàng** | - Phân loại hình ảnh theo Album<br>- Theo dõi viếng thăm có/không có hình ảnh | 2.3 Hình ảnh khách hàng |
| **Giám sát khắc phục vấn đề** | - Quản lý tập trung các vấn đề phát sinh<br>- Cập nhật hướng dẫn giải quyết | 2.6 Kiểm soát khắc phục |
| **Quản lý KPI nhân viên** | - Thiết lập và theo dõi KPI:<br>  + Số khách viếng thăm/tháng<br>  + Số khách hàng mới/tháng<br>  + Số đơn hàng/tháng<br>  + Doanh số/Doanh thu/tháng<br>  + Sản lượng/tháng<br>  + Tổng SKU/tháng | 6.1.9 Báo cáo KPI |

##### Module Bán hàng

| Chức năng | Mô tả chi tiết | Vị trí tham chiếu |
|-----------|----------------|-------------------|
| **Quản lý khách hàng** | - Danh sách KH với thông tin mở rộng<br>- Vị trí KH trên bản đồ<br>- Thông tin liên hệ (lãnh đạo, nhân viên)<br>- Lịch sử cập nhật, viếng thăm, đặt hàng<br>- Hình ảnh và ghi chú KH | 4.1 Khách Hàng |
| **Quản lý sản phẩm** | - Danh mục sản phẩm mở rộng<br>- Đơn vị tính, hệ số quy đổi<br>- Giá nhập, giá bán NPP, giá bán KH<br>- Phân loại theo ngành/nhãn hiệu/NCC<br>- Hình ảnh sản phẩm | 4.2 Sản Phẩm |
| **Quản lý đặt hàng** | - Tiếp nhận phiếu đặt hàng từ mobile<br>- Lập phiếu đặt hàng từ email/điện thoại<br>- Xét duyệt đơn hàng<br>- Lập phiếu bán hàng từ đặt hàng<br>- In phiếu | 4.8 Phiếu Đặt Hàng |
| **Quản lý bán hàng** | - Danh sách phiếu bán hàng<br>- Lập/hiệu chỉnh phiếu bán hàng<br>- Lập phiếu xuất kho từ bán hàng<br>- Lập phiếu trả hàng<br>- Theo dõi công nợ tự động<br>- Xuất Excel cho ERP Oracle<br>- In phiếu | 3.4 Phiếu Bán Hàng |
| **Quản lý kho hàng** | - Phiếu xuất/nhập/chuyển kho<br>- Lập phiếu nhập kho<br>- Lập phiếu chuyển kho<br>- In phiếu kho | 4.11 Kho Hàng |
| **Quản lý trả hàng** | - Danh sách phiếu trả hàng<br>- Lập phiếu trả hàng<br>- Tự động lập phiếu nhập kho<br>- In phiếu | 4.10 Phiếu Trả Hàng |
| **Quản lý công nợ** | - Phiếu điều chỉnh công nợ<br>- Phiếu thu nợ<br>- Phiếu hoàn tiền<br>- In phiếu thu/chi | 4.14 Công nợ |
| **Quản lý khuyến mại** | - Đa dạng hình thức KM<br>- KM theo số lượng/giá trị<br>- Áp dụng theo loại/nhóm KH<br>- Áp dụng theo thời gian | 6.7 Báo cáo KM |

##### Module Báo cáo

| Chức năng | Mô tả chi tiết | Vị trí tham chiếu |
|-----------|----------------|-------------------|
| **Báo cáo giám sát** | - BC viếng thăm KH<br>- Thống kê hình ảnh<br>- Tần suất viếng thăm<br>- Bảng chấm công tháng<br>- Tổng hợp viếng thăm & KPI | 6.1 Báo cáo Giám Sát |
| **Báo cáo KPI** | Kết quả thực hiện KPI theo tháng | 6.1.10 Tổng Hợp KPI |
| **Báo cáo khuyến mại** | Tổng hợp kết quả CTKM theo SP | 6.7 Báo cáo KM |
| **Báo cáo bán hàng** | - Theo khách hàng<br>- Theo sản phẩm<br>- Theo NVBH | 6.4 Báo cáo bán hàng |
| **Thống kê bán hàng** | - Theo KH/loại KH/nhóm KH<br>- Theo khu vực địa lý<br>- Theo ngành/nhãn hàng/SP<br>- Theo NV/nhóm bán hàng | 6.5 Thống kê bán hàng |
| **Báo cáo kho** | - Xuất nhập tồn kho<br>- Tổng hợp XNT<br>- Tồn KH/tồn thị trường | 6.9.1 Báo cáo XNT |

#### B. PHÂN HỆ MOBILE (Ứng dụng cho NVBH)

| Chức năng | Mô tả chi tiết |
|-----------|----------------|
| **Xem thông tin khách hàng** | - Tra cứu KH trên tuyến<br>- Cập nhật thông tin KH<br>- Quản lý giao dịch, ghi chú, phản hồi |
| **Xem thông tin sản phẩm** | - Tra cứu SP được phép bán<br>- Tra cứu tồn kho SP |
| **Tra cứu khuyến mại** | Xem CTKM còn hiệu lực |
| **Thực hiện viếng thăm** | - Chăm sóc KH trên tuyến<br>- Thêm mới KH<br>- Check-in/Check-out với GPS<br>- Chụp hình trưng bày |
| **Quản lý đơn hàng** | - Danh sách đơn hàng (hôm nay/tuần/tháng)<br>- Theo dõi trạng thái (chờ duyệt/đã duyệt/đã xuất)<br>- Cập nhật đơn hàng chờ gửi |
| **Xem báo cáo** | - Kết quả bán hàng theo KH/SP<br>- Thực hiện KPI<br>- BC đặt hàng/bán hàng<br>- BC thống kê đa chiều<br>- BC khuyến mại, kho, công nợ<br>- BC khách hàng mới |
| **Chấm công** | - Chấm công vào (đầu ngày)<br>- Chấm công ra (cuối ngày) |
| **Thông báo** | Tiếp nhận thông báo từ công ty |

### 3.2 Ngoài phạm vi (Out of Scope)
- Tích hợp ERP hoàn chỉnh (chỉ xuất Excel cho Oracle)
- Quản lý nhân sự (HR)
- Kế toán tài chính chi tiết
- E-commerce/Bán hàng online trực tiếp đến người tiêu dùng

---

## 4. Yêu cầu chức năng chi tiết

### 4.1 Quy trình viếng thăm khách hàng (Core Flow)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUY TRÌNH VIẾNG THĂM KHÁCH HÀNG                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [Chấm công vào]                                                   │
│       │                                                             │
│       ▼                                                             │
│  [Nhận tuyến bán hàng]                                              │
│       │                                                             │
│       ▼                                                             │
│  [Di chuyển đến điểm bán] ─────────────────┐                       │
│       │                                     │                       │
│       ▼                                     │                       │
│  [Check-in tại điểm bán]                    │                       │
│       │                                     │                       │
│       ├──────────────────────┐              │                       │
│       ▼                      ▼              │                       │
│  [Chụp hình trưng bày] [Lập đơn hàng]      │                       │
│       │                      │              │                       │
│       ▼                      ▼              │                       │
│  [Cập nhật thông tin KH] [Gửi đơn hàng]    │                       │
│       │                      │              │                       │
│       ▼                      ▼              │                       │
│  [Check-out] ◄───────────────┘              │                       │
│       │                                     │                       │
│       ▼                                     │                       │
│  [Điểm bán tiếp theo] ──────────────────────┘                       │
│       │                                                             │
│       ▼                                                             │
│  [Chấm công ra]                                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Quy trình xử lý đơn hàng

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUY TRÌNH XỬ LÝ ĐƠN HÀNG                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [NVBH tạo đơn hàng] ──► [Gửi về hệ thống]                         │
│                                │                                    │
│                                ▼                                    │
│                    ┌───────────────────────┐                       │
│                    │   Đơn hàng mới        │                       │
│                    │   (Chờ duyệt)         │                       │
│                    └───────────────────────┘                       │
│                                │                                    │
│                                ▼                                    │
│                    ┌───────────────────────┐                       │
│                    │ GSBH/Admin xét duyệt  │                       │
│                    └───────────────────────┘                       │
│                         │            │                              │
│                    [Duyệt]      [Từ chối]                          │
│                         │            │                              │
│                         ▼            ▼                              │
│             ┌─────────────────┐  ┌─────────────────┐               │
│             │   Đã duyệt      │  │   Đã từ chối    │               │
│             └─────────────────┘  └─────────────────┘               │
│                         │                                           │
│                         ▼                                           │
│             ┌─────────────────┐                                    │
│             │ Lập phiếu bán   │                                    │
│             └─────────────────┘                                    │
│                         │                                           │
│                         ▼                                           │
│             ┌─────────────────┐                                    │
│             │ Lập phiếu xuất  │                                    │
│             │     kho         │                                    │
│             └─────────────────┘                                    │
│                         │                                           │
│                         ▼                                           │
│             ┌─────────────────┐                                    │
│             │   Giao hàng     │                                    │
│             └─────────────────┘                                    │
│                         │                                           │
│                         ▼                                           │
│             ┌─────────────────┐                                    │
│             │  Cập nhật công  │                                    │
│             │      nợ         │                                    │
│             └─────────────────┘                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 5. Yêu cầu dữ liệu

### 5.1 Master Data

#### Khách hàng (Customer Master)
| Trường dữ liệu | Kiểu | Bắt buộc | Mô tả |
|---------------|------|----------|-------|
| ID | String | Có | Mã định danh duy nhất |
| Mã khách hàng | String | Có | Mã KH theo quy ước |
| Tên khách hàng | String | Có | Tên đầy đủ |
| Số điện thoại | String | Có | SĐT liên hệ |
| Người liên hệ | String | Không | Tên người liên hệ |
| Nhóm khách hàng | Enum | Có | A/B/C/D/E |
| Loại khách hàng | Enum | Có | Tạp Hóa, Hiệu Thuốc, Mỹ Phẩm, Thời Trang... |
| Kênh | Enum | Có | GT/MT |
| Vĩ độ/Kinh độ | Float | Có | Tọa độ GPS |
| Địa chỉ | String | Có | Địa chỉ chi tiết |
| Khu vực | String | Có | Mã khu vực |
| Mã tuyến | String | Có | Tuyến bán hàng |
| Hạn mức công nợ | Number | Không | Giới hạn nợ |
| Trạng thái | Enum | Có | Hoạt động/Ngừng |
| Hình ảnh | URL | Không | Ảnh cửa hàng |

#### Sản phẩm (Product Master)
| Trường dữ liệu | Kiểu | Bắt buộc | Mô tả |
|---------------|------|----------|-------|
| ID | String | Có | Mã định danh |
| Mã sản phẩm | String | Có | SKU |
| Tên sản phẩm | String | Có | Tên đầy đủ |
| Nhãn hiệu | String | Có | Brand |
| Ngành hàng | String | Có | Category |
| Nhà cung cấp | String | Không | Supplier |
| ĐVT chẵn/ĐVT lẻ | String | Có | Đơn vị tính |
| Hệ số quy đổi | Number | Có | Conversion rate |
| Giá nhập/Giá nhập lẻ | Number | Có | Cost price |
| Giá bán/Giá bán lẻ | Number | Có | Selling price |
| VAT | Number | Có | Thuế suất |
| Hình ảnh | URL | Không | Product image |
| Trạng thái | Enum | Có | Active/Inactive |

#### Nhà phân phối (Distributor Master)
| Trường dữ liệu | Kiểu | Bắt buộc | Mô tả |
|---------------|------|----------|-------|
| ID | String | Có | Mã định danh |
| Mã NPP | String | Có | Distributor code |
| Tên NPP | String | Có | Tên đầy đủ |
| Loại NPP | Enum | Có | NPP/Đại lý/Tổng thầu |
| Mã số thuế | String | Có | Tax code |
| Nhóm NPP | Enum | Có | A/B/C/D |
| Kênh SO | Enum | Có | GT/MT |
| Khu vực | String | Có | Region |
| Tỉnh/TP | String | Có | Province |
| Địa chỉ | String | Có | Full address |
| Người liên hệ | String | Có | Contact person |
| SĐT | String | Có | Phone |
| Email | String | Không | Email |
| Ngân hàng | String | Không | Bank name |
| Số tài khoản | String | Không | Bank account |
| CMND/CCCD | String | Không | ID number |
| ĐKKD | String | Không | Business license |
| Trạng thái | Enum | Có | Hoạt động/Thanh lý |

---

## 6. Yêu cầu phi chức năng

### 6.1 Hiệu năng
| Yêu cầu | Mục tiêu |
|---------|----------|
| Response time (Web) | < 3 giây cho các thao tác thông thường |
| Response time (Mobile) | < 2 giây cho check-in/checkout |
| Concurrent users | Hỗ trợ tối thiểu 1000 users đồng thời |
| Mobile app startup | < 5 giây |
| Sync data | Background sync mỗi 5 phút |

### 6.2 Bảo mật
- Xác thực người dùng (username/password)
- Phân quyền theo vai trò (RBAC)
- Mã hóa dữ liệu truyền tải (HTTPS/TLS)
- Log hoạt động người dùng
- Session timeout sau 30 phút không hoạt động

### 6.3 Khả dụng
- Uptime: 99.5%
- Mobile offline mode: Có (sync khi có mạng)
- Data backup: Daily backup
- Disaster recovery: RTO < 4 giờ, RPO < 1 giờ

### 6.4 Khả năng mở rộng
- Horizontal scaling cho web servers
- Database sharding theo khu vực nếu cần
- CDN cho static assets và hình ảnh

---

## 7. Tiêu chí chấp nhận (Acceptance Criteria)

### 7.1 Module Giám sát

| ID | User Story | Acceptance Criteria |
|----|-----------|---------------------|
| GS-01 | Là GSBH, tôi muốn xem vị trí NVBH trên bản đồ | - Hiển thị marker cho mỗi NVBH<br>- Cập nhật vị trí real-time (< 5 phút)<br>- Hiển thị trạng thái: di chuyển/dừng<br>- Click vào marker hiển thị thông tin chi tiết |
| GS-02 | Là GSBH, tôi muốn xem tình hình viếng thăm | - Hiển thị số KH đã viếng thăm/tổng KH trên tuyến<br>- Phân loại: trong tuyến/ngoài tuyến<br>- Phân loại: có đơn/không đơn<br>- Filter theo ngày/NVBH |
| GS-03 | Là ASM, tôi muốn xem hình ảnh trưng bày | - Gallery hình ảnh theo KH/NVBH/ngày<br>- Phân loại theo Album<br>- Zoom và xem chi tiết<br>- Download được |

### 7.2 Module Mobile

| ID | User Story | Acceptance Criteria |
|----|-----------|---------------------|
| MB-01 | Là NVBH, tôi muốn check-in tại điểm bán | - Capture GPS tự động<br>- Hiển thị khoảng cách so với vị trí KH<br>- Cảnh báo nếu khoảng cách > 100m<br>- Lưu thời gian check-in |
| MB-02 | Là NVBH, tôi muốn tạo đơn hàng | - Chọn SP từ danh sách<br>- Nhập số lượng<br>- Tự động tính thành tiền<br>- Áp dụng khuyến mại tự động<br>- Gửi đơn về hệ thống |
| MB-03 | Là NVBH, tôi muốn chụp hình trưng bày | - Camera trong app<br>- Gắn GPS và timestamp<br>- Chọn loại hình (Album)<br>- Upload khi có mạng |
| MB-04 | Là NVBH, tôi muốn làm việc offline | - Dữ liệu KH, SP đã sync offline<br>- Tạo đơn hàng offline<br>- Chụp hình offline<br>- Sync tự động khi có mạng |

### 7.3 Module Bán hàng

| ID | User Story | Acceptance Criteria |
|----|-----------|---------------------|
| BH-01 | Là Admin NPP, tôi muốn duyệt đơn hàng | - Danh sách đơn chờ duyệt<br>- Xem chi tiết đơn hàng<br>- Duyệt/Từ chối với lý do<br>- Notification cho NVBH |
| BH-02 | Là Admin NPP, tôi muốn lập phiếu xuất kho | - Chọn từ đơn hàng đã duyệt<br>- Tự động fill thông tin<br>- Kiểm tra tồn kho<br>- Cập nhật tồn kho sau xuất |
| BH-03 | Là Admin NPP, tôi muốn quản lý công nợ | - Xem công nợ theo KH<br>- Lập phiếu thu nợ<br>- Cảnh báo vượt hạn mức<br>- Báo cáo nợ quá hạn |

---

## 8. Metrics thành công (Success Metrics)

### 8.1 KPIs vận hành

| Metric | Mục tiêu | Cách đo |
|--------|----------|---------|
| Tỷ lệ viếng thăm đúng tuyến | > 90% | Số viếng thăm trong tuyến / Tổng viếng thăm |
| Tỷ lệ viếng thăm có đơn | > 60% | Số viếng thăm có đơn / Tổng viếng thăm |
| Thời gian xử lý đơn hàng | < 2 giờ | Từ lúc NVBH gửi đến khi duyệt |
| Tỷ lệ hình ảnh trưng bày | > 80% | Số viếng thăm có hình / Tổng viếng thăm |
| App crash rate | < 1% | Số session crash / Tổng session |

### 8.2 KPIs kinh doanh

| Metric | Mục tiêu | Cách đo |
|--------|----------|---------|
| Số KH viếng thăm/NVBH/ngày | > 20 | Trung bình viếng thăm mỗi NVBH |
| Doanh số trung bình/đơn | Tăng 10% | So sánh trước/sau triển khai |
| Độ phủ thị trường | Tăng 15% | Số KH active / Tổng KH tiềm năng |
| Tỷ lệ thu hồi công nợ | > 95% | Công nợ thu được / Tổng công nợ |

---

## 9. Rủi ro và Giải pháp

| Rủi ro | Mức độ | Giải pháp |
|--------|--------|-----------|
| NVBH không quen sử dụng smartphone | Cao | Training đầy đủ, UI đơn giản, hỗ trợ hotline |
| Mất kết nối mạng ở vùng xa | Cao | Offline mode, auto-sync |
| GPS không chính xác | Trung bình | Cho phép manual check-in với xác nhận của GS |
| Dữ liệu master data không đồng bộ | Trung bình | Sync scheduled, validation rules |
| Resistance to change từ NPP | Trung bình | Change management, demo benefits |

---

## 10. Lộ trình phát triển (Roadmap)

### Phase 1: Foundation
- Setup infrastructure
- Master data management (KH, SP, NPP)
- User management & authentication
- Basic mobile app (check-in, view data)

### Phase 2: Core Operations
- Order management
- Inventory management (xuất/nhập kho)
- Image capture & gallery
- Basic reporting

### Phase 3: Advanced Features
- Full KPI management
- Promotion management
- Advanced analytics & dashboards
- Integration with external systems

### Phase 4: Optimization
- Performance optimization
- Advanced offline capabilities
- AI-powered route optimization
- Predictive analytics

---

## 11. Phụ lục

### 11.1 Glossary

| Thuật ngữ | Viết tắt | Định nghĩa |
|-----------|----------|------------|
| Distribution Management System | DMS | Hệ thống quản lý phân phối |
| Nhân viên bán hàng | NVBH | Sales Rep |
| Giám sát bán hàng | GSBH/SS | Sales Supervisor |
| Area Sales Manager | ASM | Quản lý vùng |
| Regional Sales Manager | RSM | Quản lý khu vực |
| Nhà phân phối | NPP | Distributor |
| Key Performance Indicator | KPI | Chỉ số đánh giá hiệu suất |
| General Trade | GT | Kênh truyền thống |
| Modern Trade | MT | Kênh hiện đại |
| Point of Sale Material | POSM | Vật phẩm trưng bày |
| Stock Keeping Unit | SKU | Mã sản phẩm |
| Xuất nhập tồn | XNT | Inventory movement |

### 11.2 Tài liệu tham chiếu
- docs/baocaochucnang.md - Bảng mô tả chức năng
- docs/1. DILIGO.TaiLieu.NVBH.md - Tài liệu hướng dẫn NVBH
- docs/2. DILIGO.TaiLieu.ThucHanh_GSBH.md - Tài liệu thực hành GSBH
- docs/3. DILIGO.TaiLieu.ThucHanh_AdminNPP.md - Tài liệu Admin NPP
- docs/khach_hang.csv - Dữ liệu mẫu khách hàng
- docs/san_pham.csv - Dữ liệu mẫu sản phẩm
- docs/nha_phan_phoi.csv - Dữ liệu mẫu NPP

---

**Document Version:** 1.0
**Created Date:** 2026-02-02
**Last Updated:** 2026-02-02
**Author:** Product Team
**Status:** Draft
