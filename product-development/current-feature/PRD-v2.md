# Product Requirements Document (PRD) - Version 2.0
## Hệ thống Quản lý Phân phối (DMS - Distribution Management System) cho VIPPro

---

## Changelog từ Version 1.0

| Version | Ngày | Thay đổi chính |
|---------|------|----------------|
| 2.3 | 2026-02-03 | Cập nhật tên cột báo cáo trưng bày VIP theo file thực tế (NV Chụp thực tế), sửa tên file tham chiếu |
| 2.2 | 2026-02-03 | Bổ sung chức năng GSBH Mobile (Mở mới NPP, Quản lý tuyến, Chia KPI), chi tiết hóa chế độ Van-sale, cập nhật báo cáo trưng bày VIP, sửa lỗi tham chiếu tài liệu |
| 2.1 | 2026-02-03 | Bổ sung chi tiết quy trình NVBH/GSBH/Admin NPP từ tài liệu thực hành, cập nhật cấu trúc đơn vị theo file CSV mới, chi tiết hóa báo cáo bán hàng theo nhân viên |
| 2.0 | 2026-02-03 | Cập nhật cấu trúc dữ liệu Master Data dựa trên dữ liệu thực tế, bổ sung báo cáo mới, chi tiết hóa yêu cầu chức năng |
| 1.0 | 2026-02-02 | Phiên bản khởi tạo |

---

## 1. Tổng quan sản phẩm

### 1.1 Tên sản phẩm
**DMS VIPPro** - Hệ thống Quản lý Phân phối

### 1.2 Tầm nhìn sản phẩm
Xây dựng một hệ thống DMS toàn diện giúp VIPPro quản lý hiệu quả mạng lưới phân phối, giám sát hoạt động bán hàng thực địa, và tối ưu hóa quy trình từ đặt hàng đến giao hàng trên toàn quốc.

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
| **Báo cáo chấm điểm trưng bày** | - Chấm điểm trưng bày VIP<br>- Đánh giá Đạt/Không đạt<br>- Theo dõi NV chụp và NV chấm điểm<br>- Thống kê số lượng hình ảnh đã upload | Báo cáo trưng bày |

##### Module Bán hàng

| Chức năng | Mô tả chi tiết | Vị trí tham chiếu |
|-----------|----------------|-------------------|
| **Quản lý khách hàng** | - Danh sách KH với thông tin mở rộng<br>- Vị trí KH trên bản đồ (Google Maps integration)<br>- Thông tin liên hệ (lãnh đạo, nhân viên,...)<br>- Lịch sử cập nhật, viếng thăm, đặt hàng<br>- Hình ảnh và ghi chú KH<br>- Quản lý hạn mức công nợ<br>- Phân tuyến: Mã tuyến, Tên tuyến, Tên nhóm tuyến, NV phụ trách | 4.1 Khách Hàng |
| **Quản lý sản phẩm** | - Danh mục sản phẩm mở rộng<br>- Đơn vị tính, hệ số quy đổi<br>- Giá nhập, giá bán NPP, giá bán KH<br>- Phân loại theo ngành/nhãn hiệu/NCC<br>- Hình ảnh sản phẩm<br>- Cảnh báo tồn kho | 4.2 Sản Phẩm |
| **Quản lý đặt hàng** | - Tiếp nhận phiếu đặt hàng từ mobile<br>- Lập phiếu đặt hàng từ email/điện thoại/web<br>- Xét duyệt đơn hàng (Chờ duyệt → Đã duyệt/Từ chối)<br>- Sửa đơn hàng ở trạng thái chờ duyệt<br>- Lập phiếu bán hàng từ đặt hàng<br>- In phiếu | 4.8 Phiếu Đặt Hàng |
| **Quản lý bán hàng** | - Danh sách phiếu bán hàng<br>- Lập/hiệu chỉnh phiếu bán hàng<br>- Quy trình: Đặt hàng → Duyệt → Bán hàng → Xuất kho<br>- Lập phiếu xuất kho từ bán hàng (trừ tồn kho)<br>- Lập phiếu trả hàng (từ phiếu bán hoặc tạo mới)<br>- Theo dõi công nợ tự động<br>- Xuất Excel cho ERP Oracle<br>- In phiếu | 3.4 Phiếu Bán Hàng |
| **Quản lý kho hàng** | - Phiếu xuất/nhập/chuyển kho<br>- Lập phiếu nhập kho với Lô/Date<br>- Lập phiếu chuyển kho giữa các kho NPP<br>- Chuyển kho Van-sale cho NVBH theo xe<br>- In phiếu kho | 4.11 Kho Hàng |
| **Quản lý trả hàng** | - Danh sách phiếu trả hàng<br>- Lập phiếu trả từ phiếu bán hoặc tạo mới<br>- Quy trình: Tạo → Duyệt → Nhập trả<br>- Tự động lập phiếu nhập kho<br>- In phiếu | 4.10 Phiếu Trả Hàng |
| **Quản lý công nợ** | - Phiếu điều chỉnh công nợ (tăng nợ/giảm nợ)<br>- Phiếu thu nợ với phân bổ tự động<br>- Phiếu hoàn tiền<br>- In phiếu thu/chi<br>- Theo dõi công nợ theo khách hàng | 4.14 Công nợ |
| **Kiểm kê kho hàng** | - Tạo phiếu kiểm kê<br>- Lấy dữ liệu kiểm kê theo ngày/kho<br>- So sánh tồn thực tế với tồn hệ thống<br>- Chốt dữ liệu kiểm kê<br>- Khóa phiếu điều chỉnh khi đang kiểm kê | Kiểm kê kho |
| **Quản lý Lô/Date sản phẩm** | - Tạo lô date cho sản phẩm nhập kho<br>- Theo dõi hạn sử dụng<br>- Xuất hàng theo date (FIFO)<br>- Một sản phẩm có thể có nhiều lô date | Lô Date |
| **Quản lý khuyến mại** | - Đa dạng hình thức KM<br>- KM theo số lượng/giá trị<br>- Áp dụng theo loại/nhóm KH<br>- Áp dụng theo thời gian | 6.7 Báo cáo KM |

