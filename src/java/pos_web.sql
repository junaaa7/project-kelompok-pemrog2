-- ============================================
-- DATABASE: pos_web (Tanpa Password Hash)
-- ============================================
CREATE DATABASE IF NOT EXISTS pos_web;
USE pos_web;

-- ============================================
-- TABLE: users (password plain text)
-- ============================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,  -- PLAIN TEXT, bukan hash
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role ENUM('admin', 'cashier') DEFAULT 'cashier',
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: categories
-- ============================================
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: products
-- ============================================
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category_id INT,
    image_url VARCHAR(255),
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: customers
-- ============================================
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: transactions
-- ============================================
CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_code VARCHAR(50) UNIQUE NOT NULL,
    transaction_date DATETIME NOT NULL,
    customer_id INT,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    cash DECIMAL(10,2) NOT NULL,
    change_amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'debit', 'credit', 'transfer') DEFAULT 'cash',
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'completed',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: transaction_details
-- ============================================
CREATE TABLE transaction_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Insert users dengan PASSWORD PLAIN TEXT
INSERT INTO users (username, password, full_name, email, role) VALUES
('admin', 'admin123', 'Administrator', 'admin@pos.com', 'admin'),
('kasir1', 'kasir123', 'Kasir Utama', 'kasir1@pos.com', 'cashier'),
('kasir2', 'kasir123', 'Kasir Backup', 'kasir2@pos.com', 'cashier'),
('manager', 'manager123', 'Manager Toko', 'manager@pos.com', 'admin'),
('supervisor', 'super123', 'Supervisor', 'supervisor@pos.com', 'admin');

-- Insert categories
INSERT INTO categories (code, name, description) VALUES
('CAT001', 'Makanan', 'Produk makanan dan masakan'),
('CAT002', 'Minuman', 'Minuman ringan dan kemasan'),
('CAT003', 'Snack', 'Makanan ringan'),
('CAT004', 'ATK', 'Alat Tulis Kantor'),
('CAT005', 'Elektronik', 'Produk elektronik kecil'),
('CAT006', 'Peralatan', 'Peralatan rumah tangga'),
('CAT007', 'Kebutuhan', 'Kebutuhan sehari-hari');

-- Insert products
INSERT INTO products (code, name, description, price, stock, category_id) VALUES
-- Makanan
('PRD001', 'Nasi Goreng Spesial', 'Nasi goreng dengan telur dan ayam', 25000.00, 50, 1),
('PRD002', 'Mie Goreng Jawa', 'Mie goreng khas Jawa', 20000.00, 45, 1),
('PRD003', 'Ayam Goreng Krispi', 'Ayam goreng tepung renyah', 18000.00, 30, 1),
('PRD004', 'Sate Ayam 10 tusuk', 'Sate ayam dengan bumbu kacang', 30000.00, 40, 1),
('PRD005', 'Bakso Spesial', 'Bakso urat dengan mie', 20000.00, 35, 1),

-- Minuman
('PRD006', 'Es Teh Manis', 'Es teh dengan gula', 5000.00, 100, 2),
('PRD007', 'Kopi Hitam', 'Kopi tubruk panas', 8000.00, 80, 2),
('PRD008', 'Jus Jeruk', 'Jus jeruk segar', 12000.00, 40, 2),
('PRD009', 'Es Campur', 'Es campur spesial', 15000.00, 25, 2),
('PRD010', 'Teh Botol', 'Teh botol kemasan', 8000.00, 100, 2),

-- Snack
('PRD011', 'Keripik Kentang', 'Keripik kentang original', 15000.00, 60, 3),
('PRD012', 'Coklat Batang', 'Coklat batang premium', 10000.00, 75, 3),
('PRD013', 'Permen Aneka Rasa', 'Permen campur rasa', 2000.00, 200, 3),
('PRD014', 'Biskuit Coklat', 'Biskuit isi coklat', 12000.00, 50, 3),
('PRD015', 'Wafer Coklat', 'Wafer lapis coklat', 8000.00, 65, 3),

