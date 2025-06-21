<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*, java.text.NumberFormat" %>

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
    // ===============================================
    // LOGIKA GABUNGAN (NAVBAR & KONTEN HALAMAN)
    // ===============================================

    // Cek session user dari navbar
    String userName = (session != null) ? (String) session.getAttribute("user") : null;
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Ambil keranjang dari session (digunakan oleh navbar dan konten)
    Map<Integer, Integer> sessionCart = (Map<Integer, Integer>) session.getAttribute("cart");
    int cartCount = calculateTotalItems(sessionCart);

    // Variabel untuk konten halaman
    List<Map<String, Object>> items = new ArrayList<>();
    long total = 0;
    String idParam = request.getParameter("id");
    String qtyParam = request.getParameter("qty");

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

        if (idParam != null && qtyParam != null) {
            // Logika untuk "Beli Langsung"
            int id = Integer.parseInt(idParam);
            int qty = Integer.parseInt(qtyParam);
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM barang WHERE id=?");
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", id);
                item.put("nama", rs.getString("nama"));
                item.put("harga", rs.getInt("harga"));
                item.put("qty", qty);
                item.put("subtotal", (long) rs.getInt("harga") * qty);
                items.add(item);
            }
            rs.close();
            ps.close();
        } else if (sessionCart != null && !sessionCart.isEmpty()) {
            // Logika untuk checkout dari keranjang
            Set<Integer> productIds = sessionCart.keySet();
            if (!productIds.isEmpty()) {
                StringBuilder sql = new StringBuilder("SELECT * FROM barang WHERE id IN (");
                for (int i = 0; i < productIds.size(); i++) {
                    sql.append("?").append(i < productIds.size() - 1 ? "," : "");
                }
                sql.append(")");

                Map<Integer, Map<String, Object>> productDetails = new HashMap<>();
                PreparedStatement ps = conn.prepareStatement(sql.toString());
                int paramIndex = 1;
                for (Integer id : productIds) {
                    ps.setInt(paramIndex++, id);
                }
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> details = new HashMap<>();
                    details.put("nama", rs.getString("nama"));
                    details.put("harga", rs.getInt("harga"));
                    productDetails.put(rs.getInt("id"), details);
                }
                rs.close();
                ps.close();

                for (Map.Entry<Integer, Integer> entry : sessionCart.entrySet()) {
                    int id = entry.getKey();
                    int qty = entry.getValue();
                    Map<String, Object> details = productDetails.get(id);
                    if (details != null) {
                        Map<String, Object> item = new HashMap<>();
                        int harga = (int) details.get("harga");
                        item.put("id", id);
                        item.put("nama", details.get("nama"));
                        item.put("harga", harga);
                        item.put("qty", qty);
                        item.put("subtotal", (long) harga * qty);
                        items.add(item);
                    }
                }
            }
        }
        
        for (Map<String, Object> item : items) {
            total += (long) item.get("subtotal");
        }
    } catch (Exception e) {
        out.println("<div class='container mt-4'><div class='alert alert-danger'>Gagal mengambil data barang: " + e.getMessage() + "</div></div>");
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Pembayaran</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: #f8f9fa; padding-top: 80px; }
        .content { max-width: 700px; margin: 40px auto; background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.06); }
        .table thead { background-color: #e9ecef; }
        .navbar-brand { font-weight: bold; font-size: 1.5rem; letter-spacing: 1px; }
        .navbar { box-shadow: 0 2px 12px rgba(0,0,0,0.08); background: #fff; }
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
                <li class="nav-item">
                    <a class="nav-link" href="my_orders.jsp">
                        <i class="bi bi-box-seam"></i> Pesananku
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="keranjang.jsp">
                        <i class="bi bi-cart3"></i> Keranjang
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
    <a href="<%= (idParam != null) ? "item-detail.jsp?id="+idParam : "keranjang.jsp" %>" class="btn btn-outline-secondary mb-3"><i class="bi bi-arrow-left"></i> Kembali</a>
    <h2 class="mb-4">💳 Pembayaran</h2>
    
    <% if(items.isEmpty()) { %>
        <div class="alert alert-warning">Tidak ada barang untuk dibayar. Silakan kembali dan isi keranjang Anda.</div>
    <% } else { %>
        <h5>Ringkasan Belanja:</h5>
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Nama Barang</th>
                    <th class="text-end">Harga</th>
                    <th class="text-center">Jumlah</th>
                    <th class="text-end">Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, Object> item : items) { %>
                <tr>
                    <td><%= item.get("nama") %></td>
                    <td class="text-end">Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(item.get("harga")) %></td>
                    <td class="text-center"><%= item.get("qty") %></td>
                    <td class="text-end">Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(item.get("subtotal")) %></td>
                </tr>
                <% } %>
            </tbody>
            <tfoot>
                <tr class="table-light">
                    <th colspan="3" class="text-end">Total</th>
                    <th class="text-end fs-5">Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(total) %></th>
                </tr>
            </tfoot>
        </table>

        <form action="invoice.jsp" method="post" class="mt-4">
            <h5 class="mt-4">Detail Pengiriman & Pembayaran</h5>
            <input type="hidden" name="total" value="<%= total %>">
            <% for (Map<String, Object> item : items) { %>
                <input type="hidden" name="barang_id" value="<%= item.get("id") %>">
                <input type="hidden" name="barang_nama" value="<%= item.get("nama") %>">
                <input type="hidden" name="barang_harga" value="<%= item.get("harga") %>">
                <input type="hidden" name="barang_qty" value="<%= item.get("qty") %>">
                <input type="hidden" name="barang_subtotal" value="<%= item.get("subtotal") %>">
            <% } %>
            <div class="mb-3">
                <label class="form-label">Nama Penerima</label>
                <input type="text" name="nama_penerima" class="form-control" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Alamat Pengiriman</label>
                <textarea name="alamat" class="form-control" rows="3" required></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Metode Pembayaran</label>
                <select name="metode" id="metode" class="form-select" required onchange="toggleBankInput()">
                    <option value="Transfer Bank">Transfer Bank</option>
                    <option value="COD">COD (Bayar di Tempat)</option>
                    <option value="E-Wallet">E-Wallet</option>
                </select>
            </div>
            <div class="mb-3" id="bankInput" style="display: block;">
                <label class="form-label">Pilih Bank</label>
                <select name="nama_bank" class="form-select">
                    <option value="BCA">BCA</option>
                    <option value="BNI">BNI</option>
                    <option value="BRI">BRI</option>
                    <option value="Mandiri">Mandiri</option>
                    <option value="CIMB">CIMB</option>
                </select>
            </div>
            <div class="d-grid">
                <button type="submit" class="btn btn-success btn-lg">Konfirmasi & Bayar</button>
            </div>
        </form>
    <% } %>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
<script>
function toggleBankInput() {
    var metode = document.getElementById('metode').value;
    document.getElementById('bankInput').style.display = (metode === 'Transfer Bank') ? 'block' : 'none';
}
window.onload = toggleBankInput;
</script>
</body>
</html>