USE online_store_db;

-- =========================================================
-- TRANSACTION DEMO
-- Thực tế nên khóa tồn kho trong transaction khi tạo đơn.
-- =========================================================
START TRANSACTION;

INSERT INTO orders(customer_id, shipping_address_id, status)
VALUES (12, 12, 'PENDING');

SET @new_order_id = LAST_INSERT_ID();

-- Trigger kiểm tra tồn kho, trừ kho và cập nhật total_amount.
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
SELECT @new_order_id, product_id, 1, price
FROM products
WHERE product_id = 12;

COMMIT;

SELECT * FROM vw_order_summary WHERE order_id = @new_order_id;

-- =========================================================
-- OPTIONAL ROLE / PERMISSION DEMO
-- Chạy bằng tài khoản có quyền CREATE USER/ROLE.
-- =========================================================
-- CREATE ROLE 'report_reader';
-- GRANT SELECT ON online_store_db.* TO 'report_reader';
-- CREATE USER 'report_user'@'localhost' IDENTIFIED BY 'ChangeMe_StrongPassword!';
-- GRANT 'report_reader' TO 'report_user'@'localhost';
-- SET DEFAULT ROLE 'report_reader' TO 'report_user'@'localhost';

-- =========================================================
-- BACKUP / RESTORE (chạy ở terminal, KHÔNG chạy trong Workbench SQL editor)
-- =========================================================
-- Backup:
-- mysqldump -u root -p online_store_db > online_store_db_backup.sql
--
-- Restore:
-- mysql -u root -p online_store_db < online_store_db_backup.sql
