<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*, java.text.NumberFormat, java.text.SimpleDateFormat" %>

<%!
    // Fungsi pembantu dari navbar untuk menghitung total item di keranjang
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
    // ======================================================================
    // BAGIAN 1: LOGIKA PENGAMBILAN DATA (TERMASUK DATA UNTUK NAVBAR)
    // ======================================================================

    // Logika yang dibutuhkan oleh Navbar (dari source code kedua)
    String userName = (session != null) ? (String) session.getAttribute("user") : null;
    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
    }

    // Logika asli halaman detail pesanan
    String currentSessionId = session.getId();
    int invoiceId = -1;
    String errorMessage = null;
    try {
        invoiceId = Integer.parseInt(request.getParameter("id"));
    } catch (NumberFormatException e) {
        errorMessage = "ID Pesanan tidak valid.";
    }

    Map<String, Object> invoiceData = null;
    List<Map<String, Object>> itemDetails = new ArrayList<>();
    Connection conn = null;

    if (errorMessage == null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

            String sqlInvoice = "SELECT * FROM invoice WHERE id = ? AND session_id = ?";
            PreparedStatement psInvoice = conn.prepareStatement(sqlInvoice);
            psInvoice.setInt(1, invoiceId);
            psInvoice.setString(2, currentSessionId);
            ResultSet rsInvoice = psInvoice.executeQuery();

            if (rsInvoice.next()) {
                invoiceData = new HashMap<>();
                invoiceData.put("nomor_invoice", rsInvoice.getString("nomor_invoice"));
                invoiceData.put("nama_penerima", rsInvoice.getString("nama_penerima"));
                invoiceData.put("alamat", rsInvoice.getString("alamat"));
                invoiceData.put("metode", rsInvoice.getString("metode"));
                invoiceData.put("total", rsInvoice.getInt("total"));
                invoiceData.put("status", rsInvoice.getString("status"));
                invoiceData.put("tanggal", new SimpleDateFormat("dd-MM-yyyy HH:mm").format(rsInvoice.getTimestamp("tanggal")));
            } else {
                errorMessage = "Pesanan tidak ditemukan atau Anda tidak memiliki akses untuk melihat pesanan ini.";
            }
            rsInvoice.close();
            psInvoice.close();
            
            if (errorMessage == null) {
                String sqlDetails = "SELECT * FROM invoice_detail WHERE invoice_id = ?";
                PreparedStatement psDetails = conn.prepareStatement(sqlDetails);
                psDetails.setInt(1, invoiceId);
                ResultSet rsDetails = psDetails.executeQuery();
                
                while(rsDetails.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("nama_barang", rsDetails.getString("nama_barang"));
                    item.put("harga", rsDetails.getInt("harga"));
                    item.put("qty", rsDetails.getInt("qty"));
                    item.put("subtotal", rsDetails.getInt("subtotal"));
                    itemDetails.add(item);
                }
                rsDetails.close();
                psDetails.close();
            }

        } catch (Exception e) {
            errorMessage = "Gagal memuat detail pesanan: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Detail Pesanan <%= invoiceData != null ? invoiceData.get("nomor_invoice") : "" %></title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: #f8f9fa; padding-top: 80px; }
        .content { margin-left: auto; margin-right: auto; max-width: 900px; padding: 30px 20px 40px 20px; min-height: 100vh; }
        .card { border: none; border-radius: 18px; box-shadow: 0 2px 12px rgba(0,0,0,0.07); }
        .invoice-header { background: linear-gradient(120deg, #f8f9fa 60%, #e0f7fa 100%); border-radius: 18px; padding: 20px; margin-bottom: 20px; }
        .status-badge { padding: 6px 12px; border-radius: 20px; font-weight: 500; font-size: 0.85rem; }
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

<nav class="navbar navbar-expand-lg navbar-light bg-white fixed-top shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="welcome.jsp">RutthShop</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
            <ul class="navbar-nav align-items-center">
                <% if (userName != null) { %>
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
                <% } else { %>
                    <li class="nav-item">
                        <a class="nav-link" href="login.html">Login</a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<div class="content">
    <% if (errorMessage != null) { %>
        <div class="alert alert-warning"><%= errorMessage %></div>
        <a href="my_orders.jsp" class="btn btn-primary">Kembali ke Riwayat Pesanan</a>
    <% } else if (invoiceData != null) { %>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="bi bi-receipt"></i> Detail Pesanan</h2>
            <a href="my_orders.jsp" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Kembali</a>
        </div>

        <div class="card mb-4">
            <div class="card-body p-4">
                <div class="invoice-header d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h5 class="mb-1">NO. PESANAN: <%= invoiceData.get("nomor_invoice") %></h5>
                        <div><small><i class="bi bi-calendar3"></i> <%= invoiceData.get("tanggal") %></small></div>
                    </div>
                    <div>
                        <%
                            String status = (String) invoiceData.get("status");
                            String statusClass = "status-" + status;
                        %>
                        <span class="status-badge <%= statusClass %>"><%= status.toUpperCase() %></span>
                    </div>
                </div>

                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-body">
                                <h6 class="card-title mb-3"><i class="bi bi-truck"></i> Informasi Pengiriman</h6>
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

                <h5 class="mt-4 mb-3"><i class="bi bi-box-seam"></i> Rincian Barang</h5>
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead class="table-light">
                            <tr>
                                <th>Nama Barang</th>
                                <th class="text-end">Harga</th>
                                <th class="text-center">Jumlah</th>
                                <th class="text-end">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            Locale localeID = new Locale("id", "ID");
                            for (Map<String, Object> item : itemDetails) { 
                            %>
                            <tr>
                                <td><strong><%= item.get("nama_barang") %></strong></td>
                                <td class="text-end">Rp <%= NumberFormat.getNumberInstance(localeID).format(item.get("harga")) %></td>
                                <td class="text-center"><%= item.get("qty") %></td>
                                <td class="text-end">Rp <%= NumberFormat.getNumberInstance(localeID).format(item.get("subtotal")) %></td>
                            </tr>
                            <% } %>
                        </tbody>
                        <tfoot>
                            <tr class="total-row table-light">
                                <td colspan="3" class="text-end"><strong>Total:</strong></td>
                                <td class="text-end"><strong>Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(invoiceData.get("total")) %></strong></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>
    <% } %>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>