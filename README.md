Databasenya Uhuyy

DROP DATABASE IF EXISTS nugas_db;
CREATE DATABASE nugas_db;
USE nugas_db;

CREATE TABLE `barang` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nama` VARCHAR(100) NOT NULL,
  `deskripsi` TEXT,
  `harga` INT NOT NULL,
  `stok` INT DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `gambar` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `invoice` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `session_id` VARCHAR(100) NOT NULL,
  `nama_penerima` VARCHAR(100),
  `alamat` TEXT,
  `metode` VARCHAR(50),
  `total` INT,
  `tanggal` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('menunggu', 'dibayar', 'dikirim', 'selesai', 'batal') DEFAULT 'menunggu'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `invoice_detail` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `invoice_id` INT,
  `barang_id` INT,
  `nama_barang` VARCHAR(100),
  `harga` INT,
  `qty` INT,
  `subtotal` INT,
  CONSTRAINT `fk_detail_to_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoice`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_detail_to_barang` FOREIGN KEY (`barang_id`) REFERENCES `barang`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nama` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `role` ENUM('admin', 'user') DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `barang` (`nama`, `deskripsi`, `harga`, `stok`, `gambar`) VALUES
('Keyboard Mekanikal RGB', 'Keyboard gaming dengan switch biru yang clicky dan lampu RGB yang bisa diatur.', 750000, 15, 'keyboard.jpg'),
('Mouse Gaming Pro', 'Mouse ringan dengan sensor presisi tinggi, cocok untuk game FPS.', 450000, 25, 'mouse.jpg'),
('Headset Gaming 7.1 Surround', 'Headset dengan suara surround 7.1 virtual untuk pengalaman audio yang imersif.', 600000, 20, 'headset.jpg'),
('Mousepad XL Gaming', 'Mousepad ukuran besar dengan permukaan kain yang halus untuk pergerakan mouse yang lancar.', 150000, 50, 'mousepad.jpg'),
('Webcam Full HD 1080p', 'Webcam dengan resolusi Full HD untuk streaming atau video call yang jernih.', 550000, 18, NULL);

INSERT INTO `users` (`nama`, `email`, `password`, `role`) VALUES
('Administrator', 'admin@toko.com', 'admin', 'admin');
"# awdawrtttttt" 
