USE online_store_db;

INSERT INTO categories(category_name, description) VALUES
('Laptop','Máy tính xách tay'),('Điện thoại','Smartphone'),
('Phụ kiện','Phụ kiện công nghệ'),('Màn hình','Màn hình máy tính'),
('Bàn phím','Bàn phím cơ và văn phòng'),('Chuột','Chuột máy tính'),
('Tai nghe','Tai nghe có dây/không dây'),('Lưu trữ','SSD, USB, thẻ nhớ'),
('Thiết bị mạng','Router và thiết bị mạng'),('Camera','Camera và webcam');

INSERT INTO products(category_id, product_name, sku, price, stock_quantity) VALUES
(1,'Laptop Alpha 14','LAP-A14',18990000,25),
(1,'Laptop Pro 15','LAP-P15',25990000,18),
(2,'Phone X1','PH-X1',12990000,40),
(2,'Phone Lite','PH-LITE',7990000,55),
(3,'USB-C Hub 6 in 1','ACC-HUB6',890000,70),
(4,'Monitor 24 inch IPS','MON-24IPS',3290000,32),
(5,'Mechanical Keyboard K87','KEY-K87',1490000,45),
(6,'Wireless Mouse M5','MOU-M5',690000,80),
(7,'Bluetooth Headphone H2','AUD-H2',1790000,36),
(8,'SSD NVMe 1TB','SSD-1TB',2190000,60),
(9,'WiFi 6 Router R6','NET-R6',1590000,28),
(10,'Webcam Full HD C2','CAM-C2',1190000,33),
(3,'Laptop Stand S1','ACC-STAND1',550000,50),
(8,'USB 128GB','USB-128',390000,100),
(7,'Gaming Headset G7','AUD-G7',1390000,42);

INSERT INTO customers(full_name,email,phone) VALUES
('Nguyễn An','an@example.com','0901000001'),
('Trần Bình','binh@example.com','0901000002'),
('Lê Chi','chi@example.com','0901000003'),
('Phạm Dũng','dung@example.com','0901000004'),
('Hoàng Giang','giang@example.com','0901000005'),
('Vũ Hà','ha@example.com','0901000006'),
('Đỗ Khánh','khanh@example.com','0901000007'),
('Bùi Lan','lan@example.com','0901000008'),
('Đặng Minh','minh@example.com','0901000009'),
('Ngô Nam','nam@example.com','0901000010'),
('Phan Oanh','oanh@example.com','0901000011'),
('Mai Phúc','phuc@example.com','0901000012');

INSERT INTO addresses(customer_id,address_line,city,district,postal_code,is_default) VALUES
(1,'12 Nguyễn Trãi','Hà Nội','Thanh Xuân','100000',1),
(2,'25 Cầu Giấy','Hà Nội','Cầu Giấy','100000',1),
(3,'80 Lê Lợi','TP.HCM','Quận 1','700000',1),
(4,'11 Võ Văn Tần','TP.HCM','Quận 3','700000',1),
(5,'19 Trần Phú','Đà Nẵng','Hải Châu','550000',1),
(6,'21 Lạch Tray','Hải Phòng','Ngô Quyền','180000',1),
(7,'15 Hùng Vương','Huế','Phú Nhuận','530000',1),
(8,'30 Nguyễn Huệ','TP.HCM','Quận 1','700000',1),
(9,'44 Kim Mã','Hà Nội','Ba Đình','100000',1),
(10,'50 Hai Bà Trưng','Hà Nội','Hoàn Kiếm','100000',1),
(11,'72 Điện Biên Phủ','Đà Nẵng','Thanh Khê','550000',1),
(12,'16 Pasteur','TP.HCM','Quận 3','700000',1);

-- Create orders first with total 0; trigger will calculate totals from items
INSERT INTO orders(customer_id,shipping_address_id,order_date,status) VALUES
(1,1,'2026-09-01 09:10:00','COMPLETED'),
(2,2,'2026-09-02 10:20:00','COMPLETED'),
(3,3,'2026-09-03 14:00:00','SHIPPING'),
(4,4,'2026-09-04 15:30:00','CONFIRMED'),
(5,5,'2026-09-05 08:45:00','COMPLETED'),
(1,1,'2026-09-06 19:10:00','COMPLETED'),
(6,6,'2026-09-07 11:00:00','PENDING'),
(7,7,'2026-09-08 12:40:00','COMPLETED'),
(8,8,'2026-09-09 16:15:00','CANCELLED'),
(9,9,'2026-09-10 17:25:00','COMPLETED'),
(10,10,'2026-09-11 09:05:00','SHIPPING'),
(2,2,'2026-09-12 13:35:00','COMPLETED'),
(3,3,'2026-09-13 20:10:00','CONFIRMED'),
(11,11,'2026-09-14 10:00:00','COMPLETED'),
(1,1,'2026-09-15 18:20:00','COMPLETED');

