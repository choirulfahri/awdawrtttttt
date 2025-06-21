<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale, java.text.SimpleDateFormat, java.util.ArrayList, java.util.List, java.util.Map, java.util.HashMap" %>
<%
    // Pengecekan login admin
    String adminUserName = (session != null) ? (String) session.getAttribute("user") : null;
    if (adminUserName == null) {
        response.sendRedirect("login.html");
        return;
    }

    Map<String, Object> invoiceData = new HashMap<>();
    List<Map<String, Object>> itemDetails = new ArrayList<>();
    String errorMessage = null;
    int invoiceId = -1;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        invoiceId = Integer.parseInt(request.getParameter("id"));
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
        
        ps = conn.prepareStatement("SELECT * FROM invoice WHERE id=?");
        ps.setInt(1, invoiceId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            invoiceData.put("id", rs.getInt("id"));
            invoiceData.put("nomor_invoice", rs.getString("nomor_invoice"));
            invoiceData.put("session_id", rs.getString("session_id"));
            invoiceData.put("nama_penerima", rs.getString("nama_penerima"));
            invoiceData.put("alamat", rs.getString("alamat"));
            invoiceData.put("metode", rs.getString("metode"));
            invoiceData.put("status", rs.getString("status"));
            invoiceData.put("total", rs.getInt("total"));
            
            // PERBAIKAN: Memastikan format tanggal benar dan menggunakan Locale Indonesia
            // untuk nama bulan yang benar (misal: "Juni" bukan "June")
            invoiceData.put("tanggal", new SimpleDateFormat("dd MMMM yyyy, HH:mm", new Locale("id", "ID")).format(rs.getTimestamp("tanggal")));

        } else {
            errorMessage = "Invoice dengan ID " + invoiceId + " tidak ditemukan.";
        }
        rs.close();
        ps.close();

        if (errorMessage == null) {
            ps = conn.prepareStatement("SELECT * FROM invoice_detail WHERE invoice_id=?");
            ps.setInt(1, invoiceId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("nama_barang", rs.getString("nama_barang"));
                item.put("harga", rs.getInt("harga"));
                item.put("qty", rs.getInt("qty"));
                item.put("subtotal", rs.getInt("subtotal"));
                itemDetails.add(item);
            }
        }
    } catch (NumberFormatException e) {
        errorMessage = "ID Invoice tidak valid.";
    } catch (Exception e) {
        errorMessage = "Gagal mengambil data dari database: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Detail Pesanan <%= invoiceData.get("nomor_invoice") %> - Admin</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: #f8f9fa; padding-top: 70px; }
        .content { margin-left: auto; margin-right: auto; max-width: 1000px; padding: 30px 20px 20px 20px; min-height: 100vh; }
        .card { border: none; border-radius: 18px; box-shadow: 0 2px 12px rgba(0,0,0,0.07); }
        .table { border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
        .table thead { background-color: #f8f9fa; }
        .invoice-header { background: linear-gradient(120deg, #f8f9fa 60%, #e0f7fa 100%); border-radius: 18px; padding: 20px; margin-bottom: 20px; }
        .status-badge { padding: 6px 12px; border-radius: 20px; font-weight: 500; font-size: 0.85rem; display: inline-block; }
        .status-menunggu { background-color: #fff3cd; color: #856404; }
        .status-dibayar { background-color: #d4edda; color: #155724; }
        .status-dikirim { background-color: #cce5ff; color: #004085; }
        .status-selesai { background-color: #d1e7dd; color: #0f5132; }
        .status-batal { background-color: #f8d7da; color: #721c24; }
        .detail-row { padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { font-weight: 600; color: #555; }
        .detail-value { font-weight: 500; }
        .total-row { background-color: #f8f9fa; font-weight: 700; color: #007bff; }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />
    
<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-receipt-alt"></i> Detail Invoice</h2>
        <a href="transaksi.jsp" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Kembali ke Daftar</a>
    </div>

    <% if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
    <% } else { %>
        <div class="card mb-4">
            <div class="card-body p-4">
                <div class="invoice-header d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <h5 class="mb-1">NO. PESANAN: <%= invoiceData.get("nomor_invoice") %></h5>
                        <div><small><i class="bi bi-calendar3"></i> <%= invoiceData.get("tanggal") %></small></div>
                    </div>
                    <div>
                        <span class="status-badge status-<%= invoiceData.get("status") %>"><i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i> <%= ((String)invoiceData.get("status")).toUpperCase() %></span>
                    </div>
                </div>

                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-body">
                                <h6 class="card-title mb-3"><i class="bi bi-person"></i> Informasi Pelanggan</h6>
                                <div class="detail-row">
                                    <div class="detail-label">Session ID Pengguna</div>
                                    <div class="detail-value" style="word-wrap: break-word;"><%= invoiceData.get("session_id") %></div>
                                </div>
                                <div class="detail-row">
                                    <div class="detail-label">Nama Penerima</div>
                                    <div class="detail-value"><%= invoiceData.get("nama_penerima") %></div>
                                </div>
                                <div class="detail-row">
                                    <div class="detail-label">Alamat Pengiriman</div>
                                    <div class="detail-value"><%= invoiceData.get("alamat") %></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                         <div class="card h-100">
                            <div class="card-body">
                                <h6 class="card-title mb-3"><i class="bi bi-credit-card"></i> Informasi Pembayaran</h6>
                                <div class="detail-row">
                                    <div class="detail-label">Metode Pembayaran</div>
                                    <div class="detail-value"><%= invoiceData.get("metode") %></div>
                                </div>
                                <div class="detail-row">
                                    <div class="detail-label">Total Pembayaran</div>
                                    <div class="detail-value text-primary fw-bold fs-5">
                                        Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(invoiceData.get("total")) %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <h5 class="mt-4 mb-3"><i class="bi bi-box-seam"></i> Detail Barang</h5>
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead class="table-light">
                            <tr><th>Nama Barang</th><th class="text-end">Harga</th><th class="text-center">Jumlah</th><th class="text-end">Subtotal</th></tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> item : itemDetails) { %>
                            <tr>
                                <td><strong><%= item.get("nama_barang") %></strong></td>
                                <td class="text-end">Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(item.get("harga")) %></td>
                                <td class="text-center"><%= item.get("qty") %></td>
                                <td class="text-end">Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(item.get("subtotal")) %></td>
                            </tr>
                            <% } %>
                            <tr class="total-row table-light">
                                <td colspan="3" class="text-end"><strong>Total:</strong></td>
                                <td class="text-end"><strong>Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(invoiceData.get("total")) %></strong></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="mt-4">
                    <form action="update-status-invoice.jsp" method="post" class="d-flex align-items-center">
                        <input type="hidden" name="id" value="<%= invoiceId %>">
                        <div class="me-3">
                            <select name="status" class="form-select">
                                <% String currentStatus = (String) invoiceData.get("status"); %>
                                <option value="menunggu" <%= "menunggu".equals(currentStatus) ? "selected" : "" %>>Menunggu</option>
                                <option value="dibayar" <%= "dibayar".equals(currentStatus) ? "selected" : "" %>>Dibayar</option>
                                <option value="dikirim" <%= "dikirim".equals(currentStatus) ? "selected" : "" %>>Dikirim</option>
                                <option value="selesai" <%= "selesai".equals(currentStatus) ? "selected" : "" %>>Selesai</option>
                                <option value="batal" <%= "batal".equals(currentStatus) ? "selected" : "" %>>Batal</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary"><i class="bi bi-arrow-clockwise"></i> Update Status</button>
                    </form>
                </div>
            </div>
        </div>
    <% } %>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>