##### Module Báo cáo

| Chức năng | Mô tả chi tiết | Vị trí tham chiếu |
|-----------|----------------|-------------------|
| **Báo cáo giám sát** | - BC viếng thăm KH<br>- Thống kê hình ảnh<br>- Tần suất viếng thăm<br>- Bảng chấm công tháng<br>- Tổng hợp viếng thăm & KPI | 6.1 Báo cáo Giám Sát |
| **Báo cáo KPI** | Kết quả thực hiện KPI theo tháng | 6.1.10 Tổng Hợp KPI |
| **Báo cáo khuyến mại** | Tổng hợp kết quả CTKM theo SP | 6.7 Báo cáo KM |
| **Báo cáo bán hàng** | - Theo khách hàng<br>- Theo sản phẩm<br>- Theo NVBH<br>- Chi tiết: Số đơn, SL, Đơn giá, VAT, Thành tiền, Chiết khấu SP, Chiết khấu ĐH, Doanh thu thuần, Doanh thu | 6.4 Báo cáo bán hàng |
| **Thống kê bán hàng** | - Theo KH/loại KH/nhóm KH<br>- Theo khu vực địa lý<br>- Theo ngành/nhãn hàng/SP<br>- Theo NV/nhóm bán hàng | 6.5 Thống kê bán hàng |
| **Báo cáo kho** | - Xuất nhập tồn kho (chi tiết SL chẵn/lẻ)<br>- Tổng hợp XNT<br>- Tồn đầu kỳ, Nhập trong kỳ, Xuất trong kỳ, Tồn cuối kỳ<br>- Tồn KH/tồn thị trường | 6.9.1 Báo cáo XNT |
| **Báo cáo tổng hợp viếng thăm & doanh số** | - Số lần viếng thăm<br>- Số đơn hàng<br>- Tỷ lệ đơn hàng thành công / số lần viếng thăm (%)<br>- Số SKU đặt<br>- Bình quân SKU/đơn<br>- Doanh số, Doanh thu, Doanh thu thuần | Báo cáo tổng hợp |
| **Bảng chấm công tháng** | - Chi tiết theo ngày (1-31)<br>- Thông tin: Vào đầu, Ra cuối, Trễ, Sớm, T.Giờ, Công<br>- Tổng hợp: Ngày đi làm, Trễ, Sớm, Tổng giờ, Ngày công | Chấm Công |

#### B. PHÂN HỆ MOBILE (Ứng dụng cho NVBH)

