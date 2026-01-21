package controller;

import model.SalesEntry;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/sales-journal")
public class SalesJournalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // --- CẤU HÌNH DATABASE ---
    // Ví dụ: jdbc:mysql://monorail.proxy.rlwy.net:12345/railway
    private String jdbcURL = "mysql://root:twHYzvjfGWtpYPZHVWBcmuzIJTHxUQzS@mysql.railway.internal:3306/railway"; 
    private String jdbcUsername = "root";
    private String jdbcPassword = "";

    @Override
    public void init() {
        try {
            String envUrl = System.getenv("MYSQL_URL");
            if(envUrl != null && !envUrl.isEmpty()) {
                this.jdbcURL = envUrl;
            }
            if (this.jdbcURL.startsWith("mysql://")) {
                this.jdbcURL = this.jdbcURL.replace("mysql://", "jdbc:mysql://");
            }
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
                 Statement stmt = conn.createStatement()) {
                String sql = "CREATE TABLE IF NOT EXISTS sales (" +
                             "id INT AUTO_INCREMENT PRIMARY KEY, " +
                             "entry_date DATE, " +
                             "customer_name VARCHAR(255), " +
                             "description VARCHAR(255), " +
                             "quantity INT, " +
                             "price DOUBLE)";
                stmt.executeUpdate(sql);
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        // 1. XÓA
        if ("delete".equals(action)) {
            try {
                String idStr = req.getParameter("id");
                if (idStr != null && !idStr.isEmpty()) {
                    int id = Integer.parseInt(idStr);
                    try (Connection conn = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
                         PreparedStatement ps = conn.prepareStatement("DELETE FROM sales WHERE id = ?")) {
                        ps.setInt(1, id);
                        ps.executeUpdate();
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }
            
            // Xóa xong quay về đúng Tab
            String fromTab = req.getParameter("tab"); 
            String redirectUrl = "sales-journal";
            if("report".equals(fromTab)) redirectUrl += "?tab=report";
            
            resp.setContentType("text/html; charset=UTF-8");
            resp.getWriter().println("<script>window.location.href='" + redirectUrl + "';</script>");
            return;
        }

        // 2. XUẤT EXCEL
        if ("exportDaily".equals(action)) {
            exportDailyExcel(resp, getSalesFromDB());
            return;
        }
        if ("export".equals(action)) {
            exportS2aExcel(resp, getSalesFromDB());
            return;
        }

        // 3. HIỂN THỊ
        List<SalesEntry> list = getSalesFromDB();
        req.setAttribute("dailyList", list);
        
        // Tính toán S2a
        Map<String, Double> s2aMap = new TreeMap<>(Collections.reverseOrder());
        for(SalesEntry e : list) {
            if(e.getEntryDate() != null) {
                s2aMap.put(e.getEntryDate(), s2aMap.getOrDefault(e.getEntryDate(), 0.0) + e.getRevenue());
            }
        }
        List<SalesEntry> s2aList = new ArrayList<>();
        for(Map.Entry<String,Double> en : s2aMap.entrySet()) {
            s2aList.add(new SalesEntry(en.getKey(), "Doanh thu ngày " + en.getKey(), en.getValue()));
        }
        req.setAttribute("s2aList", s2aList);
        
        req.getRequestDispatcher("s2a_hkd.jsp").forward(req, resp);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String origin = req.getParameter("origin"); // Nhận diện xem đang sửa ở Tab nào

        try (Connection conn = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword)) {
            String date = req.getParameter("entryDate");
            String cust = req.getParameter("customerName");
            String desc = req.getParameter("description");
            int qty = Integer.parseInt(req.getParameter("quantity"));
            double price = Double.parseDouble(req.getParameter("price"));

            if("add".equals(action)) {
                String sql = "INSERT INTO sales (entry_date, customer_name, description, quantity, price) VALUES (?, ?, ?, ?, ?)";
                try(PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, date); ps.setString(2, cust); ps.setString(3, desc); ps.setInt(4, qty); ps.setDouble(5, price);
                    ps.executeUpdate();
                }
            } else if("update".equals(action)) {
                 int id = Integer.parseInt(req.getParameter("id"));
                 String sql = "UPDATE sales SET entry_date=?, customer_name=?, description=?, quantity=?, price=? WHERE id=?";
                 try(PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, date); ps.setString(2, cust); ps.setString(3, desc); ps.setInt(4, qty); ps.setDouble(5, price); ps.setInt(6, id);
                    ps.executeUpdate();
                 }
            }
        } catch(Exception e){ e.printStackTrace(); }
        
        // Điều hướng về đúng Tab sau khi Lưu
        String redirectUrl = "sales-journal";
        if("report".equals(origin)) {
            redirectUrl += "?tab=report"; // Nếu sửa từ Tab Báo cáo, thêm đuôi để mở lại Tab đó
        }
        
        resp.setContentType("text/html; charset=UTF-8");
        resp.getWriter().println("<script>window.location.href='" + redirectUrl + "';</script>");
    }

    // --- CÁC HÀM PHỤ TRỢ ---

    private List<SalesEntry> getSalesFromDB() {
        List<SalesEntry> list = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM sales ORDER BY entry_date DESC")) { // Web: Mới nhất lên đầu
            while (rs.next()) {
                list.add(new SalesEntry(
                    rs.getInt("id"),
                    rs.getString("entry_date"),
                    rs.getString("customer_name"),
                    rs.getString("description"),
                    rs.getInt("quantity"),
                    rs.getDouble("price")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Xuất Excel Nhật Ký (Đã sửa lỗi ngày tháng bị ngược)
    private void exportDailyExcel(HttpServletResponse resp, List<SalesEntry> list) throws IOException {
        // QUAN TRỌNG: Sắp xếp lại danh sách theo thứ tự Ngày Cũ -> Ngày Mới
        Collections.sort(list, Comparator.comparing(SalesEntry::getEntryDate));

        resp.setContentType("application/vnd.ms-excel; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=So_Ban_Hang_TapHoaSoan.xls");
        PrintWriter out = resp.getWriter();
        out.write('\ufeff');

        out.println("<html><head><meta charset='UTF-8'><style>");
        out.println("body { font-family: 'Times New Roman', serif; font-size: 12pt; }");
        out.println(".header-left { font-weight: bold; font-size: 14pt; }");
        out.println(".header-title { font-weight: bold; font-size: 16pt; text-align: center; }");
        out.println("table { width: 100%; border-collapse: collapse; }");
        out.println(".tbl-data td, .tbl-data th { border: 1px solid black; padding: 5px; }");
        out.println("</style></head><body>");

        out.println("<table border='0'><tr>");
        out.println("<td colspan='3' class='header-left'>Tạp hoá Soạn</td>");
        out.println("<td colspan='4' class='header-title'>SỔ BÁN HÀNG ( Năm 2026)</td>");
        out.println("</tr><tr><td colspan='7'>&nbsp;</td></tr></table>");

        out.println("<table class='tbl-data'>");
        out.println("<tr style='background-color:#f0f0f0; text-align:center; font-weight:bold;'>");
        out.println("<th>Ngày tháng</th><th>Khách hàng</th><th>Sản Phẩm</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th><th>Ghi chú</th></tr>");

        double totalAll = 0;
        if (list != null) {
            for (SalesEntry e : list) {
                String vnDate = e.getEntryDate();
                try { String[] p = vnDate.split("-"); vnDate = p[2] + "/" + p[1] + "/" + p[0]; } catch (Exception ex) {}
                out.println("<tr>");
                out.println("<td align='center'>" + vnDate + "</td>");
                out.println("<td>" + (e.getCustomerName() == null ? "" : e.getCustomerName()) + "</td>");
                out.println("<td>" + e.getDescription() + "</td>");
                out.println("<td align='center'>" + e.getQuantity() + "</td>");
                out.println("<td align='right'>" + String.format("%,.0f", e.getPrice()) + "</td>");
                out.println("<td align='right'>" + String.format("%,.0f", e.getRevenue()) + "</td>");
                out.println("<td></td>");
                out.println("</tr>");
                totalAll += e.getRevenue();
            }
        }
        out.println("<tr style='font-weight:bold; background-color:#eaeaea;'><td colspan='5' align='center'>TỔNG CỘNG</td><td align='right'>" + String.format("%,.0f", totalAll) + "</td><td></td></tr>");
        out.println("</table></body></html>");
    }

    private void exportS2aExcel(HttpServletResponse resp, List<SalesEntry> list) throws IOException {
        // Sắp xếp lại danh sách S2a theo thứ tự Cũ -> Mới luôn cho chuẩn
        Collections.sort(list, Comparator.comparing(SalesEntry::getEntryDate));
        
        resp.setContentType("application/vnd.ms-excel; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=S2a_HKD_PhanThiSoan.xls");
        PrintWriter out = resp.getWriter();
        out.write('\ufeff');

        Map<String, Double> s2aMap = new TreeMap<>(); // TreeMap tự động sắp xếp ngày tăng dần
        double totalRevenue = 0;
        if (list != null) {
            for (SalesEntry e : list) {
                if (e.getEntryDate() != null && !e.getEntryDate().isEmpty()) {
                    s2aMap.put(e.getEntryDate(), s2aMap.getOrDefault(e.getEntryDate(), 0.0) + e.getRevenue());
                    totalRevenue += e.getRevenue();
                }
            }
        }

        // ... (Giữ nguyên phần vẽ form S2a của bạn ở đây để tiết kiệm dòng lệnh) ...
        // ... (Dán lại phần vẽ HTML S2a cũ vào đây, hoặc dùng code cũ cũng được) ...
        
        out.println("<html><head><meta charset='UTF-8'><style>body{font-family:'Times New Roman'; font-size:12pt;} .title{font-size:16pt; font-weight:bold;} .bold{font-weight:bold;}</style></head><body>");
        out.println("<table border='0' width='100%'>");
        out.println("<tr><td colspan='2' class='bold'>HỘ, CÁ NHÂN KINH DOANH:</td><td></td><td></td></tr>");
        out.println("<tr><td colspan='2'>TẠP HOÁ PHAN THỊ SOẠN</td><td></td><td class='bold'>Mẫu số S2a-HKD</td></tr>");
        out.println("<tr><td colspan='2'>Địa chỉ: tổ 6, thôn Tú Cẩm, xã Thăng Điền, TP.Đà Nẵng</td><td></td><td>(Kèm theo Thông tư số 152/2025/TT-BTC,</td></tr>");
        out.println("<tr><td colspan='2'>Mã số thuế: 049172</td><td></td><td>ngày 31 tháng 12 năm 2025 của ,</td></tr>");
        out.println("<tr><td colspan='2'></td><td></td><td>Bộ trưởng Bộ Tài chính),</td></tr>");
        out.println("<tr><td colspan='4' align='center' class='title'>SỔ DOANH THU BÁN HÀNG HÓA, DỊCH VỤ</td></tr>");
        out.println("<tr><td colspan='2'>Địa điểm kinh doanh: tổ 6, thôn Tú Cẩm, xã Thăng Điền, TP.Đà Nẵng</td><td colspan='2'></td></tr>");
        out.println("<tr><td colspan='2'>Kỳ kê khai: Tháng ... Năm 2026</td><td colspan='2'></td></tr>");
        out.println("<tr><td colspan='3'></td><td align='right'>Đơn vị tính: Đồng Việt Nam</td></tr>");
        out.println("</table>");

        out.println("<table border='1' style='border-collapse:collapse; width:100%; border: 1px solid black;'>");
        out.println("<tr style='background-color:#f0f0f0; text-align:center; font-weight:bold;'><td colspan='2'>Chứng từ</td><td>Diễn giải</td><td>Số tiền</td></tr>");
        out.println("<tr style='background-color:#f0f0f0; text-align:center; font-weight:bold;'><td>Số hiệu</td><td>Ngày, tháng</td><td></td><td></td></tr>");
        out.println("<tr><td></td><td></td><td class='bold'>1. Hoạt động bán buôn, bán lẻ</td><td></td></tr>");

        int stt = 1;
        int rowCount = 0;
        for (Map.Entry<String, Double> entry : s2aMap.entrySet()) {
            String rawDate = entry.getKey();
            String[] parts = rawDate.split("-");
            String vnDate = parts[2] + "/" + parts[1] + "/" + parts[0];
            out.println("<tr><td align='center'>" + (stt++) + "</td><td align='center'>" + vnDate + "</td><td>Doanh thu bán hàng hóa trong ngày</td><td align='right'>" + String.format("%,.0f", entry.getValue()) + "</td></tr>");
            rowCount++;
        }
        for (int i = 0; i < (20 - rowCount); i++) out.println("<tr><td></td><td></td><td></td><td></td></tr>");

        out.println("<tr style='font-weight:bold; background-color:#eaeaea'><td></td><td></td><td align='center'>TỔNG CỘNG DOANH THU</td><td align='right'>" + String.format("%,.0f", totalRevenue) + "</td></tr>");
        double thueGTGT = totalRevenue * 0.01;
        double thueTNCN = totalRevenue * 0.005;
        out.println("<tr><td></td><td></td><td>Thuế GTGT (1%)</td><td align='right'>" + String.format("%,.0f", thueGTGT) + "</td></tr>");
        out.println("<tr><td></td><td></td><td>Thuế TNCN (0.5%)</td><td align='right'>" + String.format("%,.0f", thueTNCN) + "</td></tr>");
        out.println("<tr class='bold'><td></td><td></td><td>Tổng số thuế phải nộp</td><td align='right'>" + String.format("%,.0f", thueGTGT + thueTNCN) + "</td></tr>");
        out.println("</table>");

        out.println("<br><table border='0' width='100%'><tr><td colspan='2'></td><td align='center'><i>Ngày ..... tháng ..... năm 2026</i></td></tr><tr><td align='center'><b>NGƯỜI LẬP BIỂU</b><br>(Ký, họ tên)</td><td></td><td align='center'><b>NGƯỜI ĐẠI DIỆN HỘ KINH DOANH</b><br>(Ký, họ tên và đóng dấu)<br><br><br><br><b>Phan Thị Soạn</b></td></tr></table></body></html>");
    }
}