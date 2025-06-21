<%-- File: update-status-invoice.jsp --%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*" %>
<%
    // 1. Keamanan: Pastikan yang mengakses adalah admin yang sudah login
    String adminUserName = (session != null) ? (String) session.getAttribute("user") : null;
    if (adminUserName == null) {
        response.sendRedirect("login.html");
        return;
    }

    // 2. Ambil parameter dari form
    String invoiceIdStr = request.getParameter("id");
    String newStatus = request.getParameter("status");

    // Validasi parameter
    if (invoiceIdStr == null || newStatus == null || invoiceIdStr.isEmpty() || newStatus.isEmpty()) {
        // Jika parameter tidak lengkap, kembalikan ke halaman transaksi
        response.sendRedirect("transaksi.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    
    try {
        int invoiceId = Integer.parseInt(invoiceIdStr);

        // 3. Hubungkan ke database dan jalankan perintah UPDATE
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

        String sql = "UPDATE invoice SET status = ? WHERE id = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, newStatus);
        ps.setInt(2, invoiceId);

        // Eksekusi update
        int rowsAffected = ps.executeUpdate();
        
        // 4. Redirect kembali ke halaman detail setelah berhasil
        // Dengan menyertakan ID invoice agar kembali ke halaman yang benar
        response.sendRedirect("detail-invoice-admin.jsp?id=" + invoiceId);

    } catch (Exception e) {
        // Jika terjadi error, tampilkan pesan sederhana
        response.setContentType("text/html");
        out.println("<html><body>");
        out.println("<h1>Error Saat Update Status</h1>");
        out.println("<p>Terjadi kesalahan: " + e.getMessage() + "</p>");
        out.println("<a href='transaksi.jsp'>Kembali ke Daftar Transaksi</a>");
        out.println("</body></html>");
        e.printStackTrace();
    } finally {
        // 5. Selalu tutup koneksi
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>