| Chức năng | Mô tả chi tiết |
|-----------|----------------|
| **Xem thông tin khách hàng** | - Tra cứu KH trên tuyến<br>- Cập nhật thông tin KH<br>- Quản lý giao dịch, ghi chú, phản hồi |
| **Xem thông tin sản phẩm** | - Tra cứu SP được phép bán<br>- Tra cứu tồn kho SP |
| **Tra cứu khuyến mại** | Xem CTKM còn hiệu lực |
| **Thực hiện viếng thăm** | - Chăm sóc KH trên tuyến<br>- Thêm mới KH<br>- Check-in/Check-out với GPS<br>- Chụp hình trưng bày<br>- Kiểm tồn khách hàng<br>- Ghi chú và gửi người nhận<br>- Xử lý KH đóng cửa/chủ đi vắng |
| **Quản lý đơn hàng** | - Danh sách đơn hàng (hôm nay/tuần/tháng)<br>- Theo dõi trạng thái (chờ duyệt/đã duyệt/đã xuất)<br>- Cập nhật đơn hàng chờ gửi<br>- **Bán hàng thường (Pre-sales)**: Đặt hàng và gửi về NPP duyệt<br>- **Bán hàng theo xe (Van-sales)**: Bán và giao hàng ngay tại điểm, trừ tồn kho Van-sale |
| **Khai báo vị trí** | - Khai báo vị trí hiện tại khi ngoại tuyến<br>- Chụp ảnh kèm khai báo<br>- Đồng bộ dữ liệu lên hệ thống |
| **Xem báo cáo** | - Kết quả bán hàng theo KH/SP<br>- Thực hiện KPI<br>- BC đặt hàng/bán hàng<br>- BC thống kê đa chiều<br>- BC khuyến mại, kho, công nợ<br>- BC khách hàng mới<br>- Nhật ký đi tuyến<br>- Nhật ký di chuyển<br>- Nhật ký chấm công |
| **Chấm công** | - Chấm công vào (đầu ngày) với GPS + hình ảnh<br>- Chấm công ra (cuối ngày) với GPS + hình ảnh<br>- Cho phép chấm công nhiều lần (lấy đầu tiên/cuối cùng) |
| **Thông báo** | Tiếp nhận thông báo từ công ty |
| **Đồng bộ dữ liệu** | - Đồng bộ dữ liệu offline lên hệ thống<br>- Cảnh báo khi chưa đồng bộ |

#### C. PHÂN HỆ MOBILE (Chức năng bổ sung cho GSBH)

| Chức năng | Mô tả chi tiết |
|-----------|----------------|
| **Giám sát vị trí nhân viên** | - Xem danh sách NV với vị trí hiện tại<br>- Xem lịch sử vị trí chi tiết<br>- Xem trên bản đồ |
| **Giám sát viếng thăm KH** | - Xem tình hình viếng thăm theo NV<br>- Chi tiết viếng thăm từng KH |
| **Giám sát chụp ảnh KH** | - Xem danh sách ảnh theo NV<br>- Chi tiết hình ảnh |
| **Báo cáo đặt hàng theo NV** | Tổng hợp đơn đặt hàng theo từng nhân viên |
| **Báo cáo bán hàng theo NV** | Tổng hợp doanh số bán hàng theo từng nhân viên |
| **Báo cáo tổng hợp phân tích KPI** | Theo dõi các chỉ tiêu KPI theo loại |
| **Mở mới NPP** | - Nhập thông tin cơ bản NPP (tên, mã số thuế, địa chỉ, liên hệ)<br>- Thông tin về gia đình chủ NPP<br>- Bất ổn 6 quả phúc<br>- Thông tin về nhân sự<br>- Thông tin về cơ sở hạ tầng<br>- Mục tiêu VIPPro<br>- Chụp ảnh: cửa hàng, chủ NPP, họp NPP, hồ sơ, ĐKKD<br>- Đọc cẩm nang NPP trước khi cập nhật |
| **Quản lý tuyến** | - Tạo tuyến mới (mã tuyến, tên, nhóm, NV phụ trách, ngày đi, ngày bắt đầu)<br>- Thêm KH vào tuyến<br>- Sửa tuyến cho nhiều KH<br>- Import tuyến bằng file Excel |
| **Chia chỉ tiêu KPI cho NV** | - Chỉ tiêu chung (số KH viếng thăm, KH mới, đơn hàng, doanh số, doanh thu, sản lượng, SKU, số giờ làm việc)<br>- Chỉ tiêu sản phẩm trọng tâm<br>- Ngày hiệu lực từ/đến |

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

## 5. Yêu cầu dữ liệu (Cập nhật v2.0)

### 5.1 Master Data

#### Khách hàng (Customer Master) - Cập nhật

