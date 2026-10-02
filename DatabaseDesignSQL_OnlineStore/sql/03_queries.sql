USE online_store_db;

-- Q1. SELECT + WHERE + ORDER BY + LIMIT
-- Mục đích: Lấy 5 sản phẩm đang bán có giá cao nhất.
SELECT product_id, product_name, price, stock_quantity
FROM products
WHERE status = 'ACTIVE'
ORDER BY price DESC
LIMIT 5;

-- Q2. INNER JOIN 3 bảng
-- Mục đích: Xem chi tiết sản phẩm trong từng đơn hàng.
SELECT o.order_id, c.full_name, p.product_name, oi.quantity, oi.unit_price
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.product_name;

-- Q3. LEFT JOIN
-- Mục đích: Tìm khách hàng và số đơn hàng, kể cả khách chưa mua.
SELECT c.customer_id, c.full_name, COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY order_count DESC, c.full_name;

-- Q4. GROUP BY + SUM/AVG/MIN/MAX/COUNT
-- Mục đích: Thống kê giá sản phẩm theo danh mục.
SELECT cat.category_name,
       COUNT(p.product_id) AS product_count,
       MIN(p.price) AS min_price,
       MAX(p.price) AS max_price,
       AVG(p.price) AS avg_price,
       SUM(p.stock_quantity) AS total_stock
FROM categories cat
LEFT JOIN products p ON p.category_id = cat.category_id
GROUP BY cat.category_id, cat.category_name
ORDER BY avg_price DESC;

-- Q5. Subquery trong WHERE
-- Mục đích: Tìm sản phẩm có giá cao hơn giá trung bình toàn bộ sản phẩm.
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- Q6. Window function - DENSE_RANK
-- Mục đích: Xếp hạng sản phẩm theo doanh thu bán ra.
SELECT product_id, product_name, revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM (
    SELECT p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status <> 'CANCELLED'
    GROUP BY p.product_id, p.product_name
) x
ORDER BY revenue_rank, product_name;

-- Q7. Nested query
-- Mục đích: Tìm khách hàng có tổng chi tiêu cao hơn mức trung bình của các khách đã mua.
SELECT customer_id, full_name, total_spent
FROM (
    SELECT c.customer_id, c.full_name,
           SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'COMPLETED'
    GROUP BY c.customer_id, c.full_name
) customer_totals
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM orders
        WHERE status = 'COMPLETED'
        GROUP BY customer_id
    ) avg_source
)
ORDER BY total_spent DESC;

-- Q8. CASE WHEN
-- Mục đích: Phân nhóm tồn kho.
SELECT product_name, stock_quantity,
       CASE
           WHEN stock_quantity = 0 THEN 'Hết hàng'
           WHEN stock_quantity < 20 THEN 'Sắp hết'
           WHEN stock_quantity < 50 THEN 'Trung bình'
           ELSE 'Dồi dào'
       END AS stock_level
FROM products
ORDER BY stock_quantity;

-- Q9. Dữ liệu không tồn tại
-- Mục đích: Tìm khách hàng chưa từng đặt hàng.
SELECT c.customer_id, c.full_name, c.email
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Q10. Pagination
-- Mục đích: Lấy trang 2, mỗi trang 5 sản phẩm.
SELECT product_id, product_name, price
FROM products
ORDER BY product_id
LIMIT 5 OFFSET 5;

-- Q11. CTE
-- Mục đích: Tính doanh thu theo khách hàng bằng CTE.
WITH customer_revenue AS (
    SELECT c.customer_id, c.full_name,
           SUM(o.total_amount) AS revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'COMPLETED'
    GROUP BY c.customer_id, c.full_name
)
SELECT *
FROM customer_revenue
ORDER BY revenue DESC;

-- Q12. View
-- Mục đích: Sử dụng view để xem tóm tắt đơn hàng.
SELECT *
FROM vw_order_summary
ORDER BY order_date DESC;

-- Q13. Stored procedure
-- Mục đích: Xem lịch sử đơn hàng của khách hàng ID 1.
CALL sp_customer_order_history(1);

-- Q14. Tìm dữ liệu trùng lặp logic
-- Mục đích: Kiểm tra email trùng (UNIQUE khiến kết quả hợp lệ phải rỗng).
SELECT email, COUNT(*) AS duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Q15. ROW_NUMBER theo từng danh mục
-- Mục đích: Xếp thứ tự sản phẩm theo giá trong từng danh mục.
SELECT category_name, product_name, price,
       ROW_NUMBER() OVER (
           PARTITION BY category_name ORDER BY price DESC
       ) AS price_position
FROM (
    SELECT c.category_name, p.product_name, p.price
    FROM categories c
    JOIN products p ON p.category_id = c.category_id
) s
ORDER BY category_name, price_position;
