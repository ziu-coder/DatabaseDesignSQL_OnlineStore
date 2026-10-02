-- =========================================================
-- DATABASE DESIGN & SQL - ONLINE SALES MANAGEMENT SYSTEM
-- MySQL 8.0+
-- =========================================================
DROP DATABASE IF EXISTS online_store_db;
CREATE DATABASE online_store_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE online_store_db;

-- 1. Categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Products
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    price DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category
      FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 3. Customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Addresses
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    postal_code VARCHAR(20),
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_addresses_customer
      FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
      ON DELETE CASCADE
);

-- 5. Orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING','CONFIRMED','SHIPPING','COMPLETED','CANCELLED')
      NOT NULL DEFAULT 'PENDING',
    total_amount DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer
      FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_address
      FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id)
);

-- 6. Order details: resolves N-N between Orders and Products
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id),
    CONSTRAINT fk_items_order
      FOREIGN KEY (order_id) REFERENCES orders(order_id)
      ON DELETE CASCADE,
    CONSTRAINT fk_items_product
      FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 7. Payments
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('CASH','CARD','BANK_TRANSFER','E_WALLET') NOT NULL,
    amount DECIMAL(14,2) NOT NULL CHECK (amount > 0),
    payment_status ENUM('PENDING','PAID','FAILED','REFUNDED')
      NOT NULL DEFAULT 'PENDING',
    paid_at DATETIME NULL,
    transaction_code VARCHAR(100) UNIQUE,
    CONSTRAINT fk_payments_order
      FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 8. Product reviews
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_review_customer_product UNIQUE(customer_id, product_id),
    CONSTRAINT fk_reviews_customer
      FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
      ON DELETE CASCADE,
    CONSTRAINT fk_reviews_product
      FOREIGN KEY (product_id) REFERENCES products(product_id)
      ON DELETE CASCADE
);

-- Indexes for frequently queried columns
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_orders_status_date ON orders(status, order_date);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- View: order summary
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.full_name AS customer_name,
    o.status,
    COUNT(oi.order_item_id) AS line_count,
    SUM(oi.quantity) AS total_items,
    SUM(oi.quantity * oi.unit_price) AS calculated_total,
    o.total_amount
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_date, c.customer_id, c.full_name, o.status, o.total_amount;

DELIMITER $$

-- Procedure: customer order history
CREATE PROCEDURE sp_customer_order_history(IN p_customer_id INT)
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.status,
        o.total_amount,
        COALESCE(p.payment_status, 'PENDING') AS payment_status
    FROM orders o
    LEFT JOIN payments p ON p.order_id = o.order_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END$$

-- Trigger: after inserting an order item, update order total and reduce stock
CREATE TRIGGER trg_order_item_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
       SET total_amount = total_amount + (NEW.quantity * NEW.unit_price)
     WHERE order_id = NEW.order_id;

    UPDATE products
       SET stock_quantity = stock_quantity - NEW.quantity
     WHERE product_id = NEW.product_id;
END$$

-- Prevent selling more stock than available
CREATE TRIGGER trg_order_item_before_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    SELECT stock_quantity INTO current_stock
      FROM products
     WHERE product_id = NEW.product_id
     FOR UPDATE;

    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient product stock';
    END IF;
END$$

DELIMITER ;