| Trường dữ liệu | Kiểu | Bắt buộc | Mô tả |
|---------------|------|----------|-------|
| ID | String | Có | Mã định danh duy nhất (MongoDB ObjectId) |
| Ngày tạo | DateTime | Có | Timestamp tạo record |
| Người tạo | String | Có | User tạo record |
| Ngày sửa | DateTime | Có | Timestamp cập nhật gần nhất |
| Người sửa | String | Có | User cập nhật gần nhất |
| Ngày thu thập | Date | Không | Ngày thu thập thông tin thực địa |
| Vĩ độ | Float | Có | Tọa độ GPS (Latitude) |
| Kinh độ | Float | Có | Tọa độ GPS (Longitude) |
| Trạng thái | Enum | Có | Hoạt động/Ngừng |
| Mã khách hàng | String | Có | Mã KH theo quy ước (VD: HP2023, HB004Th1_KH_002) |
| Khách hàng | String | Có | Tên khách hàng |
| SĐT | String | Có | Số điện thoại liên hệ |
| Người liên hệ | String | Không | Tên người liên hệ |
| Nhóm khách hàng | Enum | Có | A/B/C/D/E (có nhãn hiển thị) |
| Loại khách hàng | Enum | Có | Tạp Hóa, Hiệu Thuốc, Mỹ Phẩm, Thời Trang... (có nhãn) |
| Kênh | Enum | Có | GT/MT (có nhãn) |
| Google Maps | String | Không | Link Google Maps |
| Địa chỉ giao hàng | String | Có | Địa chỉ chi tiết |
| Khu vực | String | Có | Mã khu vực (có nhãn: Hà Nội, Hải Phòng...) |
| Sinh nhật | Date | Không | Ngày sinh nhật |
| Chức vụ | String | Không | Chức vụ người liên hệ |
| Email | String | Không | Email liên hệ |
| Hình ảnh | URL | Không | URL ảnh cửa hàng |
| Hạn mức công nợ | Number | Không | Giới hạn nợ cho phép |
| Mã tuyến | String | Có | Mã tuyến bán hàng (VD: HP2023, HB004Th1) |
| Tên tuyến | String | Có | Tên tuyến (VD: HP009 - CVPV 4 - T6) |
| Tên nhóm tuyến | String | Có | Tên nhóm tuyến (VD: 2017-Niva) |
| Tên nhân viên tuyến | String | Có | NV phụ trách tuyến |
| Cấm sửa vị trí | Boolean | Không | Lock chỉnh sửa vị trí GPS |
| Khóa | Boolean | Không | Lock toàn bộ record |

#### Sản phẩm (Product Master) - Cập nhật

| Trường dữ liệu | Kiểu | Bắt buộc | Mô tả |
|---------------|------|----------|-------|
| ID | String | Có | Mã định danh (MongoDB ObjectId) |
| Ngày tạo | DateTime | Có | Timestamp tạo |
| Người tạo | String | Có | User tạo |
| Ngày sửa | DateTime | Có | Timestamp cập nhật |
| Người sửa | String | Có | User cập nhật |
| Trạng thái | Enum | Có | Active/Inactive |
| Số thứ tự | Number | Không | Thứ tự hiển thị |
| Nhãn hiệu | String | Có | Mã nhãn hiệu (VD: POSM, Lipzo) |
| Nhãn Nhãn hiệu | String | Có | Tên hiển thị nhãn hiệu |
| Mã sản phẩm | String | Có | SKU (VD: 241000001, 411000133) |
| Tên sản phẩm | String | Có | Tên đầy đủ sản phẩm |
| Ngành hàng | String | Có | Mã ngành hàng (VD: 24 = POSM) |
| Nhãn Ngành hàng | String | Có | Tên hiển thị ngành hàng |
| Nhà cung cấp | String | Không | Mã nhà cung cấp |
| Nhãn Nhà cung cấp | String | Không | Tên hiển thị NCC |
| ĐVT chẵn | String | Có | Đơn vị tính chẵn (Cái, Thùng, Túi) |
| Nhãn ĐVT chẵn | String | Có | Tên hiển thị ĐVT chẵn |
| ĐVT lẻ | String | Có | Đơn vị tính lẻ |
| Nhãn ĐVT lẻ | String | Có | Tên hiển thị ĐVT lẻ |
| Hệ số quy đổi | Number | Có | Conversion rate (chẵn → lẻ) |
| Cảnh báo tồn kho | Number | Không | Ngưỡng cảnh báo tồn kho thấp |
| Giá nhập | Number | Có | Giá nhập (chẵn) |
| Giá nhập lẻ | Number | Có | Giá nhập (lẻ) |
| Giá | Number | Có | Giá bán (chẵn) |
| Giá lẻ | Number | Có | Giá bán (lẻ) |
| VAT | Number | Có | Thuế suất (0, 5, 8, 10) |
| Nhãn VAT | String | Có | Hiển thị VAT |
| Mô tả | String | Không | Mô tả sản phẩm |
| Hình ảnh | URL | Không | URL hình ảnh sản phẩm |
| Ngày cập nhật | DateTime | Không | Timestamp cập nhật giá |
| Khóa | Boolean | Không | Lock record |

