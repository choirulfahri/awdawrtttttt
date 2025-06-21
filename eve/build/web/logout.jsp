<%@ page import="jakarta.servlet.http.*" %>
<%
  if (session != null) {
    session.invalidate(); // ? hapus semua data session
  }
  response.sendRedirect("login.html");
%>