-- ATK
('PRD016', 'Buku Tulis 58 Lembar', 'Buku tulis garis', 5000.00, 120, 4),
('PRD017', 'Pulpen Standard', 'Pulpen biru/merah/hitam', 3000.00, 200, 4),
('PRD018', 'Pensil 2B', 'Pensil ujian 2B', 2500.00, 150, 4),
('PRD019', 'Penghapus', 'Penghapus putih', 2000.00, 180, 4),
('PRD020', 'Penggaris 30cm', 'Penggaris plastik', 5000.00, 90, 4),

-- Elektronik
('PRD021', 'Baterai AA Alkaline', 'Baterai alkaline 1.5V', 10000.00, 90, 5),
('PRD022', 'Charger HP Universal', 'Charger universal semua tipe', 35000.00, 25, 5),
('PRD023', 'Kabel USB Type C', 'Kabel data USB-C 1m', 25000.00, 50, 5),
('PRD024', 'Power Bank 10000mAh', 'Power bank portable', 150000.00, 15, 5),
('PRD025', 'Earphone Basic', 'Earphone 3.5mm', 50000.00, 30, 5);

-- Insert customers
INSERT INTO customers (code, name, phone, email, address) VALUES
('CUST001', 'Pelanggan Umum', '081234567890', 'umum@email.com', 'Jl. Umum No. 1'),
('CUST002', 'Budi Santoso', '081298765432', 'budi@email.com', 'Jl. Merdeka No. 10'),
('CUST003', 'Siti Rahayu', '081377788899', 'siti@email.com', 'Jl. Sudirman No. 25'),
('CUST004', 'Ahmad Fauzi', '081499988877', 'ahmad@email.com', 'Jl. Diponegoro No. 15'),
('CUST005', 'Dewi Anggraini', '081511122233', 'dewi@email.com', 'Jl. Gatot Subroto No. 8'),
('CUST006', 'PT. Maju Jaya', '0211234567', 'info@majujaya.com', 'Jl. Industri No. 5'),
('CUST007', 'CV. Sejahtera', '0217654321', 'order@sejahtera.com', 'Jl. Raya Bogor KM 5'),
('CUST008', 'Toko Sumber Rejeki', '0219876543', 'sumber@rejeki.com', 'Jl. Pasar Baru No. 12');

-- Insert sample transactions
INSERT INTO transactions (transaction_code, transaction_date, customer_id, user_id, total_amount, cash, change_amount, payment_method) VALUES
('TRX-20241202-0001', '2024-12-02 10:30:00', 1, 2, 75000.00, 100000.00, 25000.00, 'cash'),
('TRX-20241202-0002', '2024-12-02 14:45:00', 2, 2, 120000.00, 150000.00, 30000.00, 'cash'),
('TRX-20241202-0003', '2024-12-02 09:15:00', 3, 3, 45000.00, 50000.00, 5000.00, 'debit'),
('TRX-20241201-0001', '2024-12-01 11:20:00', 4, 2, 85000.00, 100000.00, 15000.00, 'cash'),
('TRX-20241201-0002', '2024-12-01 16:30:00', 5, 3, 65000.00, 100000.00, 35000.00, 'debit'),
('TRX-20241130-0001', '2024-11-30 13:45:00', 6, 2, 220000.00, 250000.00, 30000.00, 'cash'),
('TRX-20241130-0002', '2024-11-30 10:10:00', 7, 3, 180000.00, 200000.00, 20000.00, 'transfer'),
('TRX-20241129-0001', '2024-11-29 15:25:00', 8, 2, 95000.00, 100000.00, 5000.00, 'cash');

-- Insert transaction details
INSERT INTO transaction_details (transaction_id, product_id, quantity, price, subtotal) VALUES
-- TRX 1
(1, 1, 2, 25000.00, 50000.00),
(1, 6, 5, 5000.00, 25000.00),