#### Nhà phân phối (Distributor Master) - Cập nhật

| Trường dữ liệu | Kiểu | Bắt buộc | Mô tả |
|---------------|------|----------|-------|
| ID | String | Có | Mã định danh (MongoDB ObjectId) |
| Ngày tạo | DateTime | Có | Timestamp tạo |
| Người tạo | String | Có | User tạo |
| Ngày sửa | DateTime | Có | Timestamp cập nhật |
| Người sửa | String | Có | User cập nhật |
| Ngày thu thập | Date | Không | Ngày thu thập thông tin |
| Vĩ độ | Float | Không | Tọa độ GPS |
| Kinh độ | Float | Không | Tọa độ GPS |
| Trạng thái | Enum | Có | Hoạt động/Thanh lý |
| Loại NPP | Enum | Có | NPP/Đại lý/Tổng thầu (có nhãn: NPP, DL) |
| Mã nhà phân phối | String | Có | Distributor code (VD: 229229, 2071) |
| Mã số thuế | String | Có | Tax code |
| Tên nhà phân phối | String | Có | Tên đầy đủ (VD: NPP Đức Bình - Đức Trọng) |
| Tên đơn vị trên HĐGTGT | String | Có | Tên trên hóa đơn VAT |
| Nhóm NPP | Enum | Có | A/B/C/D (có nhãn) |
| Kênh SO | Enum | Có | GT/MT (có nhãn) |
| Khu vực | String | Có | Mã khu vực (VD: A1, A7, A10) |
| Nhãn Khu vực | String | Có | Tên khu vực hiển thị |
| Tỉnh/TP | String | Có | Mã tỉnh/TP (VD: 68, 22, 01) |
| Nhãn Tỉnh/TP | String | Có | Tên tỉnh (Tỉnh Lâm Đồng, Tỉnh Quảng Ninh) |
| Địa chỉ khách hàng trên HĐGTGT | String | Có | Địa chỉ trên hóa đơn |
| Tên địa điểm giao hàng | String | Có | Tên điểm giao hàng |
| Địa chỉ giao hàng | String | Có | Địa chỉ giao hàng |
| Người liên hệ | String | Có | Contact person |
| Đại diện pháp nhân | String | Có | Legal representative |
| Địa chỉ văn phòng | String | Không | Office address |
| Địa chỉ kho | String | Không | Warehouse address |
| Email/Fax | String | Không | Email liên hệ |
| Số điện thoại | String | Có | Phone number |
| Ngân hàng | String | Không | Mã ngân hàng (VD: MB) |
| Nhãn Ngân hàng | String | Không | Tên ngân hàng (MB - Ngân hàng Quân Đội) |
| Số tài khoản ngân hàng | String | Không | Bank account number |
| Số chứng minh thư | String | Không | CMND/CCCD |
| Giấy đăng ký kinh doanh | String | Không | Business license number |
| Ảnh đại diện | URL[] | Không | Avatar images (multiple) |
| Ảnh cửa hàng | URL[] | Không | Store photos |
| Ảnh chủ NPP | URL[] | Không | Owner photos |
| Ảnh họp NPP | URL[] | Không | Meeting photos |
| Ảnh hồ sơ | URL[] | Không | Profile documents |
| Ảnh ĐKKD | URL[] | Không | Business license images |

#### Đơn vị & Nhóm bán hàng (Organization Structure) - MỚI

| Trường dữ liệu | Kiểu | Bắt buộc | Mô tả |
|---------------|------|----------|-------|
| # | String | Có | Hierarchical index (VD: 1.1.1.2.1.1) |
| Mã đơn vị | String | Có | Unit code |
| Tên đơn vị | String | Có | Unit name |
| Giám sát | Boolean | Không | Là đơn vị giám sát (x = true) |
| Nhóm bán hàng | Boolean | Không | Là nhóm bán hàng (x = true) |
| Mã cha | String | Không | Parent unit code |

