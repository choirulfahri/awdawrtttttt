<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head >
    <title>Registrasi</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card shadow">
        <div class="card-body">

<%
    String nama = request.getParameter("nama");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String message = "";

    String hashedPassword = "";
    try {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) {
            sb.append(String.format("%02x", b));
        }
        hashedPassword = sb.toString();
    } catch (NoSuchAlgorithmException e) {
        message = "Gagal enkripsi password: " + e.getMessage();
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String dbURL = "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        conn = DriverManager.getConnection(dbURL, "root", "");

        String sql = "INSERT INTO users (nama, email, password) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, nama);
        pstmt.setString(2, email);
        pstmt.setString(3, hashedPassword);

        int result = pstmt.executeUpdate();
        if (result > 0) {
            message = "<div class='alert alert-success'>Registrasi berhasil! Data telah disimpan.</div>";
        } else {
            message = "<div class='alert alert-warning'>Registrasi gagal. Silakan coba lagi.</div>";
        }
    } catch (Exception e) {
        message = "<div class='alert alert-danger'>Terjadi kesalahan: " + e.getMessage() + "</div>";
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }

    out.print(message);
%>

            <a href="login.html" class="btn btn-primary mt-3">Kembali ke Form</a>
        </div>
    </div>
</div>
<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
