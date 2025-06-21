<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*, java.util.*" %>
<%
    // 1. Dapatkan email pengguna dari sesi
    String userEmail = (session != null) ? (String) session.getAttribute("user") : null;
    if (userEmail == null) {
        response.sendRedirect("login.html");
        return;
    }

    // 2. Ambil data dari form pembayaran
    request.setCharacterEncoding("UTF-8");
    String namaPenerima = request.getParameter("nama_penerima");
    String alamat = request.getParameter("alamat");
    String metode = request.getParameter("metode");

    // 3. Ambil data keranjang dari session (lebih aman daripada dari form)
    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("keranjang.jsp?error=" + java.net.URLEncoder.encode("Keranjang belanja Anda kosong.", "UTF-8"));
        return;
    }

    Connection conn = null;
    int userId = -1;
    int total = 0;
    List<Map<String, Object>> itemsToInsert = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/nugas_db?useSSL=false&serverTimezone=UTC", "root", "");
        conn.setAutoCommit(false); // Mulai mode transaksi

        // 4. Dapatkan ID pengguna dari database
        PreparedStatement psUser = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
        psUser.setString(1, userEmail);
        ResultSet rsUser = psUser.executeQuery();
        if (rsUser.next()) {
            userId = rsUser.getInt("id");
        } else {
            throw new Exception("User tidak ditemukan.");
        }

        // 5. Validasi stok dan siapkan data barang dari database
        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            PreparedStatement psBarang = conn.prepareStatement("SELECT * FROM barang WHERE id = ?");
            psBarang.setInt(1, entry.getKey());
            ResultSet rsBarang = psBarang.executeQuery();
            if (rsBarang.next()) {
                int stokTersedia = rsBarang.getInt("stok");
                int qtyDiminta = entry.getValue();

                // Pengecekan stok ditambahkan di sini
                if (stokTersedia < qtyDiminta) {
                    throw new Exception("Stok untuk barang '" + rsBarang.getString("nama") + "' tidak mencukupi.");
                }

                Map<String, Object> item = new HashMap<>();
                int harga = rsBarang.getInt("harga");
                int subtotal = harga * qtyDiminta;

                item.put("id", rsBarang.getInt("id"));
                item.put("nama", rsBarang.getString("nama"));
                item.put("harga", harga);
                item.put("qty", qtyDiminta);
                item.put("subtotal", subtotal);

                itemsToInsert.add(item);
                total += subtotal;
            } else {
                 throw new Exception("Barang dengan ID " + entry.getKey() + " tidak ditemukan.");
            }
        }

        // 6. Simpan ke tabel `invoice`
        PreparedStatement psInvoice = conn.prepareStatement(
            "INSERT INTO invoice (user, nama_penerima, alamat, metode, total, status) VALUES (?, ?, ?, ?, ?, 'pending')",
            Statement.RETURN_GENERATED_KEYS
        );
        psInvoice.setInt(1, userId);
        psInvoice.setString(2, namaPenerima);
        psInvoice.setString(3, alamat);
        psInvoice.setString(4, metode);
        psInvoice.setInt(5, total);
        psInvoice.executeUpdate();

        ResultSet generatedKeys = psInvoice.getGeneratedKeys();
        int invoiceId;
        if (generatedKeys.next()) {
            invoiceId = generatedKeys.getInt(1);
        } else {
            throw new SQLException("Gagal membuat invoice, ID tidak didapatkan.");
        }

        // 7. Simpan detail dan kurangi stok
        PreparedStatement psDetail = conn.prepareStatement("INSERT INTO invoice_detail (invoice_id, barang_id, nama_barang, harga, qty, subtotal) VALUES (?, ?, ?, ?, ?, ?)");
        PreparedStatement psUpdateStok = conn.prepareStatement("UPDATE barang SET stok = stok - ? WHERE id = ?");

        for (Map<String, Object> item : itemsToInsert) {
            // Simpan ke invoice_detail
            psDetail.setInt(1, invoiceId);
            psDetail.setInt(2, (Integer) item.get("id"));
            psDetail.setString(3, (String) item.get("nama"));
            psDetail.setInt(4, (Integer) item.get("harga"));
            psDetail.setInt(5, (Integer) item.get("qty"));
            psDetail.setInt(6, (Integer) item.get("subtotal"));
            psDetail.addBatch();
            
            // Siapkan untuk update stok
            psUpdateStok.setInt(1, (Integer) item.get("qty"));
            psUpdateStok.setInt(2, (Integer) item.get("id"));
            psUpdateStok.addBatch();
        }
        psDetail.executeBatch();
        psUpdateStok.executeBatch();

        conn.commit(); // Konfirmasi semua perubahan jika semua query berhasil

        // 8. Kosongkan keranjang dari session
        session.removeAttribute("cart");

        // 9. Arahkan (REDIRECT) ke halaman My Orders
        response.sendRedirect("my_orders.jsp?status=sukses");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {} // Batalkan transaksi jika ada error
        // Redirect kembali ke keranjang dengan pesan error yang jelas
        response.sendRedirect("keranjang.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
