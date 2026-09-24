# 🛡️ TubeShield - YouTube Chặn Quảng Cáo & Chạy Nền Cho iOS 18

Ứng dụng iOS native chuyên biệt dành cho iOS 18 / iOS 17 giúp bạn xem YouTube mượt mà, **sạch bóng 100% quảng cáo**, hỗ trợ **phát nhạc khi tắt màn hình (Background Audio)**, **bỏ qua đoạn tài trợ (SponsorBlock)** và **Picture-in-Picture (PiP)**.

---

## 🌟 Các tính năng nổi bật

| Tính năng | Mô tả chi tiết |
| :--- | :--- |
| 🚫 **Chặn quảng cáo triệt để** | Tự động chặn và bỏ qua toàn bộ quảng cáo video (Pre-roll, Mid-roll), xóa sạch banner quảng cáo trên trang chủ, kết quả tìm kiếm và dưới video. |
| 🎵 **Phát trong nền (Background Play)** | Tiếp tục phát âm thanh khi bạn khóa màn hình iPhone hoặc chuyển sang ứng dụng khác. |
| 📱 **Đầy đủ Lock Screen & Dynamic Island** | Hiển thị tên bài hát, hình thu nhỏ (Thumbnail), kênh phát và các nút tua 10s, play/pause ngay trên Màn hình khóa và Trung tâm điều khiển. |
| ⚡ **Tự động bỏ qua tài trợ (SponsorBlock)** | Tự động phát hiện và nhảy qua các đoạn video được tài trợ, giới thiệu, kêu gọi subscribe,... |
| 📺 **Picture-in-Picture (PiP)** | Tự động thu nhỏ video thành cửa sổ nổi khi vuốt về Home hoặc bấm nút PiP trên thanh công cụ. |
| ⚙️ **Bảng điều khiển tuỳ biến** | Cho phép bật/tắt từng tính năng theo nhu cầu, hỗ trợ chế độ xem Desktop và nút xoá sạch cache/cookies. |

---

## 🚀 Hướng Dẫn Build File .ipa Từ Windows (Miễn Phí Qua GitHub Actions)

Vì bạn đang dùng máy tính Windows và không có Xcode cục bộ, dự án đã được tích hợp sẵn luồng **GitHub Actions CI/CD** chạy trên máy chủ **macOS 14 (Apple Silicon)** để tự động dịch mã nguồn và đóng gói thành file `TubeShield.ipa` hoàn toàn miễn phí.

### Bước 1: Đẩy mã nguồn lên GitHub của bạn
1. Mở Terminal (PowerShell) tại thư mục dự án này.
2. Khởi tạo và đẩy lên repo GitHub của bạn:
   ```powershell
   git add .
   git commit -m "Initial commit for TubeShield iOS 18"
   git branch -M main
   # Thay đường dẫn bên dưới bằng URL repository trên GitHub của bạn:
   git remote add origin https://github.com/<tai-khoan-cua-ban>/TubeShield.git
   git push -u origin main
   ```

### Bước 2: Tải file .ipa từ GitHub Actions
1. Truy cập vào kho lưu trữ (repository) của bạn trên trình duyệt web GitHub.
2. Bấm vào tab **Actions** ở menu phía trên.
3. Bạn sẽ thấy quy trình **"Build TubeShield iOS App (.ipa)"** đang chạy (hoặc có thể bấm vào và chọn **Run workflow**).
4. Đợi khoảng 2-3 phút cho đến khi có dấu tích xanh ✅ hoàn thành.
5. Bấm vào lượt chạy đó, kéo xuống phần **Artifacts** và tải về file:
   👉 **`TubeShield-iOS-IPA`** (giải nén ra sẽ có file `TubeShield.ipa`).

---

## 📲 Hướng Dẫn Cài Đặt File .ipa Lên iPhone (iOS 18)

Có nhiều cách để cài đặt file `.ipa` lên iPhone từ Windows. Khuyên dùng **Sideloadly** vì cực kỳ đơn giản và ổn định nhất.