INSERT INTO order_items(order_id,product_id,quantity,unit_price) VALUES
(1,1,1,18990000),(1,8,1,690000),
(2,3,1,12990000),(2,5,1,890000),
(3,6,2,3290000),(3,7,1,1490000),
(4,10,1,2190000),(4,14,2,390000),
(5,2,1,25990000),(5,13,1,550000),
(6,9,1,1790000),(6,8,2,690000),
(7,11,1,1590000),(7,12,1,1190000),
(8,4,1,7990000),(8,15,1,1390000),
(9,5,2,890000),
(10,10,2,2190000),(10,14,1,390000),
(11,6,1,3290000),(11,12,1,1190000),
(12,7,1,1490000),(12,8,1,690000),(12,14,2,390000),
(13,3,1,12990000),
(14,11,1,1590000),(14,5,1,890000),
(15,1,1,18990000),(15,10,1,2190000);

INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 1,'CARD',total_amount,'PAID','2026-09-01 09:15:00','TX001' FROM orders WHERE order_id=1;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 2,'BANK_TRANSFER',total_amount,'PAID','2026-09-02 10:25:00','TX002' FROM orders WHERE order_id=2;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 3,'E_WALLET',total_amount,'PAID','2026-09-03 14:05:00','TX003' FROM orders WHERE order_id=3;
INSERT INTO payments(order_id,payment_method,amount,payment_status,transaction_code)
SELECT 4,'CASH',total_amount,'PENDING','TX004' FROM orders WHERE order_id=4;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 5,'CARD',total_amount,'PAID','2026-09-05 08:50:00','TX005' FROM orders WHERE order_id=5;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 6,'E_WALLET',total_amount,'PAID','2026-09-06 19:15:00','TX006' FROM orders WHERE order_id=6;
INSERT INTO payments(order_id,payment_method,amount,payment_status,transaction_code)
SELECT 7,'CASH',total_amount,'PENDING','TX007' FROM orders WHERE order_id=7;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 8,'BANK_TRANSFER',total_amount,'PAID','2026-09-08 12:45:00','TX008' FROM orders WHERE order_id=8;
INSERT INTO payments(order_id,payment_method,amount,payment_status,transaction_code)
SELECT 9,'CARD',total_amount,'REFUNDED','TX009' FROM orders WHERE order_id=9;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 10,'CARD',total_amount,'PAID','2026-09-10 17:30:00','TX010' FROM orders WHERE order_id=10;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 11,'E_WALLET',total_amount,'PAID','2026-09-11 09:10:00','TX011' FROM orders WHERE order_id=11;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 12,'CARD',total_amount,'PAID','2026-09-12 13:40:00','TX012' FROM orders WHERE order_id=12;
INSERT INTO payments(order_id,payment_method,amount,payment_status,transaction_code)
SELECT 13,'CASH',total_amount,'PENDING','TX013' FROM orders WHERE order_id=13;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 14,'BANK_TRANSFER',total_amount,'PAID','2026-09-14 10:05:00','TX014' FROM orders WHERE order_id=14;
INSERT INTO payments(order_id,payment_method,amount,payment_status,paid_at,transaction_code)
SELECT 15,'CARD',total_amount,'PAID','2026-09-15 18:25:00','TX015' FROM orders WHERE order_id=15;

INSERT INTO reviews(customer_id,product_id,rating,comment) VALUES
(1,1,5,'Máy chạy tốt, giao nhanh'),
(2,3,4,'Điện thoại tốt'),
(3,6,5,'Màn hình đẹp'),
(4,10,4,'SSD nhanh'),
(5,2,5,'Laptop mạnh'),
(6,11,4,'Router ổn định'),
(7,4,4,'Phù hợp giá tiền'),
(8,15,5,'Âm thanh tốt'),
(9,10,5,'Tốc độ đọc ghi tốt'),
(10,6,4,'Màu sắc đẹp'),
(11,5,4,'Hub tiện dụng'),
(12,7,5,'Bàn phím gõ tốt');
