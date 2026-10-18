# Personal File Storage

Website lưu trữ cá nhân ảnh/video với đăng nhập, thư mục, xem trước, tải xuống và xóa tệp. Dữ liệu lưu trong Supabase Storage riêng tư; chính sách RLS giới hạn theo tài khoản.

## Triển khai GitHub Pages
1. Vào **Settings → Pages**.
2. Chọn **Deploy from a branch**, branch **main**, folder **/(root)**.
3. Website sẽ mở tại `https://baorlinh-adl.github.io/personal-file-storage/`.

Trang chủ `index.html` tự chuyển tới `storage.html`.

## Giới hạn tải tệp
Tệp lớn hơn 6 MB dùng TUS resumable upload để hỗ trợ thử lại/tiếp tục khi mạng gián đoạn. Điều này **không bỏ giới hạn của nhà cung cấp**: Supabase Free hiện cho phép tối đa 50 MB/tệp; các gói trả phí có thể cấu hình cao hơn (tối đa 500 GB theo tài liệu Supabase). Dung lượng lưu trữ và băng thông vẫn phụ thuộc hạn mức/gói.

## Supabase
- Frontend chỉ dùng publishable key; không đưa service-role/secret key vào website công khai.
- `supabase-setup.sql` là tài liệu schema/policy đã dùng cho dự án Supabase hiện tại. Không chạy lại nếu các bảng/policy đã tồn tại, trừ khi biết cách xử lý migration.
