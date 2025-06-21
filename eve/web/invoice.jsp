<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*, java.text.NumberFormat, java.text.SimpleDateFormat" %>
<%
    String sessionId = session.getId();
    String namaPenerima = request.getParameter("nama_penerima");
    String alamat = request.getParameter("alamat");
    String metode = request.getParameter("metode");
    if ("Transfer Bank".equals(metode)) {
        metode += " - " + request.getParameter("nama_bank");
    }
    int total = Integer.parseInt(request.getParameter("total"));
    
    String[] barangIds = request.getParameterValues("barang_id");
    String[] barangNamas = request.getParameterValues("barang_nama");
    String[] barangHargas = request.getParameterValues("barang_harga");
    String[] barangQtys = request.getParameterValues("barang_qty");
    String[] barangSubtotals = request.getParameterValues("barang_subtotal");

    Connection conn = null;
    int invoiceId = -1;
    String nomorInvoiceBaru = ""; 

    if (barangIds == null || barangIds.length == 0) {
        response.sendRedirect("keranjang.jsp");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
        conn.setAutoCommit(false);

        // ======================================================================
        // PERUBAHAN DIMULAI DI SINI: BLOK PEMBUATAN NOMOR PESANAN BARU
        // ======================================================================
        
        // 1. Buat komponen tanggal (TahunBulanTanggal), contoh: 250611
        String tanggalPart = new SimpleDateFormat("yyMMdd").format(new java.util.Date());

        // 2. Buat komponen unik dari waktu dalam milidetik dan ubah ke format Heksadesimal
        String uniquePart = Long.toHexString(System.currentTimeMillis()).toUpperCase();
        
        // 3. Gabungkan menjadi Nomor Pesanan Final
        // Format: TGL + 6 Karakter terakhir dari kode unik. Contoh: 250611A9B1C3
        nomorInvoiceBaru = tanggalPart + uniquePart.substring(uniquePart.length() - 6);
        
        // ======================================================================
        // AKHIR DARI BLOK PERUBAHAN
        // ======================================================================

        if (nomorInvoiceBaru == null || nomorInvoiceBaru.isEmpty()) {
            throw new Exception("Gagal membuat nomor invoice unik. Proses dibatalkan.");
        }

        String sqlInvoice = "INSERT INTO invoice (nomor_invoice, session_id, nama_penerima, alamat, metode, total, status, tanggal) VALUES (?, ?, ?, ?, ?, ?, 'menunggu', NOW())";
        PreparedStatement psInvoice = conn.prepareStatement(sqlInvoice, Statement.RETURN_GENERATED_KEYS);
        psInvoice.setString(1, nomorInvoiceBaru);
        psInvoice.setString(2, sessionId);
        psInvoice.setString(3, namaPenerima);
        psInvoice.setString(4, alamat);
        psInvoice.setString(5, metode);
        psInvoice.setInt(6, total);
        psInvoice.executeUpdate();

        ResultSet generatedKeys = psInvoice.getGeneratedKeys();
        if (generatedKeys.next()) {
            invoiceId = generatedKeys.getInt(1);
        } else {
            throw new SQLException("Gagal membuat invoice, tidak ada ID internal yang didapatkan.");
        }
        psInvoice.close();

        String sqlDetail = "INSERT INTO invoice_detail (invoice_id, barang_id, nama_barang, harga, qty, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
        for (int i = 0; i < barangIds.length; i++) {
            psDetail.setInt(1, invoiceId);
            psDetail.setInt(2, Integer.parseInt(barangIds[i]));
            psDetail.setString(3, barangNamas[i]);
            psDetail.setInt(4, Integer.parseInt(barangHargas[i]));
            psDetail.setInt(5, Integer.parseInt(barangQtys[i]));
            psDetail.setInt(6, Integer.parseInt(barangSubtotals[i]));
            psDetail.addBatch();
        }
        psDetail.executeBatch();
        psDetail.close();
        
        conn.commit();

        if (request.getParameter("id") == null) {
             session.removeAttribute("cart");
        }

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.println("<div class='container mt-5'><div class='alert alert-danger'>Terjadi kesalahan saat memproses pesanan Anda. Error: " + e.getMessage() + "</div></div>");
        return;
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pesanan Berhasil - <%= nomorInvoiceBaru %></title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: #f4f7f6; padding-top: 40px; padding-bottom: 40px; }
        .invoice-container { max-width: 800px; margin: auto; background: #fff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
        .invoice-header { text-align: center; border-bottom: 2px solid #eee; padding-bottom: 20px; margin-bottom: 30px; }
        .invoice-title { font-weight: bold; color: #333; }
        .thank-you-msg { background-color: #d1e7dd; color: #0f5132; border-left: 5px solid #198754; }
    </style>
</head>
<body>

<div class="invoice-container">
    <div class="invoice-header">
        <h2 class="invoice-title">PESANAN DIBUAT</h2>
        <p class="text-muted mb-0">NO. PESANAN: <strong><%= nomorInvoiceBaru %></strong></p>
    </div>

    <div class="alert thank-you-msg">
        <h5 class="alert-heading"><i class="bi bi-check-circle-fill"></i> Terima Kasih!</h5>
        <p>Pesanan Anda telah berhasil dibuat. Silakan lakukan pembayaran agar pesanan dapat segera kami proses.</p>
    </div>

    <div class="text-center mt-4">
        <a href="welcome.jsp" class="btn btn-primary">Lanjut Belanja</a>
        <a href="my_orders.jsp" class="btn btn-outline-primary">Lihat Riwayat Pesanan Saya</a>
    </div>
</div>

</body>
</html>