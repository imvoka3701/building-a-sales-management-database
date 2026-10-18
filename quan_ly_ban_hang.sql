-- =====================================================================
-- BÀI THỰC HÀNH: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ BÁN HÀNG
-- FILE: quan_ly_ban_hang.sql
-- HỆ QUẢN TRỊ CSDL: MySQL / MariaDB
-- =====================================================================

DROP DATABASE IF EXISTS QuanLyBanHang;
CREATE DATABASE QuanLyBanHang CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE QuanLyBanHang;

-- ---------------------------------------------------------------------
-- 1. BẢNG CUSTOMER (Khách hàng)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Customer (
    cID INT AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(25) NOT NULL,
    cAge TINYINT CHECK (cAge > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. BẢNG ORDER (Hóa đơn mua hàng)
-- Chú ý: Từ Order là từ khóa nên cần bọc trong dấu backtick `Order`
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Order` (
    oID INT AUTO_INCREMENT PRIMARY KEY,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice INT NULL,
    CONSTRAINT fk_order_customer FOREIGN KEY (cID) 
        REFERENCES Customer(cID) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. BẢNG PRODUCT (Sản phẩm)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Product (
    pID INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(25) NOT NULL,
    pPrice INT NOT NULL CHECK (pPrice >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. BẢNG ORDERDETAIL (Chi tiết hóa đơn - Bảng trung gian N-N)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS OrderDetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL CHECK (odQTY > 0),
    PRIMARY KEY (oID, pID),
    CONSTRAINT fk_od_order FOREIGN KEY (oID) 
        REFERENCES `Order`(oID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_od_product FOREIGN KEY (pID) 
        REFERENCES Product(pID) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =====================================================================
-- PHẦN DỮ LIỆU THỬ NGHIỆM
-- =====================================================================

-- 1. Thêm khách hàng
INSERT INTO Customer (cID, cName, cAge) VALUES
(1, 'Minh Quan', 10),
(2, 'Ngoc Oanh', 20),
(3, 'Hong Ha', 50);

-- 2. Thêm hóa đơn
INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
(1, 1, '2006-03-21', NULL),
(2, 2, '2006-03-23', NULL),
(3, 1, '2006-03-16', NULL);

-- 3. Thêm sản phẩm
INSERT INTO Product (pID, pName, pPrice) VALUES
(1, 'May Giat', 3),
(2, 'Tu Lanh', 5),
(3, 'Dieu Hoa', 7),
(4, 'Quat', 1),
(5, 'Bep Dien', 2);

-- 4. Thêm chi tiết hóa đơn
INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3);


-- =====================================================================
-- CÁC CÂU LỆNH TRUY VẤN MẪU
-- =====================================================================

-- 1. Hiển thị danh sách các hóa đơn gồm mã, ngày mua, giá tiền
SELECT oID, oDate, oTotalPrice FROM `Order`;

-- 2. Hiển thị danh sách khách hàng đã mua và danh sách sản phẩm được mua
SELECT 
    c.cName AS 'Tên khách hàng',
    p.pName AS 'Tên sản phẩm',
    od.odQTY AS 'Số lượng mua'
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
ORDER BY c.cName;

-- 3. Hiển thị những khách hàng KHÔNG mua bất kỳ sản phẩm nào
SELECT 
    c.cID AS 'Mã KH',
    c.cName AS 'Tên khách hàng',
    c.cAge AS 'Tuổi'
FROM Customer c
LEFT JOIN `Order` o ON c.cID = o.cID
WHERE o.oID IS NULL;

-- 4. Tính tổng tiền cho từng hóa đơn (Giá = odQTY * pPrice)
SELECT 
    o.oID AS 'Số Hóa Đơn',
    o.oDate AS 'Ngày Mua',
    c.cName AS 'Khách hàng',
    SUM(od.odQTY * p.pPrice) AS 'Tổng Giá Trị Hóa Đơn'
FROM `Order` o
JOIN Customer c ON o.cID = c.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
GROUP BY o.oID, o.oDate, c.cName;
