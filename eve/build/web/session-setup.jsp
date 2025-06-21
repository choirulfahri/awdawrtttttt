<%
  String idToken = request.getParameter("idToken");
  if (idToken != null && !idToken.isEmpty()) {
      // TANPA VERIFIKASI TOKEN, LANGSUNG SET SESSION (TIDAK AMAN)
      session.setAttribute("user", "user_firebase"); // kamu bisa set email atau uid dari client
      response.setStatus(200);
      out.print("Session dibuat tanpa verifikasi");
  } else {
      response.setStatus(400);
      out.print("Token kosong");
  }
%>
