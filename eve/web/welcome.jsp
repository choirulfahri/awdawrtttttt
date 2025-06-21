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
    // ======================================================================
    // BLOK LOGIKA: Menangani permintaan "Tambah ke Keranjang" (AJAX POST)
    // ======================================================================
    String action = request.getParameter("action");
    if ("add_to_cart".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
        
        if (session.getAttribute("user") == null) {
            response.setStatus(401); 
            response.setContentType("application/json");
            out.print("{\"success\": false, \"message\": \"User not logged in.\"}");
            out.flush();
            return; 
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int quantity = 1; // Dari halaman welcome, kuantitas selalu 1

            @SuppressWarnings("unchecked")
            Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
            if (cart == null) {
                cart = new HashMap<>();
            }

            cart.put(productId, cart.getOrDefault(productId, 0) + quantity);
            session.setAttribute("cart", cart);

            int totalCartCount = calculateTotalItems(cart);
            
            response.setContentType("application/json");
            String jsonResponse = String.format("{\"success\": true, \"cartCount\": %d}", totalCartCount);
            out.clear(); 
            out.print(jsonResponse);
            out.flush();

        } catch (Exception e) {
            response.setStatus(500);
            response.setContentType("application/json");
            out.clear();
            out.print("{\"success\": false, \"message\": \"Error processing request.\"}");
            out.flush();
        }
        
        // Hentikan eksekusi JSP agar tidak merender HTML
        return;
    }

    // ======================================================================
    // BLOK TAMPILAN: Merender halaman HTML (GET Request)
    // ======================================================================
    String userName = (session != null) ? (String) session.getAttribute("user") : null;
    if (userName == null) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Selamat Datang di RutthShop</title>
  <link href="css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />
  <style>
    /* Style disamakan dengan halaman item-detail.jsp */
    body {
      background: white;
      padding-top: 80px;
    }
    .navbar-brand {
      font-weight: bold;
      font-size: 1.5rem;
      letter-spacing: 1px;
      color: #00bcd4 !important; /* Diubah agar konsisten */
    }
    .navbar {
      box-shadow: 0 2px 12px rgba(0,188,212,0.07);
      background: #fff;
    }
    .navbar .nav-link, .navbar .dropdown-toggle {
      color: #212529 !important;
      font-weight: 500;
    }
    .navbar .nav-link.active, .navbar .nav-link:hover {
      color: #00bcd4 !important; /* Diubah agar konsisten */
    }
    .navbar-nav .nav-item {
      margin-right: 15px;
    }
    .navbar-nav .nav-item:last-child {
      margin-right: 0;
    }
    .card-product {
      border: none;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
      transition: all 0.2s ease-in-out;
    }
    .card-product:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 20px rgba(0,0,0,0.1);
    }
    .card-product .card-title {
      font-size: 1.1rem;
      font-weight: 600;
    }
    .card-product .card-text {
      color: #009688;
      font-size: 1.05rem;
      font-weight: 500;
    }
    .btn-add-cart {
        background-color: #4caf50;
        border-color: #4caf50;
    }
    .btn-add-cart:hover {
        background-color: #388e3c;
        border-color: #388e3c;
    }
  </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-white fixed-top">
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
            <%
                Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
                int cartCount = calculateTotalItems(cart);
            %>
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

<div class="container" style="padding-top: 20px;">
  <h3 class="mb-4"><i class="bi bi-shop"></i> Daftar Barang Dijual</h3>
  <div class="row">
    <%
      Connection conn = null;
      try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM barang ORDER BY id DESC");
        while (rs.next()) {
    %>
    <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
      <div class="card card-product h-100">
        <img src="<%= (rs.getString("gambar") != null && !rs.getString("gambar").isEmpty()) ? "uploads/" + rs.getString("gambar") : "https://via.placeholder.com/300x210?text=No+Image" %>" 
             class="card-img-top" style="height:210px;object-fit:cover;border-radius:18px 18px 0 0;" alt="<%= rs.getString("nama") %>" />
        <div class="card-body d-flex flex-column p-3">
          <h5 class="card-title"><%= rs.getString("nama") %></h5>
          <p class="card-text mb-3">Rp <%= String.format("%,d", rs.getInt("harga")) %></p>
          <div class="mt-auto">
            <a href="item-detail.jsp?id=<%= rs.getInt("id") %>" class="btn btn-outline-primary w-100 mb-2">Lihat Detail</a>
            <button class="btn btn-success w-100 add-to-cart-btn" data-product-id="<%= rs.getInt("id") %>">
                <i class="bi bi-cart-plus"></i> Tambah
            </button>
          </div>
        </div>
      </div>
    </div>
    <%
        }
        rs.close();
        st.close();
      } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
      } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
      }
    %>
  </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const addToCartButtons = document.querySelectorAll('.add-to-cart-btn');
    const cartCountElement = document.getElementById('cart-count');

    addToCartButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const productId = this.getAttribute('data-product-id');
            const params = new URLSearchParams();

            // Siapkan parameter untuk dikirim
            params.append('action', 'add_to_cart');
            params.append('productId', productId);
            params.append('quantity', '1'); // Dari halaman ini, kuantitas selalu 1

            // Kirim request ke halaman ini sendiri
            fetch('', {
                method: 'POST',
                body: params
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    cartCountElement.innerText = data.cartCount;
                    alert('Barang berhasil ditambahkan!');
                } else {
                    alert('Gagal: ' + (data.message || 'Terjadi kesalahan'));
                }
            })
            .catch(error => {
                console.error('Fetch error:', error);
                alert('Terjadi masalah koneksi.');
            });
        });
    });
});
</script>

</body>
</html>