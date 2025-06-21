<%-- File: transaksi.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale, java.util.ArrayList, java.util.List, java.sql.Timestamp, java.text.SimpleDateFormat" %>
<%
    // Pengecekan login admin dilakukan di halaman utama ini.
    String adminUserName = (session != null) ? (String) session.getAttribute("user") : null;
    if (adminUserName == null) {
        response.sendRedirect("login.html");
        return;
    }
%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Daftar Invoice - Admin</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: white; padding-top: 80px; }
        .content { padding: 20px 30px; max-width: 1200px; margin: auto; }
        .card { border: none; border-radius: 18px; box-shadow: 0 2px 12px rgba(0,0,0,0.07); }
        .table { border-radius: 12px; overflow: hidden; vertical-align: middle; }
        .table thead { background-color: #f8f9fa; }
        .status-badge { padding: 6px 12px; border-radius: 20px; font-weight: 500; font-size: 0.85rem; display: inline-block; text-align: center; }
        .status-menunggu { background-color: #fff3cd; color: #856404; }
        .status-dibayar { background-color: #d4edda; color: #155724; }
        .status-dikirim { background-color: #cce5ff; color: #004085; }
        .status-selesai { background-color: #d1e7dd; color: #0f5132; }
        .status-batal { background-color: #f8d7da; color: #721c24; }
        .btn-detail { background: #00bcd4; border-color: #00bcd4; color: white; }
        .btn-detail:hover { background: #0097a7; border-color: #0097a7; color: white; }
        .address-cell, .session-id-cell { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .search-form { background: white; border-radius: 12px; padding: 15px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
    </style>
</head>
<body>

<%-- Memanggil navbar khusus admin --%>
<jsp:include page="navbar.jsp" />

<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-receipt"></i> Daftar Invoice</h2>
        <a href="admin.jsp" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Kembali</a>
    </div>

    <div class="search-form mb-4">
        <form action="transaksi.jsp" method="get" class="row align-items-end g-2">
            <div class="col-md-3">
                <label for="search-session" class="form-label">No. Pesanan / Session ID</label>
                <input type="text" class="form-control" id="search-session" name="search_query" placeholder="Cari No. Pesanan atau Session..."
                       value="<%= request.getParameter("search_query") != null ? request.getParameter("search_query") : "" %>">
            </div>
            <div class="col-md-3">
                <label for="search-status" class="form-label">Status</label>
                <select class="form-select" id="search-status" name="status">
                    <option value="">Semua Status</option>
                    <option value="menunggu" <%= "menunggu".equals(request.getParameter("status")) ? "selected" : "" %>>Menunggu</option>
                    <option value="dibayar" <%= "dibayar".equals(request.getParameter("status")) ? "selected" : "" %>>Dibayar</option>
                    <option value="dikirim" <%= "dikirim".equals(request.getParameter("status")) ? "selected" : "" %>>Dikirim</option>
                    <option value="selesai" <%= "selesai".equals(request.getParameter("status")) ? "selected" : "" %>>Selesai</option>
                    <option value="batal" <%= "batal".equals(request.getParameter("status")) ? "selected" : "" %>>Batal</option>
                </select>
            </div>
            <div class="col-md-4">
                <div class="d-flex">
                    <button type="submit" class="btn btn-primary me-2"><i class="bi bi-search"></i> Cari</button>
                    <a href="transaksi.jsp" class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i> Reset</a>
                </div>
            </div>
        </form>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>No. Pesanan</th>
                            <th>Session ID</th>
                            <th>Nama Penerima</th>
                            <th>Total</th>
                            <th>Tanggal</th>
                            <th>Status</th>
                            <th class="text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
                                
                                StringBuilder sql = new StringBuilder("SELECT * FROM invoice WHERE 1=1");
                                List<String> params = new ArrayList<>();
                                
                                if (request.getParameter("search_query") != null && !request.getParameter("search_query").isEmpty()) {
                                    sql.append(" AND (nomor_invoice LIKE ? OR session_id LIKE ?)");
                                    params.add("%" + request.getParameter("search_query") + "%");
                                    params.add("%" + request.getParameter("search_query") + "%");
                                }
                                
                                if (request.getParameter("status") != null && !request.getParameter("status").isEmpty()) {
                                    sql.append(" AND status = ?");
                                    params.add(request.getParameter("status"));
                                }
                                
                                sql.append(" ORDER BY tanggal DESC");
                                
                                PreparedStatement ps = conn.prepareStatement(sql.toString());
                                for(int i=0; i < params.size(); i++) {
                                    ps.setString(i+1, params.get(i));
                                }
                                
                                ResultSet rs = ps.executeQuery();
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                        %>
                        <tr>
                            <td><strong><%= rs.getString("nomor_invoice") %></strong></td>
                            <td class="session-id-cell" title="<%= rs.getString("session_id") %>"><%= rs.getString("session_id") %></td>
                            <td><%= rs.getString("nama_penerima") %></td>
                            <td>Rp <%= NumberFormat.getNumberInstance(new Locale("id", "ID")).format(rs.getInt("total")) %></td>
                            <td><%= new SimpleDateFormat("dd-MM-yyyy HH:mm").format(rs.getTimestamp("tanggal")) %></td>
                            <td>
                                <span class="status-badge status-<%= rs.getString("status") %>"><%= rs.getString("status").toUpperCase() %></span>
                            </td>
                            <td class="text-center">
                                <a href="detail-invoice-admin.jsp?id=<%= rs.getInt("id") %>" class="btn btn-detail btn-sm">
                                    <i class="bi bi-eye"></i> Detail
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                if (!hasData) {
                                    out.println("<tr><td colspan='7' class='text-center py-4'>Tidak ada data invoice yang ditemukan.</td></tr>");
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7' class='text-danger'>Gagal mengambil data: " + e.getMessage() + "</td></tr>");
                                e.printStackTrace();
                            } finally {
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
    
</body>
</html>