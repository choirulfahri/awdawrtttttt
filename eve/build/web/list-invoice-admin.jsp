<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Daftar Invoice</title>
  
  <style>
    body {
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      padding-top: 80px;
    }
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      height: 100%;
      width: 210px;
      background: #212529;
      padding-top: 30px;
      box-shadow: 2px 0 10px rgba(0,0,0,0.07);
      z-index: 100;
    }
    .sidebar .logo {
      font-size: 1.6rem;
      font-weight: bold;
      color: #00bcd4;
      text-align: center;
      margin-bottom: 30px;
      letter-spacing: 1px;
    }
    .sidebar a {
      color: #f8f9fa;
      padding: 12px 22px;
      text-decoration: none;
      display: flex;
      align-items: center;
      font-size: 1.08rem;
      border-radius: 8px 0 0 8px;
      margin-bottom: 6px;
      transition: background 0.2s;
    }
    .sidebar a:hover, .sidebar a.active {
      background: #00bcd4;
      color: #fff;
    }
    .content {
      margin-left: 230px;
      padding: 30px 20px 20px 20px;
      min-height: 100vh;
    }
    .navbar-brand {
      font-weight: bold;
      font-size: 1.5rem;
      letter-spacing: 1px;
      color: #00bcd4 !important;
    }
    .navbar {
      box-shadow: 0 2px 12px rgba(0,188,212,0.07);
      background: #fff;
    }
    .navbar .nav-link, .navbar .dropdown-toggle {
      color: #212529 !important;
      font-weight: 500;
      margin-right: 10px;
    }
    .navbar .nav-link.active, .navbar .nav-link:hover {
      color: #00bcd4 !important;
    }
    
    @media (max-width: 900px) {
      .sidebar { width: 100%; height: auto; position: static; box-shadow: none; }
      .content { margin-left: 0; padding: 15px; }
    }
  </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
  <div class="logo mb-4">
    <i class="bi bi-bag-check-fill"></i> TokoKita
  </div>
  <a href="admin.jsp"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
  <a href="data-user.jsp"><i class="bi bi-people me-2"></i> Data Pengguna</a>
  <a href="data-barang.jsp"><i class="bi bi-box-seam me-2"></i> Data Barang</a>
  <a href="list-invoice-admin.jsp" class="active"><i class="bi bi-receipt me-2"></i> Transaksi</a>
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg fixed-top" style="left:210px;">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
      <ul class="navbar-nav align-items-center">
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



<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>