### Cách 1: Sử dụng Sideloadly (Khuyên dùng nhất trên Windows)
1. Tải và cài đặt **[Sideloadly](https://sideloadly.io/)** trên máy tính Windows.
2. Cài đặt iTunes và iCloud bản chuẩn từ Apple (nếu chưa có, Sideloadly sẽ tự gợi ý tải).
3. Cắm iPhone vào máy tính bằng cáp USB (trên màn hình iPhone, chọn **Tin cậy máy tính này** nếu được hỏi).
4. Mở phần mềm **Sideloadly**:
   - Kéo file `TubeShield.ipa` thả vào ô biểu tượng IPA trong Sideloadly.
   - Nhập **Apple ID** của bạn vào ô *Apple ID* (Apple ID này chỉ dùng để ký chứng chỉ nhà phát triển miễn phí 7 ngày từ Apple).
   - Bấm nút **Start**.
5. Nhập mật khẩu Apple ID (và mã xác thực 2FA gửi về iPhone nếu có).
6. Đợi 1 phút báo **Done**! App **TubeShield** sẽ xuất hiện trên màn hình chính của iPhone.

---

### Bước Kích Hoạt Quyền Trên iOS 18 (Bắt buộc cho lần đầu)

Sau khi cài xong, khi mở app có thể iOS sẽ hiện thông báo *"Nhà phát triển doanh nghiệp không đáng tin cậy"* hoặc yêu cầu bật Developer Mode:

1. **Bật Chế độ Nhà phát triển (Developer Mode) trên iOS 18**:
   - Vào **Cài đặt (Settings)** -> **Quyền riêng tư & Bảo mật (Privacy & Security)**.
   - Kéo xuống dưới cùng chọn **Chế độ nhà phát triển (Developer Mode)** -> Bật **On**.
   - Khởi động lại iPhone theo yêu cầu. Sau khi máy khởi động lại, bấm **Bật (Turn On)** và nhập mật mã iPhone.

2. **Tin cậy chứng chỉ ứng dụng**:
   - Vào **Cài đặt (Settings)** -> **Cài đặt chung (General)** -> **Quản lý VPN & Thiết bị (VPN & Device Management)**.
   - Dưới mục *Ứng dụng của nhà phát triển*, bấm vào tài khoản Apple ID của bạn.
   - Bấm **Tin cậy (Trust)...** -> Xác nhận **Tin cậy**.

🎉 **Hoàn tất!** Giờ bạn có thể mở **TubeShield** và thưởng thức YouTube không còn một mẩu quảng cáo nào!

---

## 💻 Dành Cho Người Dùng Có Máy Mac (Nếu cần)
Nếu bạn có máy Mac hoặc máy ảo macOS:
1. Mở file `TubeShield.xcodeproj` bằng **Xcode 15/16**.
2. Chọn thiết bị đích là iPhone của bạn (hoặc iOS Simulator).
3. Trong tab **Signing & Capabilities**, chọn Team của bạn.
4. Bấm nút **Run (Cmd + R)** để cài trực tiếp vào iPhone.

---

## 🛠️ Cấu Trúc Mã Nguồn

```
├── .github/workflows/
│   └── build.yml               # CI/CD tự động build .ipa trên macOS runner
├── TubeShield/
│   ├── TubeShieldApp.swift     # Điểm khởi chạy app, cấu hình AVAudioSession nền
│   ├── ContentView.swift       # Giao diện chính SwiftUI, thanh điều hướng hiện đại
│   ├── Settings/
│   │   ├── AppSettings.swift   # Quản lý cấu hình (UserDefaults)
│   │   └── SettingsView.swift  # Màn hình cài đặt các chế độ chặn & nền
│   ├── WebView/
│   │   ├── YouTubeWebView.swift    # Cầu nối WKWebView và SwiftUI
│   │   ├── WebViewCoordinator.swift# Quản lý script và navigation
│   │   └── MediaManager.swift      # Đồng bộ Lock Screen & Dynamic Island
│   ├── Resources/
│   │   ├── Scripts/
│   │   │   ├── adblock.js          # Chặn & tua tốc độ cao mọi quảng cáo video
│   │   │   ├── sponsorblock.js     # Tự động nhảy qua phân đoạn tài trợ
│   │   │   ├── background_play.js  # Giữ phát nhạc nền & trích xuất metadata
│   │   │   └── pip_controller.js   # Kích hoạt Picture-in-Picture
│   │   └── Rules/
│   │       └── adblock_content_rules.json # Bộ lọc chặn domain quảng cáo WebKit
│   ├── Assets.xcassets/        # Biểu tượng ứng dụng TubeShield iOS 18
│   ├── Info.plist              # Quyền chạy nền Audio và cấu hình mạng
│   └── TubeShield.entitlements # Cấu hình entitlement
└── TubeShield.xcodeproj/
    └── project.pbxproj         # File dự án Xcode chuẩn
```
