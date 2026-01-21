<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.SalesEntry" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sổ Bán Hàng 2026 - Tiến Võ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style> .hover-bg:hover { background-color: #f8f9fa; } </style>
</head>
<body class="bg-light py-4">
<div class="container">
    <h2 class="text-center text-primary fw-bold mb-4">🛒 SỔ SÁCH TẠP HÓA SOẠN</h2>
    
    <ul class="nav nav-pills mb-3 bg-white p-2 rounded shadow-sm justify-content-center">
        <li class="nav-item"><button class="nav-link active" id="tab1-btn" data-bs-toggle="pill" data-bs-target="#tab1">📝 1. NHẬP NHẬT KÝ</button></li>
        <li class="nav-item"><button class="nav-link" id="tab2-btn" data-bs-toggle="pill" data-bs-target="#tab2">📊 2. XEM BÁO CÁO THUẾ</button></li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane fade show active" id="tab1">
            <div class="row">
                <div class="col-md-4">
                    <div class="card p-3 shadow-sm mb-3">
                        <div class="card-header bg-primary text-white fw-bold">NHẬP ĐƠN</div>
                        <form action="${pageContext.request.contextPath}/sales-journal" method="post" class="mt-2">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="origin" value="journal"> 
                            <div class="mb-2">Ngày: <input type="date" name="entryDate" class="form-control" value="<%= java.time.LocalDate.now() %>"></div>
                            <div class="mb-2">Hàng hóa: <input type="text" name="description" class="form-control" required placeholder="VD: Mì tôm"></div>
                            <div class="mb-2">Khách: <input type="text" name="customerName" class="form-control" placeholder="Tên khách"></div>
                            <div class="row mb-2">
                                <div class="col">SL: <input type="number" name="quantity" class="form-control" value="1"></div>
                                <div class="col">Giá: <input type="number" name="price" class="form-control" required></div>
                            </div>
                            <button class="btn btn-primary w-100">Lưu</button>
                        </form>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card p-3 shadow-sm">
                        <div class="d-flex justify-content-between mb-2">
                            <h5>Lịch Sử Bán Hàng</h5>
                            <a href="${pageContext.request.contextPath}/sales-journal?action=exportDaily" class="btn btn-sm btn-outline-success fw-bold">📥 Xuất Excel Nhật Ký</a>
                        </div>
                        <div class="table-responsive" style="max-height: 500px">
                            <table class="table table-striped text-center align-middle">
                                <thead class="table-light sticky-top"><tr><th>Ngày</th><th>Hàng</th><th>Tiền</th><th>Xử lý</th></tr></thead>
                                <tbody>
                                    <% 
                                    List<SalesEntry> dailyList = (List<SalesEntry>)request.getAttribute("dailyList");
                                    if(dailyList!=null) for(SalesEntry e : dailyList){ 
                                    %>
                                    <tr>
                                        <td><%=e.getEntryDate()%></td>
                                        <td class="text-start"><%=e.getDescription()%></td>
                                        <td class="fw-bold"><%=String.format("%,.0f", e.getRevenue())%></td>
                                        <td>
                                            <button onclick="edit('<%=e.getId()%>','<%=e.getEntryDate()%>','<%=e.getDescription()%>','<%=e.getCustomerName()%>','<%=e.getQuantity()%>','<%=e.getPrice()%>', 'journal')" class="btn btn-sm btn-outline-primary border-0">✏️</button>
                                            <a href="${pageContext.request.contextPath}/sales-journal?action=delete&id=<%=e.getId()%>" class="btn btn-sm btn-outline-danger border-0" onclick="return confirm('Xóa?')">🗑</a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="tab-pane fade" id="tab2">
            <div class="card p-3 shadow-sm">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="text-success fw-bold">BÁO CÁO THUẾ TỰ ĐỘNG</h5>
                    <a href="${pageContext.request.contextPath}/sales-journal?action=export" class="btn btn-success fw-bold">📥 Tải Excel S2a</a>
                </div>
                
                <table class="table table-bordered text-center align-middle">
                    <thead class="table-secondary"><tr><th>Ngày</th><th>Tổng Doanh Thu</th><th>Thuế (1.5%)</th><th>Chi tiết</th></tr></thead>
                    <tbody>
                        <% 
                        List<SalesEntry> s2a = (List<SalesEntry>)request.getAttribute("s2aList");
                        if(s2a!=null) for(SalesEntry sumEntry : s2a){ String dateKey = sumEntry.getEntryDate(); %>
                        <tr class="hover-bg">
                            <td><%=dateKey%></td>
                            <td class="fw-bold text-primary fs-5"><%=String.format("%,.0f", sumEntry.getRevenue())%></td>
                            <td class="text-danger"><%=String.format("%,.0f", sumEntry.getRevenue()*0.015)%></td>
                            <td>
                                <button class="btn btn-sm btn-outline-primary fw-bold" onclick="showDetailModal('<%=dateKey%>')">👁 Xem & Sửa</button>
                                <div id="data-<%=dateKey%>" style="display:none;">
                                    <table class="table table-sm table-bordered mt-2">
                                        <thead class="table-light"><tr><th>Hàng hóa</th><th>SL</th><th>Giá</th><th>Thành tiền</th><th>Sửa/Xóa</th></tr></thead>
                                        <tbody>
                                            <% if(dailyList!=null) {
                                                for(SalesEntry raw : dailyList) {
                                                    if(raw.getEntryDate().equals(dateKey)) { %>
                                            <tr>
                                                <td class="text-start"><%=raw.getDescription()%></td>
                                                <td><%=raw.getQuantity()%></td>
                                                <td><%=String.format("%,.0f", raw.getPrice())%></td>
                                                <td class="fw-bold"><%=String.format("%,.0f", raw.getRevenue())%></td>
                                                <td>
                                                    <button onclick="switchModal('<%=raw.getId()%>','<%=raw.getEntryDate()%>','<%=raw.getDescription()%>','<%=raw.getCustomerName()%>','<%=raw.getQuantity()%>','<%=raw.getPrice()%>', 'report')" class="btn btn-sm btn-primary py-0 px-1">✏️</button>
                                                    
                                                    <a href="${pageContext.request.contextPath}/sales-journal?action=delete&id=<%=raw.getId()%>&tab=report" onclick="return confirm('Xóa?')" class="btn btn-sm btn-danger py-0 px-1">🗑</a>
                                                </td>
                                            </tr>
                                            <% }}} %>
                                        </tbody>
                                    </table>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editModal"><div class="modal-dialog"><div class="modal-content">
    <form action="${pageContext.request.contextPath}/sales-journal" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" id="eid">
        <input type="hidden" name="origin" id="eorigin">
        
        <div class="modal-header bg-primary text-white"><h5 class="modal-title">Sửa Đơn Hàng</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
        <div class="modal-body">
            <div class="mb-2">Ngày: <input type="date" name="entryDate" id="edate" class="form-control" required></div>
            <div class="mb-2">Hàng: <input type="text" name="description" id="edesc" class="form-control" required></div>
            <div class="mb-2">Khách: <input type="text" name="customerName" id="ecust" class="form-control"></div>
            <div class="row"><div class="col">SL: <input type="number" name="quantity" id="eqty" class="form-control" required></div>
            <div class="col">Giá: <input type="number" name="price" id="eprice" class="form-control" required></div></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary w-100">Cập Nhật</button></div>
    </form>
</div></div></div>

<div class="modal fade" id="detailModal"><div class="modal-dialog modal-lg"><div class="modal-content">
    <div class="modal-header bg-success text-white"><h5 class="modal-title">Chi Tiết Ngày: <span id="dtTitle"></span></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body" id="detailContent"></div>
    <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button></div>
</div></div></div>

<script>
// TỰ ĐỘNG CHUYỂN TAB NẾU URL CÓ CHỮ ?tab=report
window.onload = function() {
    const params = new URLSearchParams(window.location.search);
    if(params.get('tab') === 'report') {
        // Kích hoạt nút Tab 2
        const tabBtn = document.querySelector('#tab2-btn');
        bootstrap.Tab.getOrCreateInstance(tabBtn).show();
    }
}

// Hàm sửa: nhận thêm tham số 'source' (nguồn gốc)
function edit(id,date,desc,cust,qty,price, source){
    document.getElementById('eid').value=id; 
    document.getElementById('edate').value=date;
    document.getElementById('edesc').value=desc; 
    document.getElementById('ecust').value=cust;
    document.getElementById('eqty').value=qty; 
    document.getElementById('eprice').value=parseFloat(price).toFixed(0);
    
    // Gán nguồn gốc (journal hay report) vào ô ẩn để Server biết
    document.getElementById('eorigin').value = source || 'journal';
    
    new bootstrap.Modal(document.getElementById('editModal')).show();
}

function showDetailModal(dateKey) {
    document.getElementById('dtTitle').innerText = dateKey;
    document.getElementById('detailContent').innerHTML = document.getElementById('data-' + dateKey).innerHTML;
    new bootstrap.Modal(document.getElementById('detailModal')).show();
}

// Hàm chuyển Modal và nhớ nguồn là 'report'
function switchModal(id,date,desc,cust,qty,price, source){
    var detailEl = document.getElementById('detailModal');
    var detailInstance = bootstrap.Modal.getInstance(detailEl);
    if (detailInstance) { detailInstance.hide(); }
    
    setTimeout(function(){
        edit(id,date,desc,cust,qty,price, source);
    }, 200);
}
</script>
</body>
</html>