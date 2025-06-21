<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*, jakarta.servlet.*" %>
<%
  // Cek session user
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }

  // Koneksi database
  String jdbcURL = "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC";
  String dbUser = "root";
  String dbPass = "";

  Connection conn = null;
  Statement stmt = null;
  ResultSet rs = null;

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(jdbcURL, dbUser, dbPass);
    stmt = conn.createStatement();
    rs = stmt.executeQuery("SELECT id, nama, email, role FROM users");
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Data Pengguna - TokoKita</title>
  <link rel="stylesheet" href="css/bootstrap.min.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
  <style>
    body {
      background: white;
      padding-top: 70px;
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
    .navbar-brand {
      font-weight: bold;
      font-size: 1.5rem;
      letter-spacing: 1px;
      color: #00bcd4 !important;
    }
    .content {
      padding: 20px 30px;
      max-width: 1200px;
      margin: auto;
    }
    .welcome-card {
      border-radius: 18px;
      background: linear-gradient(120deg, #e0f7fa 60%, #fff 100%);
      box-shadow: 0 2px 12px rgba(0,188,212,0.09);
      border: none;
      margin-bottom: 30px;
    }
    .card {
      border: none;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
    }
    .stat-card {
      transition: transform 0.2s;
      cursor: default;
      position: relative;
    }
    .stat-card:hover {
      transform: translateY(-5px);
    }
    .stat-card i {
      font-size: 2.5rem;
      opacity: 0.2;
      position: absolute;
      right: 20px;
      top: 50%;
      transform: translateY(-50%);
    }
    @media (max-width: 900px) {
      .content {
        padding: 15px;
      }
    }
  </style>
</head>
<body>
  <jsp:include page="navbar.jsp" />
  <div class="container mt-5 pt-4">
    <h2>Punya Customer</h2>
    <table class="table table-striped table-hover mt-3">
      <thead class="table-primary">
        <tr>
          <th>ID</th>
          <th>Username</th>
          <th>Email</th>
          <th>Role</th>
          <th>Aksi</th>
        </tr>
      </thead>
      <tbody>
        <%
          while (rs.next()) {
            int id = rs.getInt("id");
            String nama = rs.getString("nama");
            String email = rs.getString("email");
            String role = rs.getString("role");
        %>
        <tr>
          <td><%= id %></td>
          <td><%= nama %></td>
          <td><%= email %></td>
          <td><%= role %></td>
          <td>
            <!-- Tombol Edit -->
            <button 
              type="button" 
              class="btn btn-sm btn-warning" 
              data-bs-toggle="modal" 
              data-bs-target="#editUserModal"
              data-id="<%= id %>"
              data-nama="<%= nama %>"
              data-email="<%= email %>"
              data-role="<%= role %>"
            >
              <i class="bi bi-pencil-square"></i> Edit
            </button>

            <!-- Tombol Delete -->
            <button 
              type="button" 
              class="btn btn-sm btn-danger" 
              data-bs-toggle="modal" 
              data-bs-target="#deleteUserModal"
              data-id="<%= id %>"
              data-nama="<%= nama %>"
            >
              <i class="bi bi-trash"></i> Delete
            </button>
          </td>
        </tr>
        <%
          }
        %>
      </tbody>
    </table>
  </div>

  <!-- Modal Edit User -->
<div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="update-user.jsp" method="post" id="editUserForm" class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="editUserModalLabel">Edit Data Pengguna</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" name="id" id="editUserId" />
        <div class="mb-3">
          <label for="editUserNama" class="form-label">Nama</label>
          <input type="text" class="form-control" id="editUserNama" name="nama" required />
        </div>
        <div class="mb-3">
          <label for="editUserEmail" class="form-label">Email</label>
          <input type="email" class="form-control" id="editUserEmail" name="email" required />
        </div>
        <div class="mb-3">
          <label for="editUserRole" class="form-label">Role</label>
          <select class="form-select" id="editUserRole" name="role" required>
            <option value="admin">Admin</option>
            <option value="user">User</option>
            <!-- Tambahkan role lain jika ada -->
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
      </div>
    </form>
  </div>
</div>

  <!-- Modal Delete User -->
  <div class="modal fade" id="deleteUserModal" tabindex="-1" aria-labelledby="deleteUserModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <form action="delete-user.jsp" method="get" id="deleteUserForm" class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="deleteUserModalLabel">Konfirmasi Hapus Pengguna</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" name="id" id="deleteUserId" />
          <p>Apakah Anda yakin ingin menghapus pengguna <strong id="deleteUserName"></strong>?</p>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
          <button type="submit" class="btn btn-danger">Hapus</button>
        </div>
      </form>
    </div>
  </div>

  <script src="js/bootstrap.bundle.min.js"></script>
  <script>
    var editUserModal = document.getElementById('editUserModal');
  editUserModal.addEventListener('show.bs.modal', function (event) {
    var button = event.relatedTarget;
    var id = button.getAttribute('data-id');
    var nama = button.getAttribute('data-nama');
    var email = button.getAttribute('data-email');
    var role = button.getAttribute('data-role');

    document.getElementById('editUserId').value = id;
    document.getElementById('editUserNama').value = nama;
    document.getElementById('editUserEmail').value = email;
    document.getElementById('editUserRole').value = role; // Pastikan ini sesuai dengan opsi dropdown
  });

    // Event listener untuk modal delete user
    var deleteUserModal = document.getElementById('deleteUserModal');
    deleteUserModal.addEventListener('show.bs.modal', function (event) {
      var button = event.relatedTarget;
      var id = button.getAttribute('data-id');
      var nama = button.getAttribute('data-nama');

      document.getElementById('deleteUserId').value = id;
      document.getElementById('deleteUserName').textContent = nama;
    });
  </script>
</body>
</html>
<%
  } catch (Exception e) {
    out.println("Error: " + e.getMessage());
  } finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (stmt != null) try { stmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
  }
%>