-- TRX 2
(2, 2, 3, 20000.00, 60000.00),
(2, 3, 2, 18000.00, 36000.00),
(2, 8, 2, 12000.00, 24000.00),

-- TRX 3
(3, 11, 2, 15000.00, 30000.00),
(3, 12, 1, 10000.00, 10000.00),
(3, 17, 2, 3000.00, 6000.00),

-- TRX 4
(4, 1, 1, 25000.00, 25000.00),
(4, 4, 2, 30000.00, 60000.00),

-- TRX 5
(5, 6, 3, 5000.00, 15000.00),
(5, 5, 2, 20000.00, 40000.00),
(5, 9, 1, 15000.00, 15000.00),

-- TRX 6
(6, 21, 5, 10000.00, 50000.00),
(6, 22, 2, 35000.00, 70000.00),
(6, 23, 3, 25000.00, 75000.00),
(6, 25, 1, 50000.00, 50000.00),

-- TRX 7
(7, 16, 10, 5000.00, 50000.00),
(7, 17, 15, 3000.00, 45000.00),
(7, 18, 20, 2500.00, 50000.00),
(7, 19, 10, 2000.00, 20000.00),
(7, 20, 5, 5000.00, 25000.00),

-- TRX 8
(8, 13, 10, 2000.00, 20000.00),
(8, 14, 5, 12000.00, 60000.00),
(8, 15, 2, 8000.00, 16000.00);

-- ============================================
-- CREATE INDEXES
-- ============================================
CREATE INDEX idx_products_code ON products(code);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_transactions_code ON transactions(transaction_code);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_users_username ON users(username);

-- ============================================
-- CREATE VIEWS FOR REPORTING
-- ============================================

-- View: product_stock_low (stok kurang dari 20)
CREATE VIEW product_stock_low AS
SELECT 
    p.code AS kode,
    p.name AS nama_produk,
    c.name AS kategori,
    p.price AS harga,
    p.stock AS stok,
    CASE 
        WHEN p.stock < 10 THEN 'SANGAT RENDAH'
        WHEN p.stock < 20 THEN 'RENDAH'
        ELSE 'CUKUP'
    END AS status_stok
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.stock < 20 AND p.is_active = 1
ORDER BY p.stock ASC;

-- View: daily_sales_summary
CREATE VIEW daily_sales_summary AS
SELECT 
    DATE(t.transaction_date) AS tanggal,
    COUNT(t.id) AS jumlah_transaksi,
    SUM(t.total_amount) AS total_penjualan,
    AVG(t.total_amount) AS rata_transaksi,
    MAX(t.total_amount) AS transaksi_terbesar,
    MIN(t.total_amount) AS transaksi_terkecil
FROM transactions t
WHERE t.status = 'completed'
GROUP BY DATE(t.transaction_date)
ORDER BY tanggal DESC;

-- View: top_selling_products
CREATE VIEW top_selling_products AS
SELECT 
    p.code,
    p.name,
    c.name AS kategori,
    SUM(td.quantity) AS total_terjual,
    SUM(td.subtotal) AS total_pendapatan,
    ROUND(AVG(td.price), 2) AS harga_rata
FROM transaction_details td
JOIN products p ON td.product_id = p.id
JOIN categories c ON p.category_id = c.id
JOIN transactions t ON td.transaction_id = t.id
WHERE t.status = 'completed'
GROUP BY p.id
ORDER BY total_terjual DESC
LIMIT 10;

-- View: cashier_performance
CREATE VIEW cashier_performance AS
SELECT 
    u.username,
    u.full_name,
    COUNT(t.id) AS total_transaksi,
    SUM(t.total_amount) AS total_penjualan,
    ROUND(AVG(t.total_amount), 2) AS rata_transaksi,
    MIN(t.transaction_date) AS pertama_kali,
    MAX(t.transaction_date) AS terakhir_kali