**Cấu trúc phân cấp (Cập nhật v2.1):**
```
VIPPro
├── BPTKH (Bộ phận Thị trường Kinh doanh)
│   ├── GT (General Trade - Kênh truyền thống)
│   │   ├── OTC
│   │   │   ├── Bắc (Giám sát, Nhóm BH)
│   │   │   └── Nam (Giám sát, Nhóm BH)
│   │   ├── R1 (Miền Bắc)
│   │   │   ├── A1+A2
│   │   │   │   ├── A1 (Hà Nội và lân cận)
│   │   │   │   │   ├── NPP An Khang - Hà Đông
│   │   │   │   │   │   ├── Lipzo (Nhóm BH)
│   │   │   │   │   │   ├── Niva (Nhóm BH)
│   │   │   │   │   │   └── Tổng Hợp (Giám sát, Nhóm BH)
│   │   │   │   │   ├── NPP Thanh Xuân - Từ Liêm
│   │   │   │   │   ├── NPP Bảo Anh - Sơn Tây
│   │   │   │   │   └── ... (các NPP khác)
│   │   │   │   └── A2 (Phú Thọ, Tuyên Quang, Yên Bái)
│   │   │   ├── A3 (Thái Nguyên, Bắc Ninh, Bắc Giang, Hưng Yên, Lạng Sơn)
│   │   │   ├── A4 (Hải Phòng, Quảng Ninh, Nam Định, Ninh Bình)
│   │   │   └── A5 (Thanh Hóa, Nghệ An, Hà Tĩnh)
│   │   └── R2 (Miền Trung & Nam)
│   │       ├── A6 (Huế, Đà Nẵng, Quảng Nam, Quảng Ngãi, Quảng Bình, Quảng Trị)
│   │       ├── A7 (Tây Nguyên: Gia Lai, Kon Tum, Đắk Lắk, Đắk Nông, Lâm Đồng)
│   │       ├── A8 (ĐBSCL: Cần Thơ, An Giang, Hậu Giang, Sóc Trăng, Bạc Liêu, Kiên Giang)
│   │       ├── A9 (TP. Hồ Chí Minh)
│   │       ├── A10 (Đông Nam Bộ: Đồng Nai, Bình Dương, Bình Phước, Tây Ninh, Bà Rịa-Vũng Tàu)
│   │       ├── A11 (Tiền Giang, Trà Vinh, Cà Mau)
│   │       └── A12
│   └── MT (Modern Trade - Kênh hiện đại)
│       ├── MTMB (Miền Bắc)
│       │   ├── Nguyễn Thị Chiển (Giám sát, Nhóm BH)
│       │   ├── Nguyễn Thị Nên (Giám sát, Nhóm BH)
│       │   ├── Phạm Thanh Hải (Nhóm BH)
│       │   └── Võ Huỳnh Sang (Giám sát, Nhóm BH)
│       └── MTMN (Miền Nam)
│           ├── Lê Hùng Việt (Giám sát, Nhóm BH)
│           ├── Nguyễn Thị Bích Chi (Giám sát, Nhóm BH)
│           └── ... (các NV khác)
├── Kho Vận
│   ├── KVMB (Kho vận Miền Bắc - Giám sát, Nhóm BH)
│   └── KVMN (Kho vận Miền Nam - Giám sát, Nhóm BH)
└── Nhóm KT (Kế toán)
```

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
| GS-04 | Là RSM, tôi muốn xem báo cáo tổng hợp viếng thăm & doanh số | - Hiển thị số lần VT, số đơn hàng, tỷ lệ thành công<br>- Hiển thị Số SKU đặt, Bình quân SKU/đơn<br>- Hiển thị Doanh số, Doanh thu, Doanh thu thuần<br>- Filter theo thời gian, NV, KH |
| GS-05 | Là GSBH, tôi muốn chấm điểm trưng bày | - Xem danh sách hình ảnh cần chấm<br>- Chấm Đạt/Không đạt<br>- Ghi nhận NV chụp và NV chấm điểm<br>- Thống kê kết quả chấm điểm |

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
| BH-04 | Là Admin NPP, tôi muốn xem báo cáo XNT | - Hiển thị Tồn đầu kỳ (SL, SL chẵn, SL lẻ, Giá trị)<br>- Hiển thị Nhập trong kỳ (SL, Giá trị, Giá trị nhập)<br>- Hiển thị Xuất trong kỳ (SL, Giá trị, Giá trị bán)<br>- Hiển thị Tồn cuối kỳ (SL, Giá trị)<br>- Filter theo kho, thời gian |

### 7.4 Module Chấm công

| ID | User Story | Acceptance Criteria |
|----|-----------|---------------------|
| CC-01 | Là GSBH, tôi muốn xem bảng chấm công tháng | - Hiển thị grid theo ngày (1-31) với thứ trong tuần<br>- Mỗi ngày hiển thị: Vào đầu, Ra cuối, Trễ, Sớm, T.Giờ, Công<br>- Tổng hợp: Ngày đi làm, Trễ, Sớm, Tổng giờ, Ngày công<br>- Filter theo NV, phòng/nhóm |

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
| Bình quân SKU/đơn | > 3 SKU | Từ báo cáo tổng hợp |

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
| Hóa đơn giá trị gia tăng | HĐGTGT | VAT Invoice |

