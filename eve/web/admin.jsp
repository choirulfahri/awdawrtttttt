<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%
  String userName = (String) session.getAttribute("user");
  if (userName == null) {
    response.sendRedirect("login.html");
    return;
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Dashboard Admin - TokoKita</title>
  <link rel="stylesheet" href="css/bootstrap.min.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
  <style>
    body {
      background: white;
      padding-top: 70px;
    }
    .navbar {
      box-shadow: 0 2px 12px rgba(0,188,212,0.07);
      background: #fff;
    }
    .navbar .nav-link, .navbar .dropdown-toggle {
      color: #212529 !important;
      font-weight: 500;
      margin-right: 10px;
    }
    .navbar .nav-link.active, .navbar .nav-link:hover {
      color: #00bcd4 !important;
    }
    .navbar-brand {
      font-weight: bold;
      font-size: 1.5rem;
      letter-spacing: 1px;
      color: #00bcd4 !important;
    }
    .content {
      padding: 20px 30px;
      max-width: 1200px;
      margin: auto;
    }
    .welcome-card {
      border-radius: 18px;
      background: linear-gradient(120deg, #e0f7fa 60%, #fff 100%);
      box-shadow: 0 2px 12px rgba(0,188,212,0.09);
      border: none;
      margin-bottom: 30px;
    }
    .card {
      border: none;
      border-radius: 18px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
    }
    .stat-card {
      transition: transform 0.2s;
      cursor: default;
      position: relative;
    }
    .stat-card:hover {
      transform: translateY(-5px);
    }
    .stat-card i {
      font-size: 2.5rem;
      opacity: 0.2;
      position: absolute;
      right: 20px;
      top: 50%;
      transform: translateY(-50%);
    }
    @media (max-width: 900px) {
      .content {
        padding: 15px;
      }
    }
  </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="content">
  <!-- Welcome Card -->
<h1 class="text-primary mb-3"><i class="bi bi-person-circle me-2"></i>Selamat Datang Admin, <%= userName %>!</h1>


<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>