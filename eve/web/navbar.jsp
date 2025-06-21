<%-- File: navbar_admin.jsp --%>
<%@ page pageEncoding="UTF-8" %>
<%
    // Variabel userName diasumsikan sudah ada dari halaman yang memanggil (misal: transaksi.jsp)
    String adminName = (String) session.getAttribute("user");
%>
<nav class="navbar navbar-expand-lg navbar-light fixed-top bg-white shadow-sm">
  <div class="container-fluid">
    <a class="navbar-brand" href="admin.jsp"> RutthShop [Admin]</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbar">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-end" id="adminNavbar">
      <ul class="navbar-nav align-items-center">
        <li class="nav-item">
          <a class="nav-link" href="data-user.jsp">Data User</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="data-barang.jsp">Data Barang</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="transaksi.jsp">Data Transaksi</a>
        </li>
        <li class="nav-item dropdown ms-3">
          <a class="nav-link dropdown-toggle" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown">
            <i class="bi bi-person-circle"></i> <%= adminName %>
          </a>
          <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="adminDropdown">
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