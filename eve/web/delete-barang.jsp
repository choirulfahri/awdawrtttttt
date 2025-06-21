<%@ page import="java.sql.*, java.io.*" %>
<%
String id = request.getParameter("id");
Connection conn = null;
PreparedStatement ps = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");

    // (Opsional) Hapus file gambar jika ingin
    String gambar = null;
    PreparedStatement psGet = conn.prepareStatement("SELECT gambar FROM barang WHERE id=?");
    psGet.setString(1, id);
    ResultSet rs = psGet.executeQuery();
    if (rs.next()) {
        gambar = rs.getString("gambar");
    }
    rs.close();
    psGet.close();

    String sql = "DELETE FROM barang WHERE id=?";
    ps = conn.prepareStatement(sql);
    ps.setString(1, id);
    int result = ps.executeUpdate();

    // Hapus file gambar jika ada
    if (gambar != null && !gambar.isEmpty()) {
        String filePath = application.getRealPath("") + File.separator + gambar;
        File file = new File(filePath);
        if (file.exists()) file.delete();
    }

    if (result > 0) {
        response.sendRedirect("data-barang.jsp?msg=delete-success");
    } else {
        response.sendRedirect("data-barang.jsp?msg=delete-failed");
    }
} catch (Exception e) {
    out.println("Error: " + e.getMessage());
} finally {
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>