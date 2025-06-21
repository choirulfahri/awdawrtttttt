<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*" %>

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
    // BAGIAN 1: PERSIAPAN DAN LOGIKA SEBELUM RENDER HTML
    // =================================================================

    // Cek session user
    String userName = (session != null) ? (String) session.getAttribute("user") : null;
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Ambil keranjang dari session
    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
    }

    // Logika hapus barang dipindahkan ke atas
    String removeIdStr = request.getParameter("remove");
    if (removeIdStr != null && !removeIdStr.isEmpty()) {
        try {
            int idToRemove = Integer.parseInt(removeIdStr);
            cart.remove(idToRemove);
            session.setAttribute("cart", cart);
            response.sendRedirect("keranjang.jsp"); // Redirect agar parameter 'remove' hilang dari URL
            return;
        } catch (NumberFormatException e) {
            // Abaikan jika parameter tidak valid
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keranjang Belanja - RutthShop</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body {
            background: #f8f9fa;
            padding-top: 80px; /* Adjusted for fixed-top navbar */
        }
        .content {
            max-width: 950px;
            margin: 40px auto;
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        .table > :not(caption) > * > * {
            padding: 1rem 1rem;
            vertical-align: middle;
        }
        .product-img-thumb {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 8px;
        }
        .grand-total {
            font-size: 1.25rem;
            font-weight: bold;
        }
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
                        <%-- KOREKSI: Gunakan variabel 'cart' yang sudah ada --%>
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
        <h2 class="mb-0"><i class="bi bi-cart3 me-2"></i>Keranjang Belanja</h2>
        <a href="welcome.jsp" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Lanjut Belanja</a>
    </div>

    <% if (cart.isEmpty()) { %>
        <div class="alert alert-info text-center">
            <p class="mb-0">Keranjang belanja Anda masih kosong.</p>
        </div>
    <% } else {
        // ... (rest of the code is the same)
    %>
    <form action="pembayaran.jsp" method="post">
        <table class="table table-hover">
            <thead class="table-light">
                <tr>
                    <th scope="col" colspan="2">Produk</th>
                    <th scope="col" class="text-center">Jumlah</th>
                    <th scope="col" class="text-end">Harga Satuan</th>
                    <th scope="col" class="text-end">Subtotal</th>
                    <th scope="col" class="text-center">Aksi</th>
                </tr>
            </thead>
            <tbody>
            <%
                long grandTotal = 0;
                // Database connection and query
                Map<Integer, Map<String, Object>> productDetails = new HashMap<>();
                Connection conn = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
                    
                    Set<Integer> productIds = cart.keySet();
                    if (!productIds.isEmpty()) {
                        String sql = "SELECT id, nama, harga, gambar FROM barang WHERE id IN (";
                        StringBuilder placeholders = new StringBuilder();
                        for (int i = 0; i < productIds.size(); i++) {
                            placeholders.append("?");
                            if (i < productIds.size() - 1) {
                                placeholders.append(",");
                            }
                        }
                        sql += placeholders.toString() + ")";

                        PreparedStatement ps = conn.prepareStatement(sql);
                        int i = 1;
                        for (Integer id : productIds) {
                            ps.setInt(i++, id);
                        }

                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                            Map<String, Object> details = new HashMap<>();
                            details.put("nama", rs.getString("nama"));
                            details.put("harga", rs.getInt("harga"));
                            details.put("gambar", rs.getString("gambar"));
                            productDetails.put(rs.getInt("id"), details);
                        }
                        rs.close();
                        ps.close();
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Gagal mengambil data produk: " + e.getMessage() + "</div>");
                } finally {
                    if (conn != null) try { conn.close(); } catch (SQLException ex) {}
                }
                
                // Render table rows
                for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
                    int id = entry.getKey();
                    int qty = entry.getValue();
                    Map<String, Object> details = productDetails.get(id);

                    if (details != null) {
                        String nama = (String) details.get("nama");
                        int harga = (int) details.get("harga");
                        String gambar = (String) details.get("gambar");
                        long subtotal = (long) harga * qty;
                        grandTotal += subtotal;
            %>
                <tr>
                    <td style="width: 100px;">
                        <img src="<%= (gambar != null && !gambar.isEmpty()) ? "uploads/" + gambar : "https://via.placeholder.com/80" %>" 
                             alt="<%= nama %>" class="product-img-thumb">
                    </td>
                    <td>
                        <strong><%= nama %></strong>
                    </td>
                    <td class="text-center"><%= qty %></td>
                    <td class="text-end">Rp <%= String.format("%,d", harga) %></td>
                    <td class="text-end">Rp <%= String.format("%,d", subtotal) %></td>
                    <td class="text-center">
                        <a href="keranjang.jsp?remove=<%= id %>" class="btn btn-outline-danger btn-sm" title="Hapus item">
                            <i class="bi bi-trash"></i>
                        </a>
                    </td>
                </tr>
            <%
                    }
                }
            %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="4" class="text-end border-0"><strong>Total Belanja</strong></td>
                    <td colspan="2" class="text-end border-0 grand-total">Rp <%= String.format("%,d", grandTotal) %></td>
                </tr>
            </tfoot>
        </table>

        <div class="d-flex justify-content-end mt-4">
            <button type="submit" class="btn btn-primary btn-lg">
                Lanjut ke Pembayaran <i class="bi bi-arrow-right"></i>
            </button>
        </div>
    </form>
    <% } %>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>