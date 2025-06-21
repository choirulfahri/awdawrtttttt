<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.text.SimpleDateFormat, java.util.Locale" %>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Edit Data Pengguna</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <style>
    body {
      background-color: #f5f5f5;
    }
    .form-container {
      max-width: 650px;
      margin: 30px auto;
      padding: 30px;
      background-color: #fff;
      border-radius: 10px;
      box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
    }
    .form-header {
      display: flex;
      align-items: center;
      margin-bottom: 25px;
      border-bottom: 2px solid #e9ecef;
      padding-bottom: 15px;
    }
    .form-header i {
      font-size: 24px;
      color: #0d6efd;
      margin-right: 15px;
    }
    .form-header h2 {
      margin: 0;
      font-weight: 600;
      color: #212529;
    }
    .form-group {
      margin-bottom: 20px;
    }
    label {
      font-weight: 500;
      margin-bottom: 8px;
      display: block;
    }
    .btn-container {
      display: flex;
      justify-content: space-between;
      margin-top: 30px;
    }
    .btn-save {
      background-color: #0d6efd;
      border-color: #0d6efd;
      padding: 10px 20px;
    }
    .btn-save:hover {
      background-color: #0b5ed7;
      border-color: #0a58ca;
    }
    .btn-delete {
      background-color: #dc3545;
      border-color: #dc3545;
      padding: 10px 20px;
    }
    .btn-delete:hover {
      background-color: #bb2d3b;
      border-color: #b02a37;
    }
    .btn-back {
      background-color: #6c757d;
      border-color: #6c757d;
      padding: 10px 20px;
    }
    .btn-back:hover {
      background-color: #5c636a;
      border-color: #565e64;
    }
    .form-control:focus {
      border-color: #86b7fe;
      box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
    }
  </style>
</head>
<body>
<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }
  String userId = request.getParameter("id");
  if (userId == null) {
    out.println("<div class='container mt-5'><div class='alert alert-danger'>ID pengguna tidak ditemukan.</div></div>");
    return;
  }
  Connection conn = null;
  PreparedStatement ps = null;
  ResultSet rs = null;
  String sql = "SELECT id, nama, email FROM users WHERE id = ?";
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", ""
    );
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(userId));
    rs = ps.executeQuery();
    if (rs.next()) {
      String nama = rs.getString("nama");
      String email = rs.getString("email");
%>
<div class="container">
  <div class="form-container">
    <div class="form-header">
      <i class="fas fa-user-edit"></i>
      <h2>Edit Data Pengguna</h2>
    </div>
    
    <form action="update-user.jsp" method="post" id="editForm">
      <input type="hidden" name="id" value="<%= userId %>" />
      
      <div class="form-group">
        <label for="nama"><i class="fas fa-user"></i> Nama:</label>
        <input type="text" id="nama" name="nama" class="form-control" value="<%= nama %>" required />
      </div>
      
      <div class="form-group">
        <label for="email"><i class="fas fa-envelope"></i> Email:</label>
        <input type="email" id="email" name="email" class="form-control" value="<%= email %>" required />
      </div>
      
      <div class="btn-container">
        <a href="data-user.jsp" class="btn btn-back">
          <i class="fas fa-arrow-left"></i> Kembali
        </a>
        <div>
          <button type="button" class="btn btn-delete" data-bs-toggle="modal" data-bs-target="#deleteModal">
            <i class="fas fa-trash"></i> Hapus
          </button>
          <button type="submit" class="btn btn-save">
            <i class="fas fa-save"></i> Simpan Perubahan
          </button>
        </div>
      </div>
    </form>
  </div>
</div>

<!-- Modal Konfirmasi Hapus -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header bg-danger text-white">
        <h5 class="modal-title" id="deleteModalLabel"><i class="fas fa-exclamation-triangle"></i> Konfirmasi Hapus</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p>Apakah Anda yakin ingin menghapus pengguna <strong><%= nama %></strong>?</p>
        <p class="text-danger"><small>Tindakan ini tidak dapat dibatalkan.</small></p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <form action="delete-user.jsp" method="post">
          <input type="hidden" name="id" value="<%= userId %>" />
          <button type="submit" class="btn btn-danger">Ya, Hapus</button>
        </form>
      </div>
    </div>
  </div>
</div>

<%
    } else {
      out.println("<div class='container mt-5'><div class='alert alert-danger'>Pengguna tidak ditemukan.</div></div>");
    }
  } catch (Exception e) {
    out.println("<div class='container mt-5'><div class='alert alert-danger'>Terjadi kesalahan: " + e.getMessage() + "</div></div>");
  } finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
  }
%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>