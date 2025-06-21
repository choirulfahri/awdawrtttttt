<%@ page import="java.sql.*, java.io.*, jakarta.servlet.http.Part" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Koneksi database langsung dalam file
  Connection conn = null;
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
  } catch (Exception e) {
    out.println("Connection Error: " + e.getMessage());
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  String nama = request.getParameter("nama");
  String deskripsi = request.getParameter("deskripsi");
  String harga = request.getParameter("harga");
  String stok = request.getParameter("stok");
  Part filePart = request.getPart("gambar");
  String fileName = null;

  if (filePart != null && filePart.getSize() > 0) {
    fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();

    // PATH ABSOLUTE - Simpan gambar ke lokasi yang tetap dan bisa dilihat langsung
    String absoluteUploadPath = "C:/Users/Pongo/Downloads/Program/Belajar/eve/web/uploads";
    
    // Path untuk deployment (tetap dibutuhkan agar aplikasi bisa menampilkan gambar)
    String deploymentPath = application.getRealPath("/uploads");
    
    // Debug info - tampilkan lokasi penyimpanan
    System.out.println("Saving to absolute path: " + absoluteUploadPath);
    System.out.println("Deployment path: " + deploymentPath);
    
    // Buat folder jika belum ada
    File absoluteUploadDir = new File(absoluteUploadPath);
    File deploymentUploadDir = new File(deploymentPath);
    
    if (!absoluteUploadDir.exists()) absoluteUploadDir.mkdirs();
    if (!deploymentUploadDir.exists()) deploymentUploadDir.mkdirs();

    try (InputStream input = filePart.getInputStream()) {
      // Simpan ke path absolute
      File absoluteFile = new File(absoluteUploadPath, fileName);
      try (FileOutputStream absoluteFos = new FileOutputStream(absoluteFile)) {
        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = input.read(buffer)) != -1) {
          absoluteFos.write(buffer, 0, bytesRead);
        }
      }
      
      // Simpan juga ke path deployment
      input.reset(); // Reset stream untuk dibaca ulang
      if (input.markSupported()) {
        input.reset();
        File deploymentFile = new File(deploymentPath, fileName);
        try (FileOutputStream deploymentFos = new FileOutputStream(deploymentFile)) {
          byte[] buffer = new byte[1024];
          int bytesRead;
          while ((bytesRead = input.read(buffer)) != -1) {
            deploymentFos.write(buffer, 0, bytesRead);
          }
        }
      } else {
        // Jika input stream tidak bisa di-reset, salin file dari absolute ke deployment
        try (FileInputStream fis = new FileInputStream(absoluteFile);
             FileOutputStream deploymentFos = new FileOutputStream(new File(deploymentPath, fileName))) {
          byte[] buffer = new byte[1024];
          int bytesRead;
          while ((bytesRead = fis.read(buffer)) != -1) {
            deploymentFos.write(buffer, 0, bytesRead);
          }
        }
      }
    } catch(Exception e) {
      System.out.println("Upload error: " + e.getMessage());
      e.printStackTrace();
    }
  }

  if (nama != null && deskripsi != null && harga != null && stok != null && fileName != null) {
    try {
      String sql = "INSERT INTO barang (nama, deskripsi, harga, stok, gambar) VALUES (?, ?, ?, ?, ?)";
      PreparedStatement ps = conn.prepareStatement(sql);
      ps.setString(1, nama);
      ps.setString(2, deskripsi);
      ps.setInt(3, Integer.parseInt(harga));
      ps.setInt(4, Integer.parseInt(stok));
      ps.setString(5, fileName);
      ps.executeUpdate();
      ps.close();
    } catch (Exception e) {
      out.println("Gagal menambah barang: " + e.getMessage());
      e.printStackTrace();
    }
  }
  response.sendRedirect("data-barang.jsp");
%>