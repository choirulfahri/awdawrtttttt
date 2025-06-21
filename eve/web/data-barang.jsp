<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
  // Koneksi database
  Connection conn = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
  } catch (Exception e) {
    out.println("Connection Error: " + e.getMessage());
  }
%>

<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <title>Data Barang - Dashboard Admin</title>
  <!-- Bootstrap CSS CDN -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
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

<!-- Include Navbar -->
<%@ include file="navbar.jsp" %>


<!-- Main Content -->
<div class="container mt-4">
  <h2>Data Barang</h2>
  <button class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#modalTambahBarang">
    <i class="bi bi-plus-circle"></i> Tambah Barang
  </button>

  <!-- Tabel Data Barang -->
  <table class="table table-striped align-middle">
    <thead class="table-light">
      <tr>
        <th>No</th>
        <th>Gambar</th>
        <th>Nama</th>
        <th>Deskripsi</th>
        <th>Harga</th>
        <th>Stok</th>
        <th>Aksi</th>
      </tr>
    </thead>
    <tbody>
      <%
        int no = 1;
        try {
          Statement st = conn.createStatement();
          ResultSet rs = st.executeQuery("SELECT * FROM barang ORDER BY id DESC");
          while (rs.next()) {
      %>
      <tr>
        <td><%= no++ %></td>
        <td style="width: 100px">
          <% if (rs.getString("gambar") != null && !rs.getString("gambar").isEmpty()) { %>
            <img src="uploads/<%= rs.getString("gambar") %>" class="img-thumbnail" style="width:80px; height:80px; object-fit:cover;">
          <% } else { %>
            <img src="https://via.placeholder.com/80?text=No+Image" class="img-thumbnail" style="width:80px; height:80px; object-fit:cover;">
          <% } %>
        </td>
        <td><%= rs.getString("nama") %></td>
        <td>
          <%= rs.getString("deskripsi").length() > 50 ? rs.getString("deskripsi").substring(0, 50) + "..." : rs.getString("deskripsi") %>
        </td>
        <td>Rp <%= String.format("%,d", rs.getInt("harga")) %></td>
        <td><%= rs.getInt("stok") %></td>
        <td>
          <button 
            class="btn btn-warning btn-sm btn-edit-barang"
            data-id="<%= rs.getInt("id") %>"
            data-nama="<%= rs.getString("nama") %>"
            data-deskripsi="<%= rs.getString("deskripsi") %>"
            data-harga="<%= rs.getInt("harga") %>"
            data-stok="<%= rs.getInt("stok") %>"
            data-bs-toggle="modal"
            data-bs-target="#modalEditBarang"
          >Edit</button>
          <button 
            class="btn btn-danger btn-sm btn-delete-barang"
            data-id="<%= rs.getInt("id") %>"
            data-nama="<%= rs.getString("nama") %>"
            data-bs-toggle="modal"
            data-bs-target="#modalDeleteBarang"
          >Delete</button>
        </td>
      </tr>
      <%
          }
          rs.close();
          st.close();
        } catch (Exception e) {
          out.println("<tr><td colspan='7' class='text-danger'>Gagal mengambil data: " + e.getMessage() + "</td></tr>");
        }
      %>
    </tbody>
  </table>
</div>

<!-- Modal Tambah Barang -->
<div class="modal fade" id="modalTambahBarang" tabindex="-1" aria-labelledby="modalTambahLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="tambah-barang.jsp" method="post" enctype="multipart/form-data" class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalTambahLabel">Tambah Barang Baru</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label for="nama" class="form-label">Nama</label>
          <input type="text" class="form-control" id="nama" name="nama" required />
        </div>
        <div class="mb-3">
          <label for="deskripsi" class="form-label">Deskripsi</label>
          <textarea class="form-control" id="deskripsi" name="deskripsi" rows="3" required></textarea>
        </div>
        <div class="mb-3">
          <label for="harga" class="form-label">Harga</label>
          <input type="number" class="form-control" id="harga" name="harga" required />
        </div>
        <div class="mb-3">
          <label for="stok" class="form-label">Stok</label>
          <input type="number" class="form-control" id="stok" name="stok" required />
        </div>
        <div class="mb-3">
          <label for="gambar" class="form-label">Gambar</label>
          <input type="file" class="form-control" id="gambar" name="gambar" accept="image/*" />
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-success">Tambah</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Edit Barang (Single modal, data diisi dinamis via JS) -->
<div class="modal fade" id="modalEditBarang" tabindex="-1" aria-labelledby="modalEditLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="edit-barang.jsp" method="post" enctype="multipart/form-data" class="modal-content" id="formEditBarang">
      <div class="modal-header">
        <h5 class="modal-title" id="modalEditLabel">Edit Barang</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" name="id" id="edit-id" />
        <div class="mb-3">
          <label for="edit-nama" class="form-label">Nama</label>
          <input type="text" class="form-control" id="edit-nama" name="nama" required />
        </div>
        <div class="mb-3">
          <label for="edit-deskripsi" class="form-label">Deskripsi</label>
          <textarea class="form-control" id="edit-deskripsi" name="deskripsi" rows="3" required></textarea>
        </div>
        <div class="mb-3">
          <label for="edit-harga" class="form-label">Harga</label>
          <input type="number" class="form-control" id="edit-harga" name="harga" required />
        </div>
        <div class="mb-3">
          <label for="edit-stok" class="form-label">Stok</label>
          <input type="number" class="form-control" id="edit-stok" name="stok" required />
        </div>
        <div class="mb-3">
          <label for="edit-gambar" class="form-label">Gambar (upload baru jika ingin ganti)</label>
          <input type="file" class="form-control" id="edit-gambar" name="gambar" accept="image/*" />    
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Delete Barang (Single modal, data diisi dinamis via JS) -->
<div class="modal fade" id="modalDeleteBarang" tabindex="-1" aria-labelledby="modalDeleteLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="delete-barang.jsp" method="get" class="modal-content" id="formDeleteBarang">
      <div class="modal-header">
        <h5 class="modal-title" id="modalDeleteLabel">Hapus Barang</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" name="id" id="delete-id" />
        <p>Apakah Anda yakin ingin menghapus barang <strong id="delete-nama"></strong>?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
        <button type="submit" class="btn btn-danger">Hapus</button>
      </div>
    </form>
  </div>
</div>

<!-- Bootstrap JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- JavaScript untuk mengisi data modal edit dan delete -->
<script>
  document.addEventListener('DOMContentLoaded', function () {
    // Edit button click handler
    const editButtons = document.querySelectorAll('.btn-edit-barang');
    editButtons.forEach(button => {
      button.addEventListener('click', function () {
        const id = this.getAttribute('data-id');
        const nama = this.getAttribute('data-nama');
        const deskripsi = this.getAttribute('data-deskripsi');
        const harga = this.getAttribute('data-harga');
        const stok = this.getAttribute('data-stok');

        document.getElementById('edit-id').value = id;
        document.getElementById('edit-nama').value = nama;
        document.getElementById('edit-deskripsi').value = deskripsi;
        document.getElementById('edit-harga').value = harga;
        document.getElementById('edit-stok').value = stok;
        // Clear file input
        document.getElementById('edit-gambar').value = '';
      });
    });

    // Delete button click handler
    const deleteButtons = document.querySelectorAll('.btn-delete-barang');
    deleteButtons.forEach(button => {
      button.addEventListener('click', function () {
        const id = this.getAttribute('data-id');
        const nama = this.getAttribute('data-nama');

        document.getElementById('delete-id').value = id;
        document.getElementById('delete-nama').textContent = nama;
      });
    });
  });
</script>

</body>
</html>
