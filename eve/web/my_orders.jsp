<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*, java.text.SimpleDateFormat, java.text.NumberFormat" %>

<%!
    // Fungsi pembantu untuk menghitung total item di keranjang
    private int calculateTotalItems(Map<Integer, Integer> cart) {
        if (cart == null) return 0;
        int total = 0;
        for (int qty : cart.values()) {
            total += qty;
        }
        return total;
    }
%>

<%
    // =================================================================
    // BAGIAN PERSIAPAN DARI NAVBAR (diambil dari keranjang.jsp)
    // =================================================================

    // Cek session user, jika tidak ada, redirect ke halaman login
    String userName = (session != null) ? (String) session.getAttribute("user") : null;
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Ambil keranjang dari session untuk menampilkan jumlah item di navbar
    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
    }

    // =================================================================
    // BAGIAN LOGIKA HALAMAN RIWAYAT PESANAN
    // =================================================================
    
    // Mengambil ID sesi dari browser pengunjung saat ini untuk query pesanan.
    String sessionId = session.getId();
    String filterStatus = request.getParameter("status");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Riwayat Pesanan Saya - RutthShop</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: #f8f9fa; padding-top: 80px; }
        .content { padding: 20px 30px; max-width: 1200px; margin: auto; }
        .card { border: none; border-radius: 18px; box-shadow: 0 2px 12px rgba(0,0,0,0.07); }
        .table { vertical-align: middle; }
        .status-badge { padding: 6px 12px; border-radius: 20px; font-weight: 500; font-size: 0.85rem; }
        .status-menunggu { background-color: #fff3cd; color: #856404; }
        .status-dibayar { background-color: #d4edda; color: #155724; }
        .status-dikirim { background-color: #cce5ff; color: #004085; }
        .status-selesai { background-color: #d1e7dd; color: #0f5132; }
        .status-batal { background-color: #f8d7da; color: #721c24; }
        .btn-detail { background: #00bcd4; border-color: #00bcd4; color: white; }
        .btn-detail:hover { background: #0097a7; border-color: #0097a7; color: white; }
        .filter-form { background: white; border-radius: 12px; padding: 15px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
    </style>
</head>
<body>

<%-- ====================================================== --%>
<%-- KODE NAVBAR BARU DITEMPATKAN DI SINI                   --%>
<%-- ====================================================== --%>
<nav class="navbar navbar-expand-lg navbar-light bg-white fixed-top shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="welcome.jsp">RutthShop</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
            <ul class="navbar-nav align-items-center">
                <li class="nav-item">
                    <a class="nav-link" href="my_orders.jsp">
                        <i class="bi bi-box-seam"></i> Pesananku
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="keranjang.jsp">
                        <i class="bi bi-cart3"></i> Keranjang
                        <% int cartCount = calculateTotalItems(cart); %>
                        <span class="badge bg-danger rounded-pill ms-1" id="cart-count"><%= (cartCount > 0) ? cartCount : "" %></span>
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                        <i class="bi bi-person-circle"></i> <%= userName %>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                        <li><a class="dropdown-item" href="data-user.jsp"><i class="bi bi-person"></i> Profil</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <a href="logout.jsp" class="dropdown-item text-danger">
                                <i class="bi bi-box-arrow-right"></i> Logout
                            </a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-receipt-cutoff"></i> Riwayat Pesanan Saya</h2>
    </div>

    <div class="filter-form mb-4">
        <form action="my_orders.jsp" method="get" class="row align-items-end g-2">
            <div class="col-md-4">
                <label for="search-status" class="form-label">Filter berdasarkan Status</label>
                <select class="form-select" id="search-status" name="status" onchange="this.form.submit()">
                    <option value="">Semua Status</option>
                    <option value="menunggu" <%= "menunggu".equals(filterStatus) ? "selected" : "" %>>Menunggu</option>
                    <option value="dibayar" <%= "dibayar".equals(filterStatus) ? "selected" : "" %>>Dibayar</option>
                    <option value="dikirim" <%= "dikirim".equals(filterStatus) ? "selected" : "" %>>Dikirim</option>
                    <option value="selesai" <%= "selesai".equals(filterStatus) ? "selected" : "" %>>Selesai</option>
                    <option value="batal" <%= "batal".equals(filterStatus) ? "selected" : "" %>>Batal</option>
                </select>
            </div>
            <div class="col-md-4">
                <a href="my_orders.jsp" class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i> Reset Filter</a>
            </div>
        </form>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>No. Pesanan</th>
                            <th>Tanggal</th>
                            <th>Total Belanja</th>
                            <th class="text-center">Status</th>
                            <th class="text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
                                
                                StringBuilder sql = new StringBuilder("SELECT id, nomor_invoice, tanggal, total, status FROM invoice WHERE session_id = ?");
                                if (filterStatus != null && !filterStatus.isEmpty()) {
                                    sql.append(" AND status = ?");
                                }
                                sql.append(" ORDER BY tanggal DESC");

                                PreparedStatement ps = conn.prepareStatement(sql.toString());
                                ps.setString(1, sessionId); 
                                if (filterStatus != null && !filterStatus.isEmpty()) {
                                    ps.setString(2, filterStatus);
                                }
                                
                                ResultSet rs = ps.executeQuery();
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                        %>
                        <tr>
                            <td>
                                <strong><%= rs.getString("nomor_invoice") %></strong>
                            </td>
                            <td><%= new SimpleDateFormat("dd MMMM yyyy, HH:mm", new Locale("id", "ID")).format(rs.getTimestamp("tanggal")) %></td>
                            <td>Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(rs.getInt("total")) %></td>
                            <td class="text-center">
                                <span class="status-badge status-<%= rs.getString("status") %>"><%= rs.getString("status").toUpperCase() %></span>
                            </td>
                            <td class="text-center">
                                <a href="detail_order.jsp?id=<%= rs.getInt("id") %>" class="btn btn-detail btn-sm">
                                    <i class="bi bi-eye"></i> Detail
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                if (!hasData) {
                                    out.println("<tr><td colspan='5' class='text-center text-muted py-5'>Anda belum memiliki riwayat pesanan di sesi browser ini.</td></tr>");
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='5' class='text-center text-danger'>Gagal memuat data pesanan. Silakan coba lagi nanti.</td></tr>");
                                e.printStackTrace();
                            } finally {
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>