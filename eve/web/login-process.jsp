<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>

<%! 
  // Fungsi untuk hash password ke SHA-256
  public String hashPassword(String password) throws Exception {
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    byte[] hash = md.digest(password.getBytes("UTF-8"));
    StringBuilder sb = new StringBuilder();
    for (byte b : hash) {
      sb.append(String.format("%02x", b));
    }
    return sb.toString();
  }
%>

<%
  String email = request.getParameter("email");
  String password = request.getParameter("password");
  String hashedPassword = "";

  try {
    hashedPassword = hashPassword(password); // ? Enkripsi sebelum cocokkan
  } catch (Exception e) {
    out.println("Gagal enkripsi password: " + e.getMessage());
    return;
  }

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC",
      "root",
      ""
    );

    PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ?");
    stmt.setString(1, email);
    stmt.setString(2, hashedPassword); // ? cocokkan yang sudah di-hash

    ResultSet rs = stmt.executeQuery();

    if (rs.next()) {
      session.setAttribute("user", rs.getString("nama"));
      String role = rs.getString("role");
      if ("admin".equalsIgnoreCase(role)) {
        response.sendRedirect("admin.jsp");
      } else {
        response.sendRedirect("welcome.jsp");
      }
    } else {
      out.println("<script>alert('Login gagal: email atau password salah!'); window.location='login.html';</script>");
    }

    conn.close();
  } catch (Exception e) {
    out.println("Error: " + e.getMessage());
  }
%>

%>