### 11.2 Tài liệu tham chiếu
- docs/baocaochucnang.md - Bảng mô tả chức năng
- docs/1. VIPPro.TaiLieu.NVBH.md - Tài liệu hướng dẫn NVBH
- docs/1. VIPPro.TaiLieu.ThucHanh_NVBH.md - Tài liệu thực hành NVBH
- docs/2. VIPPro.TaiLieu.ThucHanh_GSBH.md - Tài liệu thực hành GSBH
- docs/3. VIPPro.TaiLieu.ThucHanh_AdminNPP.md - Tài liệu Admin NPP
- docs/3. VIPPro.TaiLieu.ThucHanh_AdminNPP2.md - Tài liệu Admin NPP (phần 2)
- docs/khach_hang.csv - Dữ liệu mẫu khách hàng
- docs/san_pham.csv - Dữ liệu mẫu sản phẩm
- docs/nha_phan_phoi.csv - Dữ liệu mẫu NPP
- docs/6.4.csv - Báo cáo bán hàng theo nhân viên
- docs/XNT T9 2025(Sheet 1).csv - Báo cáo xuất nhập tồn
- docs/Báo cáo tổng hợp Viếng Thăm và Doanh Số(Sheet 1).csv - Báo cáo tổng hợp
- docs/Chấm Công Tháng 8 2025(TimeSheet).csv - Bảng chấm công
- docs/Báo cáo trưng bày T8 2025.csv - Báo cáo chấm điểm trưng bày VIP
- docs/Danh sách tài khoản và Case đơn vị(Đơn vị, nhóm bán hàng).csv - Cấu trúc đơn vị

### 11.3 Cấu trúc báo cáo chi tiết

#### Báo cáo bán hàng theo nhân viên (6.4)

| Trường dữ liệu | Kiểu | Mô tả |
|---------------|------|-------|
| # | String | Số thứ tự phân cấp (VD: 1.1, 1.2) |
| Phòng/nhóm | String | Mã nhóm bán hàng (VD: 2071-Lipzo) |
| Tên nhân viên | String | Họ tên NVBH |
| Mã sản phẩm | String | SKU sản phẩm |
| Tên sản phẩm | String | Tên đầy đủ sản phẩm |
| ĐVT | String | Đơn vị tính |
| Số đơn | Number | Số lượng đơn hàng |
| SL | Number | Số lượng sản phẩm |
| Đơn giá | Number | Giá bán đơn vị |
| VAT | Number | Thuế VAT |
| Thành tiền | Number | Tổng tiền = SL x Đơn giá |
| Chiết khấu SP | Number | Chiết khấu theo sản phẩm |
| Chiết khấu ĐH | Number | Chiết khấu theo đơn hàng |
| Doanh thu thuần | Number | = Thành tiền - CK SP - CK ĐH |
| Doanh thu | Number | = Doanh thu thuần + VAT |

#### Báo cáo xuất nhập tồn (XNT)

| Trường dữ liệu | Kiểu | Mô tả |
|---------------|------|-------|
| STT | String | Số thứ tự phân cấp theo kho |
| Mã kho | String | Mã định danh kho |
| Tên kho | String | Tên kho hàng |
| Mã hàng | String | SKU sản phẩm |
| Tên hàng | String | Tên sản phẩm |
| ĐVT | String | Đơn vị tính |
| **Tồn đầu kỳ** | | |
| - Số lượng | Number | Tổng số lượng tồn |
| - SL chẵn | Number | Số lượng theo ĐVT chẵn |
| - SL lẻ | Number | Số lượng theo ĐVT lẻ |
| - Giá trị | Number | Giá trị tồn đầu kỳ |
| **Nhập trong kỳ** | | |
| - Số lượng | Number | Tổng số lượng nhập |
| - SL chẵn | Number | Số lượng nhập theo ĐVT chẵn |
| - SL lẻ | Number | Số lượng nhập theo ĐVT lẻ |
| - Giá trị | Number | Giá trị nhập theo giá bán |
| - Giá trị nhập | Number | Giá trị nhập theo giá nhập |
| **Xuất trong kỳ** | | |
| - Số lượng | Number | Tổng số lượng xuất |
| - SL chẵn | Number | Số lượng xuất theo ĐVT chẵn |
| - SL lẻ | Number | Số lượng xuất theo ĐVT lẻ |
| - Giá trị | Number | Giá trị xuất theo giá bán |
| - Giá trị bán | Number | Giá trị bán thực tế |
| **Tồn cuối kỳ** | | |
| - Số lượng | Number | Tổng số lượng tồn cuối |
| - SL chẵn | Number | Số lượng tồn theo ĐVT chẵn |
| - SL lẻ | Number | Số lượng tồn theo ĐVT lẻ |
| - Giá trị | Number | Giá trị tồn cuối kỳ |

