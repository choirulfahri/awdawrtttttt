<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*" %>
<%
  String userName = (session != null) ? (String) session.getAttribute("user") : null;
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }
  
  String userId = request.getParameter("id");
  if (userId == null || userId.trim().isEmpty()) {
    response.sendRedirect("data-user.jsp?error=id-not-found");
    return;
  }
  
  Connection conn = null;
  PreparedStatement ps = null;
  
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
      "jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", ""
    );
    
    String sql = "DELETE FROM users WHERE id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(userId));
    
    int result = ps.executeUpdate();
    
    if (result > 0) {
      response.sendRedirect("data-user.jsp?status=delete-success");
    } else {
      response.sendRedirect("data-user.jsp?error=delete-failed");
    }
    
  } catch (Exception e) {
    response.sendRedirect("data-user.jsp?error=delete-error&message=" + e.getMessage());
  } finally {
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
  }
%>