<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.SalesEntry" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Sổ Bán Hàng 2026 - Tiến Võ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style> 
        .hover-bg:hover { background-color: #f8f9fa; } 
        .form-control { font-size: 16px; height: 50px; }
        .btn-lg-mobile { padding: 12px; font-size: 18px; font-weight: bold; }
        body { display: flex; flex-direction: column; min-height: 100vh; }
        .main-content { flex: 1; }
        footer { background-color: #f8f9fa; border-top: 1px solid #e9ecef; }
        /* Khu vực nguy hiểm chỉ còn ở Tab 2 */
        .danger-zone { border-top: 2px dashed #dc3545; margin-top: 20px; padding-top: 15px; background-color: #fff5f5; border-radius: 0 0 8px 8px; }
    </style>
</head>
<body class="bg-light">

<div class="container main-content py-3">
    <h3 class="text-center text-primary fw-bold mb-3 text-uppercase">🛒 Tạp Hóa Soạn</h3>
    
    <ul class="nav nav-pills nav-fill mb-3 bg-white p-1 rounded shadow-sm">
        <li class="nav-item"><button class="nav-link active fw-bold" id="tab1-btn" data-bs-toggle="pill" data-bs-target="#tab1">📝 NHẬP ĐƠN</button></li>
        <li class="nav-item"><button class="nav-link fw-bold" id="tab2-btn" data-bs-toggle="pill" data-bs-target="#tab2">📊 BÁO CÁO</button></li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane fade show active" id="tab1">
            <div class="row">
                <div class="col-md-5">
                    <div class="card p-3 shadow-sm mb-3 border-0">
                        <form action="${pageContext.request.contextPath}/sales-journal" method="post">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="origin" value="journal"> 
                            
                            <div class="row g-2">
                                <div class="col-12">
                                    <div class="form-floating mb-2">
                                        <input type="date" name="entryDate" class="form-control" id="fDate" value="<%= java.time.LocalDate.now() %>">
                                        <label for="fDate">Ngày bán</label>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div class="form-floating mb-2">
                                        <input type="text" name="description" class="form-control" id="fDesc" required placeholder="Tên hàng">
                                        <label for="fDesc">Tên hàng hóa (VD: Mì tôm)</label>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div class="form-floating mb-2">
                                        <input type="text" name="customerName" class="form-control" id="fCust" placeholder="Khách">
                                        <label for="fCust">Tên khách (Để trống nếu khách lẻ)</label>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="form-floating mb-2">
                                        <input type="number" inputmode="numeric" name="quantity" class="form-control" id="fQty" value="1" required>
                                        <label for="fQty">Số lượng</label>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="form-floating mb-2">
                                        <input type="number" inputmode="decimal" name="price" class="form-control" id="fPrice" required placeholder="Giá">
                                        <label for="fPrice">Đơn giá</label>
                                    </div>
                                </div>
                            </div>
                            
                            <button class="btn btn-primary w-100 btn-lg-mobile mt-2 shadow">LƯU ĐƠN HÀNG</button>
                        </form>
                    </div>
                </div>

                <div class="col-md-7">
                    <div class="card shadow-sm border-0">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h6 class="fw-bold text-secondary m-0">LỊCH SỬ VỪA NHẬP</h6>
                                <a href="${pageContext.request.contextPath}/sales-journal?action=exportDaily" class="btn btn-sm btn-success fw-bold">📥 Excel Nhật Ký</a>
                            </div>
                            <div class="table-responsive bg-white rounded border" style="max-height: 400px">
                                <table class="table table-striped table-hover text-center align-middle mb-0">
                                    <thead class="table-light sticky-top small"><tr><th>Hàng</th><th>Tiền</th><th>Sửa/Xóa</th></tr></thead>
                                    <tbody>
                                        <% 
                                        List<SalesEntry> dailyList = (List<SalesEntry>)request.getAttribute("dailyList");
                                        if(dailyList!=null) for(SalesEntry e : dailyList){ 
                                        %>
                                        <tr>
                                            <td class="text-start">
                                                <div class="fw-bold"><%=e.getDescription()%></div>
                                                <div class="small text-muted"><%=e.getEntryDate()%></div>
                                            </td>
                                            <td class="fw-bold text-primary"><%=String.format("%,.0f", e.getRevenue())%></td>
                                            <td>
                                                <button type="button" 
                                                        class="btn btn-sm btn-outline-primary border-0 p-1"
                                                        data-id="<%=e.getId()%>"
                                                        data-date="<%=e.getEntryDate()%>"
                                                        data-desc="<%=e.getDescription()%>"
                                                        data-cust="<%=e.getCustomerName()%>"
                                                        data-qty="<%=e.getQuantity()%>"
                                                        data-price="<%=e.getPrice()%>"
                                                        data-source="journal"
                                                        onclick="openEdit(this)">✏️</button>
                                                        
                                                <a href="${pageContext.request.contextPath}/sales-journal?action=delete&id=<%=e.getId()%>" class="btn btn-sm btn-outline-danger border-0 p-1" onclick="return confirm('Xóa?')">🗑</a>
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
        </div>

        <div class="tab-pane fade" id="tab2">
            <div class="card shadow-sm border-0">
                <div class="card-body p-3">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="text-success fw-bold m-0">BÁO CÁO THUẾ</h5>
                        <a href="${pageContext.request.contextPath}/sales-journal?action=export" class="btn btn-success btn-sm fw-bold">📥 Tải Excel S2a</a>
                    </div>
                    
                    <div class="table-responsive border rounded">
                        <table class="table table-bordered text-center align-middle mb-0">
                            <thead class="table-secondary small"><tr><th>Ngày</th><th>Doanh Thu</th><th>Chi tiết</th></tr></thead>
                            <tbody>
                                <% 
                                List<SalesEntry> s2a = (List<SalesEntry>)request.getAttribute("s2aList");
                                if(s2a!=null) for(SalesEntry sumEntry : s2a){ String dateKey = sumEntry.getEntryDate(); %>
                                <tr class="hover-bg">
                                    <td><%=dateKey%></td>
                                    <td class="fw-bold text-primary"><%=String.format("%,.0f", sumEntry.getRevenue())%></td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-dark fw-bold" onclick="showDetailModal('<%=dateKey%>')">Xem</button>
                                        <div id="data-<%=dateKey%>" style="display:none;">
                                            <table class="table table-sm table-bordered mt-2">
                                                <thead class="table-light"><tr><th>Hàng</th><th>Tiền</th><th>Xử lý</th></tr></thead>
                                                <tbody>
                                                    <% if(dailyList!=null) {
                                                        for(SalesEntry raw : dailyList) {
                                                            if(raw.getEntryDate().equals(dateKey)) { %>
                                                    <tr>
                                                        <td class="text-start"><%=raw.getDescription()%> <span class="text-muted small">(<%=raw.getQuantity()%>)</span></td>
                                                        <td class="fw-bold"><%=String.format("%,.0f", raw.getRevenue())%></td>
                                                        <td>
                                                            <button type="button" 
                                                                    class="btn btn-sm btn-primary py-0 px-1"
                                                                    data-id="<%=raw.getId()%>"
                                                                    data-date="<%=raw.getEntryDate()%>"
                                                                    data-desc="<%=raw.getDescription()%>"
                                                                    data-cust="<%=raw.getCustomerName()%>"
                                                                    data-qty="<%=raw.getQuantity()%>"
                                                                    data-price="<%=raw.getPrice()%>"
                                                                    data-source="report"
                                                                    onclick="switchModal(this)">✏️</button>
                                                                    
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

                <div class="danger-zone text-center p-3">
                    <small class="d-block text-danger mb-2 fw-bold">⚠️ Hết Quý / Hết Năm</small>
                    <a href="${pageContext.request.contextPath}/sales-journal?action=deleteAll" 
                       class="btn btn-danger w-100 fw-bold shadow"
                       onclick="return confirm('⛔️ CẢNH BÁO QUAN TRỌNG!\n\nBạn đang chọn: KẾT THÚC KỲ - RESET SỐ LIỆU\n\n1. Hành động này sẽ XÓA SẠCH toàn bộ dữ liệu.\n2. Số thứ tự (ID) sẽ quay về 1.\n3. Dùng khi bạn đã nộp báo cáo xong và muốn bắt đầu kỳ mới.\n\nBạn đã tải file Excel về chưa?')">
                       🔄 KẾT THÚC KỲ - RESET MỚI
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<footer class="mt-auto text-center py-3">
    <div class="container">
        <span class="text-muted small fw-bold">Design by Võ Tiến &copy; 2026</span>
    </div>
</footer>

<div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true"><div class="modal-dialog modal-dialog-centered"><div class="modal-content">
    <form action="${pageContext.request.contextPath}/sales-journal" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" id="eid">
        <input type="hidden" name="origin" id="eorigin">
        
        <div class="modal-header bg-primary text-white"><h5 class="modal-title">Sửa Đơn Hàng</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
        <div class="modal-body">
            <div class="form-floating mb-2"><input type="date" name="entryDate" id="edate" class="form-control" required><label>Ngày</label></div>
            <div class="form-floating mb-2"><input type="text" name="description" id="edesc" class="form-control" required><label>Tên hàng</label></div>
            <div class="form-floating mb-2"><input type="text" name="customerName" id="ecust" class="form-control"><label>Khách hàng</label></div>
            <div class="row g-2">
                <div class="col"><div class="form-floating"><input type="number" inputmode="numeric" name="quantity" id="eqty" class="form-control" required><label>Số lượng</label></div></div>
                <div class="col"><div class="form-floating"><input type="number" inputmode="decimal" name="price" id="eprice" class="form-control" required><label>Giá</label></div></div>
            </div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary w-100 btn-lg-mobile">CẬP NHẬT</button></div>
    </form>
</div></div></div>

<div class="modal fade" id="detailModal" tabindex="-1" aria-hidden="true"><div class="modal-dialog modal-dialog-centered modal-lg"><div class="modal-content">
    <div class="modal-header bg-success text-white"><h5 class="modal-title">Chi Tiết Ngày: <span id="dtTitle"></span></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body" id="detailContent"></div>
    <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button></div>
</div></div></div>

<script>
window.onload = function() {
    const params = new URLSearchParams(window.location.search);
    if(params.get('tab') === 'report') { 
        var tabTrigger = document.querySelector('#tab2-btn');
        var tab = bootstrap.Tab.getOrCreateInstance(tabTrigger);
        tab.show();
    }
}

// HÀM MỞ FORM SỬA (Dùng Data Attributes để an toàn)
function openEdit(btn) {
    // Lấy dữ liệu từ chính cái nút được bấm
    document.getElementById('eid').value = btn.dataset.id;
    document.getElementById('edate').value = btn.dataset.date;
    document.getElementById('edesc').value = btn.dataset.desc;
    document.getElementById('ecust').value = btn.dataset.cust;
    document.getElementById('eqty').value = btn.dataset.qty;
    
    // Giá tiền cần xử lý chút xíu (chuyển về số nguyên)
    var priceRaw = btn.dataset.price;
    document.getElementById('eprice').value = parseFloat(priceRaw).toFixed(0);
    
    document.getElementById('eorigin').value = btn.dataset.source;
    
    // Mở Modal an toàn
    var myModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('editModal'));
    myModal.show();
}

function showDetailModal(dateKey) {
    document.getElementById('dtTitle').innerText = dateKey;
    document.getElementById('detailContent').innerHTML = document.getElementById('data-' + dateKey).innerHTML;
    var myModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('detailModal'));
    myModal.show();
}

function switchModal(btn) {
    var detailEl = document.getElementById('detailModal');
    var detailInstance = bootstrap.Modal.getOrCreateInstance(detailEl);
    
    // Ẩn modal chi tiết trước
    detailInstance.hide();
    
    // Đợi modal cũ tắt hẳn rồi mới mở modal sửa
    setTimeout(function(){ 
        openEdit(btn); 
    }, 300);
}
</script>
</body>
</html>