#### Báo cáo tổng hợp Viếng thăm và Doanh số

| Trường dữ liệu | Kiểu | Mô tả |
|---------------|------|-------|
| STT | Number | Số thứ tự |
| Mã khách hàng | String | Mã KH |
| Tên khách hàng | String | Tên KH |
| Địa chỉ | String | Địa chỉ KH |
| SĐT | String | Số điện thoại |
| Loại KH | String | Loại khách hàng |
| Nhóm KH | String | Nhóm khách hàng (A/B/C/D/E) |
| Phòng nhóm | String | Mã nhóm bán hàng |
| Mã nhân viên | String | Mã NVBH |
| Tên nhân viên | String | Tên NVBH |
| Số lần VT | Number | Số lần viếng thăm |
| Số đơn hàng | Number | Số đơn hàng đặt được |
| Tỷ lệ ĐH thành công/VT (%) | Number | % đơn hàng / viếng thăm |
| Số SKU đặt | Number | Tổng số SKU trong các đơn |
| Bình quân SKU/đơn | Number | Trung bình SKU mỗi đơn |
| Doanh số | Number | Tổng doanh số đặt hàng |
| Số phiếu bán | Number | Số phiếu bán hàng |
| Số phiếu trả | Number | Số phiếu trả hàng |
| Doanh thu | Number | Doanh thu sau bán |
| Doanh thu thuần | Number | Doanh thu sau chiết khấu |

#### Báo cáo chấm điểm trưng bày (Trưng bày kệ VIP)

| Trường dữ liệu | Kiểu | Mô tả |
|---------------|------|-------|
| STT | Number | Số thứ tự |
| NV Chụp thực tế - Mã | String | Mã NV chụp ảnh thực tế |
| NV Chụp thực tế - Tên | String | Tên NV chụp ảnh thực tế |
| Mã KH | String | Mã khách hàng |
| Tên KH | String | Tên khách hàng |
| Địa chỉ | String | Địa chỉ KH |
| Loại khách hàng | String | Loại KH |
| Nhóm khách hàng | String | Nhóm KH |
| Khu vực | String | Khu vực |
| Kênh | String | GT/MT |
| Doanh số | Number | Doanh số KH |
| Ngày Upload | Date | Ngày upload ảnh |
| SL Hình đã up | Number | Số lượng hình ảnh đã upload |
| Mã NV chấm | String | Mã NV chấm điểm |
| Tên NV chấm điểm | String | Tên NV chấm điểm |
| Ngày chấm | Date | Ngày chấm điểm |
| Đạt | Boolean | Đánh giá Đạt (x) |
| Không đạt | Boolean | Đánh giá Không đạt (x) |

#### Bảng chấm công tháng (TimeSheet)

| Trường dữ liệu | Kiểu | Mô tả |
|---------------|------|-------|
| STT | Number | Số thứ tự |
| Mã nhân viên | String | Mã NV |
| Tên nhân viên | String | Tên NV |
| Ngày (1-31) | | Mỗi ngày gồm các thông tin: |
| - Thứ | String | Thứ trong tuần (T2-CN) |
| - Vào đầu | Time | Thời gian chấm công vào |
| - Ra cuối | Time | Thời gian chấm công ra |
| - Trễ | Time | Thời gian đi trễ |
| - Sớm | Time | Thời gian về sớm |
| - T.Giờ | Number | Tổng số giờ làm việc |
| - Công | Number | Số công (0 hoặc 1) |
| **Tổng hợp** | | |
| Ngày đi làm | Number | Tổng số ngày có chấm công |
| Trễ | Number | Tổng số lần đi trễ |
| Sớm | Number | Tổng số lần về sớm |
| T.Giờ | Number | Tổng số giờ làm việc |
| Ngày công | Number | Tổng số ngày công |

---

**Document Version:** 2.3
**Created Date:** 2026-02-02
**Last Updated:** 2026-02-03
**Author:** Product Team
**Status:** Draft
**Previous Version:** [PRD.md](PRD.md)
