<%@ page import="java.sql.*" %>

<%
    String host = "localhost";
    String db = "nugas_db";
    String user = "root";
    String pass = "";

    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://" + host + ":3306/" + db + "?useSSL=false&serverTimezone=UTC";
        conn = DriverManager.getConnection(url, user, pass);
    } catch (Exception e) {
        out.println("Koneksi gagal: " + e.getMessage());
    }
%>