FROM transactions t
JOIN users u ON t.user_id = u.id
WHERE t.status = 'completed'
GROUP BY u.id
ORDER BY total_penjualan DESC;

-- ============================================
-- SIMPLE STORED PROCEDURES
-- ============================================

-- Procedure: Cek stok produk
DELIMITER $$
CREATE PROCEDURE check_product_stock(IN product_code VARCHAR(20))
BEGIN
    SELECT 
        code,
        name,
        stock,
        price,
        CASE 
            WHEN stock = 0 THEN 'HABIS'
            WHEN stock < 10 THEN 'SEDIKIT'
            WHEN stock < 50 THEN 'CUKUP'
            ELSE 'BANYAK'
        END AS status_stok
    FROM products 
    WHERE code = product_code;
END$$
DELIMITER ;

-- Procedure: Ringkasan harian
DELIMITER $$
CREATE PROCEDURE daily_summary(IN tanggal DATE)
BEGIN
    SELECT 
        COUNT(*) AS jumlah_transaksi,
        SUM(total_amount) AS total_penjualan,
        SUM(cash) AS total_tunai,
        SUM(change_amount) AS total_kembalian,
        AVG(total_amount) AS rata_transaksi
    FROM transactions
    WHERE DATE(transaction_date) = tanggal
    AND status = 'completed';
END$$
DELIMITER ;

-- ============================================
-- SAMPLE QUERIES FOR TESTING
-- ============================================

-- Query 1: Cek semua user dengan password
SELECT id, username, password, full_name, role FROM users ORDER BY role, username;

-- Query 2: Cek produk dengan stok
SELECT code, name, price, stock, 
       (price * stock) AS nilai_stok 
FROM products 
WHERE is_active = 1 
ORDER BY name;

-- Query 3: Transaksi hari ini
SELECT 
    t.transaction_code,
    DATE_FORMAT(t.transaction_date, '%d/%m/%Y %H:%i') AS waktu,
    c.name AS customer,
    u.full_name AS kasir,
    t.total_amount AS total,
    t.payment_method AS pembayaran
FROM transactions t
LEFT JOIN customers c ON t.customer_id = c.id
JOIN users u ON t.user_id = u.id
WHERE DATE(t.transaction_date) = CURDATE()
ORDER BY t.transaction_date DESC;

-- Query 4: 10 produk terlaris
SELECT 
    p.code,
    p.name,
    SUM(td.quantity) AS jumlah_terjual,
    SUM(td.subtotal) AS total_penjualan
FROM transaction_details td
JOIN products p ON td.product_id = p.id
JOIN transactions t ON td.transaction_id = t.id
WHERE t.status = 'completed'
GROUP BY p.id
ORDER BY jumlah_terjual DESC
LIMIT 10;

-- ============================================
-- TEST DATA READY MESSAGE
-- ============================================
SELECT '========================================' AS '';
SELECT 'DATABASE POS WEB READY!' AS '';
SELECT '========================================' AS '';
SELECT 'USERS untuk login:' AS '';
SELECT '----------------------------------------' AS '';
SELECT '1. Username: admin      Password: admin123   Role: Admin' AS '';
SELECT '2. Username: kasir1     Password: kasir123   Role: Cashier' AS '';
SELECT '3. Username: kasir2     Password: kasir123   Role: Cashier' AS '';
SELECT '4. Username: manager    Password: manager123 Role: Admin' AS '';
SELECT '5. Username: supervisor Password: super123   Role: Admin' AS '';
SELECT '----------------------------------------' AS '';
SELECT 'Total Users    : ' AS '', COUNT(*) FROM users;
SELECT 'Total Products : ' AS '', COUNT(*) FROM products;
SELECT 'Total Transaksi: ' AS '', COUNT(*) FROM transactions;
SELECT '========================================' AS '';