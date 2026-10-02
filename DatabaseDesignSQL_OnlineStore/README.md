# Database Design & SQL - Online Sales Management System

## Thông tin học viên
- Họ tên: [ĐIỀN HỌ TÊN]
- Mã số học viên: [ĐIỀN MSHV]
- Lớp: [ĐIỀN LỚP]

## Công nghệ
- MySQL 8.0+
- MySQL Workbench
- Git / GitHub

## Cấu trúc database
Hệ thống gồm 8 bảng:
1. `categories` - danh mục.
2. `products` - sản phẩm.
3. `customers` - khách hàng.
4. `addresses` - địa chỉ giao hàng.
5. `orders` - đơn hàng.
6. `order_items` - chi tiết đơn hàng, giải quyết quan hệ N-N giữa order và product.
7. `payments` - thanh toán.
8. `reviews` - đánh giá sản phẩm.

## Cách chạy
Mở MySQL Workbench và chạy lần lượt:
1. `sql/01_schema.sql`
2. `sql/02_seed_data.sql`
3. `sql/03_queries.sql`
4. `sql/04_advanced.sql`

Yêu cầu MySQL 8.0+ để dùng CTE và window functions.

## Nội dung kỹ thuật
- PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT.
- Chuẩn hóa đến 3NF.
- 4 index.
- 1 view: `vw_order_summary`.
- 1 stored procedure: `sp_customer_order_history`.
- 2 trigger: kiểm tra tồn kho và tự động cập nhật tổng tiền/trừ kho.
- 15 query mẫu: SELECT, JOIN, LEFT JOIN, GROUP BY, subquery, nested query, CASE, pagination, CTE, ROW_NUMBER, DENSE_RANK.
- Transaction demo.
- Ví dụ phân quyền và backup/restore.

## ERD
Xem `erd/ERD_OnlineStore.png` hoặc `erd/ERD.md`.

## Chụp ảnh kết quả
Mở `03_queries.sql`, chạy từng query và chụp phần Result Grid trong MySQL Workbench. Đặt tên ảnh gợi ý:
`Q01.png`, `Q02.png`, ..., `Q15.png`.
Có thể tạo thư mục `screenshots/` rồi commit ảnh lên GitHub.

## Gợi ý Git
```bash
git init
git add .
git commit -m "Initial database design and SQL assignment"
git branch -M main
git remote add origin <YOUR_REPOSITORY_URL>
git push -u origin main
```
