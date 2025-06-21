<%@ page import="java.sql.*, java.io.*, jakarta.servlet.http.Part" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Koneksi database
  Connection conn = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
  } catch (Exception e) {
    out.println("Connection Error: " + e.getMessage());
  }

  request.setCharacterEncoding("UTF-8");
  String idStr = request.getParameter("id");
  String nama = request.getParameter("nama");
  String deskripsi = request.getParameter("deskripsi");
  String harga = request.getParameter("harga");
  String stok = request.getParameter("stok");
  Part filePart = request.getPart("gambar");
  String fileName = null;
  boolean fileUploaded = false;

  if (idStr != null && !idStr.trim().isEmpty()) {
    int id = Integer.parseInt(idStr);

    try {
      if (filePart != null && filePart.getSize() > 0) {
        fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();

        // Path absolute di komputer Anda
        String absoluteUploadPath = "C:/Users/Pongo/Documents/Belajar/eve/web/uploads";

        // Path deployment aplikasi
        String deploymentPath = application.getRealPath("/uploads");

        // Buat folder jika belum ada
        File absoluteUploadDir = new File(absoluteUploadPath);
        if (!absoluteUploadDir.exists()) absoluteUploadDir.mkdirs();

        File deploymentUploadDir = new File(deploymentPath);
        if (!deploymentUploadDir.exists()) deploymentUploadDir.mkdirs();

        // Simpan file ke absolute path
        File absoluteFile = new File(absoluteUploadPath, fileName);
        try (InputStream input = filePart.getInputStream();
             FileOutputStream fos = new FileOutputStream(absoluteFile)) {
          byte[] buffer = new byte[1024];
          int bytesRead;
          while ((bytesRead = input.read(buffer)) != -1) {
            fos.write(buffer, 0, bytesRead);
          }
        }

        // Simpan file ke deployment path
        File deploymentFile = new File(deploymentPath, fileName);
        try (InputStream input2 = new FileInputStream(absoluteFile);
             FileOutputStream fos2 = new FileOutputStream(deploymentFile)) {
          byte[] buffer = new byte[1024];
          int bytesRead;
          while ((bytesRead = input2.read(buffer)) != -1) {
            fos2.write(buffer, 0, bytesRead);
          }
        }

        fileUploaded = true;
      }

      // Update data barang
      String sql;
      PreparedStatement ps;

      if (fileUploaded) {
        // Update termasuk gambar baru
        sql = "UPDATE barang SET nama=?, deskripsi=?, harga=?, stok=?, gambar=? WHERE id=?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, nama);
        ps.setString(2, deskripsi);
        ps.setInt(3, Integer.parseInt(harga));
        ps.setInt(4, Integer.parseInt(stok));
        ps.setString(5, fileName);
        ps.setInt(6, id);
      } else {
        // Update tanpa mengubah gambar
        sql = "UPDATE barang SET nama=?, deskripsi=?, harga=?, stok=? WHERE id=?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, nama);
        ps.setString(2, deskripsi);
        ps.setInt(3, Integer.parseInt(harga));
        ps.setInt(4, Integer.parseInt(stok));
        ps.setInt(5, id);
      }

      int rowsUpdated = ps.executeUpdate();
      ps.close();

      if (rowsUpdated > 0) {
        out.println("<script>alert('Data barang berhasil diupdate!');</script>");
      } else {
        out.println("<script>alert('Gagal mengupdate data barang.');</script>");
      }

    } catch (Exception e) {
      out.println("Error saat update barang: " + e.getMessage());
      e.printStackTrace();
    }
  } else {
    out.println("ID barang tidak valid.");
  }

  response.sendRedirect("data-barang.jsp");
%>
