                       ----- THAO TÁC TẠO TABLE -----


-- HOCVIEN
CREATE TABLE hocvien (
    mahv VARCHAR2(20) PRIMARY KEY,
    hoten VARCHAR2(100) NOT NULL,
    ngaysinh DATE,
    email VARCHAR2(100) NOT NULL,
    matkhau VARCHAR2(100)
);

-- DIENDAN
CREATE TABLE diendan (
    madd VARCHAR2(20) PRIMARY KEY,
    tieude VARCHAR2(200) NOT NULL,
    ngay_thaoluan DATE,
    noidung_thaoluan CLOB,
    manguoitao VARCHAR2(20) NOT NULL,
    upvote int,
    downvote int,
    FOREIGN KEY (manguoitao) REFERENCES hocvien(mahv)
);

-- THAMGIA(HOCVIEN -> DIENDAN)
CREATE TABLE THAMGIA (
    thamgia_id varchar(20) NOT NULL,
    madd VARCHAR2(20) NOT NULL,
    mantg VARCHAR2(20) NOT NULL,
    binhluan CLOB,
    upvote int,
    downvote int,
    PRIMARY KEY (thamgia_id),
    FOREIGN KEY (madd) REFERENCES diendan(madd),
    FOREIGN KEY (mantg) REFERENCES hocvien(mahv)
);

-- KHOAHOC
CREATE TABLE khoahoc (
    makh VARCHAR2(20) PRIMARY KEY,
    ten_khoahoc VARCHAR2(200) NOT NULL,
    ngaytao_kh DATE,
    ngaycapnhat DATE,
    mota CLOB,
    ngoaingu VARCHAR2(50),
    chungchi VARCHAR2(100)
);

--  bảng có(khoahoc -> diendan)
CREATE TABLE co (
    madd VARCHAR2(20) NOT NULL,
    makh VARCHAR2(20) NOT NULL,
    PRIMARY KEY (madd, makh),
    FOREIGN KEY (madd) REFERENCES diendan(madd),
    FOREIGN KEY (makh) REFERENCES khoahoc(makh)
);

-- DANGKY (hocvien -> khoahoc)
CREATE TABLE dangky (
    mahv VARCHAR2(20) NOT NULL,
    makh VARCHAR2(20) NOT NULL,
    ngaydangky DATE,
    trangthai VARCHAR2(20),
    ngayhoanthanh DATE,
    PRIMARY KEY (mahv, makh),
    FOREIGN KEY (mahv) REFERENCES hocvien(mahv),
    FOREIGN KEY (makh) REFERENCES khoahoc(makh)
);

-- lịch sử đăng nhập
CREATE TABLE lichsu_dangnhap (
  ma_dn     VARCHAR2(20) PRIMARY KEY,
  mahv           VARCHAR2(20) NOT NULL,
  matkhau    VARCHAR2(100) NOT NULL,
  trangthai   CHAR(40),
  ngay_dangnhap   DATE DEFAULT SYSDATE,
  FOREIGN KEY (mahv) REFERENCES hocvien(mahv)
);

-- LINHVUC 
CREATE TABLE linhvuc (
    malv VARCHAR2(20) PRIMARY KEY,
    ten_linhvuc VARCHAR2(100) NOT NULL
);

-- THUOC_LV (khoahoc -> linhvuc)
CREATE TABLE thuoc_lv (
    makh VARCHAR2(20) NOT NULL,
    malv VARCHAR2(20) NOT NULL,
    PRIMARY KEY (makh, malv),
    FOREIGN KEY (makh) REFERENCES khoahoc(makh),
    FOREIGN KEY (malv) REFERENCES linhvuc(malv)
);

-- GIANGVIEN
CREATE TABLE giangvien (
    magv VARCHAR2(20) PRIMARY KEY,
    hoten VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) NOT NULL
);

-- GIANGDAY (giangvien -> khoahoc)
CREATE TABLE giangday (
    magv VARCHAR2(20) NOT NULL,
    makh VARCHAR2(20) NOT NULL,
    PRIMARY KEY (magv, makh),
    FOREIGN KEY (magv) REFERENCES giangvien(magv),
    FOREIGN KEY (makh) REFERENCES khoahoc(makh)
);

-- BAIHOC
CREATE TABLE baihoc (
    mabh VARCHAR2(20) PRIMARY KEY,
    ten_baihoc VARCHAR2(200) NOT NULL,
    mota VARCHAR2(1000),
    makh VARCHAR2(20),
    FOREIGN KEY (makh) REFERENCES khoahoc(makh)
);

-- CHUDE
CREATE TABLE chude (
    machude VARCHAR2(20) PRIMARY KEY,
    tenchude VARCHAR2(100) NOT NULL,
    mota VARCHAR2(1000)
);

-- TAILIEU
CREATE TABLE tailieu (
    matl VARCHAR2(20) PRIMARY KEY,
    ten_tailieu VARCHAR2(200) NOT NULL,
    loaitl VARCHAR2(50),
    nguon VARCHAR2(200),
    ngay_dang_tai DATE,
    magv VARCHAR2(20),
    FOREIGN KEY (machude) REFERENCES chude(machude),
    FOREIGN KEY (magv) REFERENCES giangvien(magv)
);

-- BAITAP
CREATE TABLE baitap (
    mabt VARCHAR2(20) PRIMARY KEY,
    ten_bt VARCHAR2(200) NOT NULL,
    mota VARCHAR2(1000),
    loaibt VARCHAR2(50),
    hannop DATE,
    mabh VARCHAR2(20),
    FOREIGN KEY (mabh) REFERENCES baihoc(mabh)
);

-- BAINOP
CREATE TABLE bainop (
    mabt VARCHAR2(20) NOT NULL,
    mahv VARCHAR2(20) NOT NULL,
    ngaynop DATE,
    trangthai VARCHAR2(20),
    diem NUMBER(5,2),
    nhan_xet VARCHAR2(1000),
    PRIMARY KEY (mabt, mahv),
    FOREIGN KEY (mabt) REFERENCES baitap(mabt),
    FOREIGN KEY (mahv) REFERENCES hocvien(mahv)
);
-- Tạo bảng bao gồm liên kết giữa  bảng chủ đề và bảng tài liệu
CREATE TABLE BAOGOM (
    machude VARCHAR2(20) NOT NULL,
    matl VARCHAR2(20) NOT NULL,
    PRIMARY KEY (machude, matl),
    FOREIGN KEY (machude) REFERENCES chude(machude),
    FOREIGN KEY (matl) REFERENCES tailieu(matl)
);

-- hocvien_baihoc (hocvien -> baihoc)
CREATE TABLE hocvien_baihoc (
    mahv VARCHAR2(20) NOT NULL,
    mabh VARCHAR2(20) NOT NULL,
    trangthai VARCHAR2(20),
    ngayhoanthanh DATE,
    PRIMARY KEY (mahv, mabh),
    FOREIGN KEY (mahv) REFERENCES hocvien(mahv),
    FOREIGN KEY (mabh) REFERENCES baihoc(mabh)
);

                        ----- THAO TÁC CHỈNH SỬA TABLE -----

                        
-- 1. Thêm thuộc tính mới email với ràng buộc unique vào bảng hocvien
ALTER TABLE hocvien ADD CONSTRAINT uq_email UNIQUE (email);

-- 3. Mã học viên phải bắt đầu bằng “SI”
ALTER TABLE hocvien
ADD CONSTRAINT chk_hocvien_mahv
CHECK (REGEXP_LIKE(mahv, '^HV[0-9]+$'));
    
-- 4. Mã giảng viên phải bắt đầu bằng "GV"
ALTER TABLE giangvien
ADD CONSTRAINT chk_giangvien_magv
CHECK (REGEXP_LIKE(magv, '^GV[0-9]+$'));

                       ----- Thêm dữ liệu các các table -----
truncate table hocvien;
-- Thêm dữ liệu cho bảng HOCVIEN
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV001', 'Nguyễn Văn An', TO_DATE('1999-10-24','YYYY-MM-DD'), 'nguyễn.văn.an@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV002', 'Trần Thị Bình', TO_DATE('1998-02-19','YYYY-MM-DD'), 'trần.thị.bình@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV003', 'Lê Minh Châu', TO_DATE('1997-07-31','YYYY-MM-DD'), 'lê.minh.châu@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV004', 'Phạm Thị Dung', TO_DATE('1999-10-01','YYYY-MM-DD'), 'phạm.thị.dung@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV005', 'Hoàng Văn Đức', TO_DATE('1996-09-27','YYYY-MM-DD'), 'hoàng.văn.đức@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV006', 'Vũ Thị Hà', TO_DATE('1999-02-14','YYYY-MM-DD'), 'vũ.thị.hà@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV007', 'Bùi Quang Huy', TO_DATE('1997-06-30','YYYY-MM-DD'), 'bùi.quang.huy@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV008', 'Đỗ Thị Lan', TO_DATE('1996-01-10','YYYY-MM-DD'), 'đỗ.thị.lan@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV009', 'Phan Văn Lâm', TO_DATE('1997-11-11','YYYY-MM-DD'), 'phan.văn.lâm@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV010', 'Lê Thị Mai', TO_DATE('1995-10-24','YYYY-MM-DD'), 'lê.thị.mai@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV011', 'Ngô Minh Nga', TO_DATE('1998-03-28','YYYY-MM-DD'), 'ngô.minh.nga@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV012', 'Trịnh Văn Phúc', TO_DATE('1995-10-16','YYYY-MM-DD'), 'trịnh.văn.phúc@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV013', 'Hà Thị Quỳnh', TO_DATE('1998-07-16','YYYY-MM-DD'), 'hà.thị.quỳnh@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV014', 'Đặng Văn Sơn', TO_DATE('1998-07-22','YYYY-MM-DD'), 'đặng.văn.sơn@example.com', 'matkhau123');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) VALUES ('HV015', 'Phùng Thị Thảo', TO_DATE('1997-09-18','YYYY-MM-DD'), 'phùng.thị.thảo@example.com', 'matkhau123');

truncate table diendan;
-- Thêm dữ liệu cho bảng DIENDAN
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD001', 'Áp dụng trí tuệ nhân tạo trong y học', TO_DATE('2025-05-01','YYYY-MM-DD'), 'Nội dung cho Áp dụng trí tuệ nhân tạo trong y học', 'HV007', 35, 29);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD002', 'Phương pháp học sâu cho ảnh hưởng sinh học', TO_DATE('2025-05-02','YYYY-MM-DD'), 'Nội dung cho Phương pháp học sâu cho ảnh hưởng sinh học', 'HV007', 64, 7);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD003', 'Phân tích dữ liệu lớn trong kinh doanh', TO_DATE('2025-05-03','YYYY-MM-DD'), 'Nội dung cho Phân tích dữ liệu lớn trong kinh doanh', 'HV012', 58, 15);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD004', 'Thiết kế cơ sở dữ liệu hiệu năng cao', TO_DATE('2025-05-04','YYYY-MM-DD'), 'Nội dung cho Thiết kế cơ sở dữ liệu hiệu năng cao', 'HV009', 95, 6);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD005', 'Phát triển ứng dụng di động với React Native', TO_DATE('2025-05-05','YYYY-MM-DD'), 'Nội dung cho Phát triển ứng dụng di động với React Native', 'HV006', 25, 35);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD006', 'Bảo mật mạng trong kỷ nguyên IoT', TO_DATE('2025-05-06','YYYY-MM-DD'), 'Nội dung cho Bảo mật mạng trong kỷ nguyên IoT', 'HV007', 34, 35);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD007', 'Khởi động dự án khoa học dữ liệu', TO_DATE('2025-05-07','YYYY-MM-DD'), 'Nội dung cho Khởi động dự án khoa học dữ liệu', 'HV011', 51, 19);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD008', 'Phân tích thống kê trong nghiên cứu xã hội', TO_DATE('2025-05-08','YYYY-MM-DD'), 'Nội dung cho Phân tích thống kê trong nghiên cứu xã hội', 'HV001', 95, 41);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD009', 'Đồng bộ hóa hệ thống phân tán', TO_DATE('2025-05-09','YYYY-MM-DD'), 'Nội dung cho Đồng bộ hóa hệ thống phân tán', 'HV005', 41, 17);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD010', 'Ứng dụng blockchain cho tài chính', TO_DATE('2025-05-10','YYYY-MM-DD'), 'Nội dung cho Ứng dụng blockchain cho tài chính', 'HV008', 35, 42);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD011', 'Xử lý ngôn ngữ tự nhiên với Python', TO_DATE('2025-05-11','YYYY-MM-DD'), 'Nội dung cho Xử lý ngôn ngữ tự nhiên với Python', 'HV015', 81, 21);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD012', 'Tối ưu hóa thuật toán tìm kiếm', TO_DATE('2025-05-12','YYYY-MM-DD'), 'Nội dung cho Tối ưu hóa thuật toán tìm kiếm', 'HV002', 28, 29);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD013', 'Kiến trúc microservices trong doanh nghiệp', TO_DATE('2025-05-13','YYYY-MM-DD'), 'Nội dung cho Kiến trúc microservices trong doanh nghiệp', 'HV008', 35, 40);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD014', 'Tích hợp hệ thống ERP và CRM', TO_DATE('2025-05-14','YYYY-MM-DD'), 'Nội dung cho Tích hợp hệ thống ERP và CRM', 'HV006', 82, 44);
INSERT INTO diendan (madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao, upvote, downvote) VALUES ('DD015', 'Phân tích gene trong sinh học phân tử', TO_DATE('2025-05-15','YYYY-MM-DD'), 'Nội dung cho Phân tích gene trong sinh học phân tử', 'HV012', 17, 29);

truncate table thamgia
-- Thêm dữ liệu cho bảng THAMGIA
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG001', 'DD001', 'HV011', 'Mình nghĩ cách 1 sẽ tốt hơn', 11, 37);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG002', 'DD002', 'HV013', 'Nó thật ra khá đơn giản', 61, 23);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG003', 'DD006', 'HV014', 'Chịu khó nghĩ tí là ra á bạn, lĩnh vực này học là vậy á', 91, 30);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG004', 'DD011', 'HV005', 'Thế mới bảo ngoài học ra cần chút thể thao nữa', 98, 20);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG005', 'DD008', 'HV012', 'Mình đồng ý vs bạn xY, nhưng xin phép bổ sung thêm tí nữa nhé', 59, 24);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG006', 'DD004', 'HV003', 'Đã g thì vô lý, phải chuyển sang này mới được chứ bro, như này nè', 8, 26);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG007', 'DD008', 'HV008', 'Đọc kỹ luật trước khi đăng đi bạn', 85, 39);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG008', 'DD009', 'HV005', 'Bạn nên đăng dòng code trực tiếp thay vì ảnh nhé', 56, 35);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG009', 'DD009', 'HV005', 'Bạn có thể cho tôi biết cuốn giáo trình bạn đang đề cập là từ nguồn nào không', 72, 36);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG010', 'DD014', 'HV007', 'Bạn X bình luận thiếu văn hóa quá', 18, 41);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG011', 'DD010', 'HV014', 'Ngoài cách này thì nên áp dụng phương pháp khác nữa ông chú', 37, 46);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG012', 'DD001', 'HV002', 'uầy topic này ít ai  nói tới này', 72, 13);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG013', 'DD006', 'HV009', 'Nếu lăn 1 quả bòng xuống đất thì sẽ xảy ra hiện tượng lăn bóng :))', 11, 49);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG014', 'DD012', 'HV008', 'Dùng Python sẽ tốt nhưng vẫn nên học chắc C++ trước đó', 91, 2);
INSERT INTO thamgia (thamgia_id, madd, mantg, binhluan, upvote, downvote) VALUES ('TG015', 'DD005', 'HV001', 'Cảm ơn lời khuyên của bạn nha!', 82, 7);

truncate table khoahoc;
-- Thêm dữ liệu cho bảng KHOAHOC
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH001', 'Khóa học Trí tuệ nhân tạo cơ bản', TO_DATE('2025-01-01','YYYY-MM-DD'), TO_DATE('2025-02-01','YYYY-MM-DD'), 'Mô tả cho Khóa học Trí tuệ nhân tạo cơ bản', 'Tiếng Anh', 'Chứng chỉ bản');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH002', 'Khóa học Học sâu nâng cao', TO_DATE('2025-01-02','YYYY-MM-DD'), TO_DATE('2025-02-02','YYYY-MM-DD'), 'Mô tả cho Khóa học Học sâu nâng cao', 'Tiếng Trung', 'Chứng chỉ cao');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH003', 'Khóa học Khoa học dữ liệu', TO_DATE('2025-01-03','YYYY-MM-DD'), TO_DATE('2025-02-03','YYYY-MM-DD'), 'Mô tả cho Khóa học Khoa học dữ liệu', 'Tiếng Trung', 'Chứng chỉ liệu');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH004', 'Khóa học Cơ sở dữ liệu tiên tiến', TO_DATE('2025-01-04','YYYY-MM-DD'), TO_DATE('2025-02-04','YYYY-MM-DD'), 'Mô tả cho Khóa học Cơ sở dữ liệu tiên tiến', 'Tiếng Anh', 'Chứng chỉ tiến');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH005', 'Khóa học Phát triển di động', TO_DATE('2025-01-05','YYYY-MM-DD'), TO_DATE('2025-02-05','YYYY-MM-DD'), 'Mô tả cho Khóa học Phát triển di động', 'Tiếng Anh', 'Chứng chỉ động');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH006', 'Khóa học Bảo mật mạng', TO_DATE('2025-01-06','YYYY-MM-DD'), TO_DATE('2025-02-06','YYYY-MM-DD'), 'Mô tả cho Khóa học Bảo mật mạng', 'Tiếng Trung', 'Chứng chỉ mạng');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH007', 'Khóa học Dự án dữ liệu lớn', TO_DATE('2025-01-07','YYYY-MM-DD'), TO_DATE('2025-02-07','YYYY-MM-DD'), 'Mô tả cho Khóa học Dự án dữ liệu lớn', 'Tiếng Anh', 'Chứng chỉ lớn');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH008', 'Khóa học Thống kê ứng dụng', TO_DATE('2025-01-08','YYYY-MM-DD'), TO_DATE('2025-02-08','YYYY-MM-DD'), 'Mô tả cho Khóa học Thống kê ứng dụng', 'Tiếng Trung', 'Chứng chỉ dụng');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH009', 'Khóa học Hệ thống phân tán', TO_DATE('2025-01-09','YYYY-MM-DD'), TO_DATE('2025-02-09','YYYY-MM-DD'), 'Mô tả cho Khóa học Hệ thống phân tán', 'Tiếng Trung', 'Chứng chỉ tán');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH010', 'Khóa học Blockchain tài chính', TO_DATE('2025-01-10','YYYY-MM-DD'), TO_DATE('2025-02-10','YYYY-MM-DD'), 'Mô tả cho Khóa học Blockchain tài chính', 'Tiếng Trung', 'Chứng chỉ chính');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH011', 'Khóa học Xử lý ngôn ngữ tự nhiên', TO_DATE('2025-01-11','YYYY-MM-DD'), TO_DATE('2025-02-11','YYYY-MM-DD'), 'Mô tả cho Khóa học Xử lý ngôn ngữ tự nhiên', 'Tiếng Trung', 'Chứng chỉ nhiên');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH012', 'Khóa học Thuật toán tối ưu', TO_DATE('2025-01-12','YYYY-MM-DD'), TO_DATE('2025-02-12','YYYY-MM-DD'), 'Mô tả cho Khóa học Thuật toán tối ưu', 'Tiếng Trung', 'Chứng chỉ ưu');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH013', 'Khóa học Microservices', TO_DATE('2025-01-13','YYYY-MM-DD'), TO_DATE('2025-02-13','YYYY-MM-DD'), 'Mô tả cho Khóa học Microservices', 'Tiếng Anh', 'Chứng chỉ Microservices');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH014', 'Khóa học ERP & CRM tích hợp', TO_DATE('2025-01-14','YYYY-MM-DD'), TO_DATE('2025-02-14','YYYY-MM-DD'), 'Mô tả cho Khóa học ERP & CRM tích hợp', 'Tiếng Pháp', 'Chứng chỉ hợp');
INSERT INTO khoahoc (makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota,  ngoaingu, chungchi) VALUES ('KH015', 'Khóa học Bioinformatics', TO_DATE('2025-01-15','YYYY-MM-DD'), TO_DATE('2025-02-15','YYYY-MM-DD'), 'Mô tả cho Khóa học Bioinformatics', 'Tiếng Anh', 'Chứng chỉ Bioinformatics');

SELECT *
FROM khoahoc;


truncate table co;
-- Thêm dữ liệu cho bảng CO
INSERT INTO co (madd, makh) VALUES ('DD001', 'KH001');
INSERT INTO co (madd, makh) VALUES ('DD002', 'KH002');
INSERT INTO co (madd, makh) VALUES ('DD003', 'KH003');
INSERT INTO co (madd, makh) VALUES ('DD004', 'KH001');
INSERT INTO co (madd, makh) VALUES ('DD005', 'KH012');
INSERT INTO co (madd, makh) VALUES ('DD006', 'KH008');
INSERT INTO co (madd, makh) VALUES ('DD007', 'KH014');
INSERT INTO co (madd, makh) VALUES ('DD008', 'KH010');
INSERT INTO co (madd, makh) VALUES ('DD009', 'KH007');
INSERT INTO co (madd, makh) VALUES ('DD010', 'KH003');
INSERT INTO co (madd, makh) VALUES ('DD011', 'KH014');
INSERT INTO co (madd, makh) VALUES ('DD012', 'KH011');
INSERT INTO co (madd, makh) VALUES ('DD013', 'KH015');
INSERT INTO co (madd, makh) VALUES ('DD014', 'KH012');
INSERT INTO co (madd, makh) VALUES ('DD015', 'KH008');

truncate table dangky;
-- Thêm dữ liệu cho bảng DANGKY
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV003', 'KH002', TO_DATE('2025-03-06','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-09','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV006', 'KH004', TO_DATE('2025-03-05','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-18','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV013', 'KH004', TO_DATE('2025-03-08','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-11','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV006', 'KH001', TO_DATE('2025-03-08','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-27','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV001', 'KH002', TO_DATE('2025-03-24','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-06','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV004', 'KH015', TO_DATE('2025-03-11','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-13','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV015', 'KH012', TO_DATE('2025-03-08','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-14','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV008', 'KH001', TO_DATE('2025-03-16','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-28','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV009', 'KH006', TO_DATE('2025-03-11','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-20','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV010', 'KH011', TO_DATE('2025-03-19','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-08','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV009', 'KH014', TO_DATE('2025-03-12','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-07','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV011', 'KH014', TO_DATE('2025-03-02','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-19','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV001', 'KH001', TO_DATE('2025-03-17','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-03','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV008', 'KH003', TO_DATE('2025-03-08','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-07','YYYY-MM-DD'));
INSERT INTO dangky (mahv, makh, ngaydangky, trangthai, ngayhoanthanh) VALUES ('HV007', 'KH013', TO_DATE('2025-03-21','YYYY-MM-DD'), 'đã đăng ký', TO_DATE('2025-04-08','YYYY-MM-DD'));

truncate table linhvuc;
-- Thêm dữ liệu cho bảng LINHVUC
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV001', 'Công nghệ thông tin');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV002', 'Khoa học máy tính');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV003', 'Khoa học dữ liệu');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV004', 'An toàn thông tin');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV005', 'Công nghệ phần mềm');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV006', 'Mạng máy tính');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV007', 'Trí tuệ nhân tạo');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV008', 'Hệ thống thông tin');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV009', 'Khoa học tự nhiên');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV010', 'Toán ứng dụng');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV011', 'Sinh học phân tử');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV012', 'Y sinh học');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV013', 'Thống kê');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV014', 'Quản trị kinh doanh');
INSERT INTO linhvuc (malv, ten_linhvuc) VALUES ('LV015', 'Tài chính');

truncate table thuoc_lv;
-- Thêm dữ liệu cho bảng THUOC_LV
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH001', 'LV002');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH002', 'LV009');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH003', 'LV013');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH004', 'LV010');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH005', 'LV001');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH006', 'LV014');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH007', 'LV009');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH008', 'LV014');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH009', 'LV007');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH010', 'LV009');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH011', 'LV008');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH012', 'LV007');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH013', 'LV010');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH014', 'LV010');
INSERT INTO thuoc_lv (makh, malv) VALUES ('KH015', 'LV009');

truncate table giangvien;
-- Thêm dữ liệu cho bảng GIANGVIEN
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV001', 'Lê Thị Cẩm', 'lê.thị.cẩm@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV002', 'Trần Văn Giang', 'trần.văn.giang@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV003', 'Nguyễn Thị Hồng', 'nguyễn.thị.hồng@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV004', 'Hoàng Văn Khánh', 'hoàng.văn.khánh@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV005', 'Phạm Thị Linh', 'phạm.thị.linh@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV006', 'Vũ Minh Ngọc', 'vũ.minh.ngọc@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV007', 'Bùi Thị Oanh', 'bùi.thị.oanh@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV008', 'Đỗ Văn Phú', 'đỗ.văn.phú@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV009', 'Phan Thị Quỳnh', 'phan.thị.quỳnh@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV010', 'Lê Văn Sơn', 'lê.văn.sơn@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV011', 'Ngô Thị Thanh', 'ngô.thị.thanh@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV012', 'Trịnh Minh Tuấn', 'trịnh.minh.tuấn@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV013', 'Hà Văn Uy', 'hà.văn.uy@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV014', 'Đặng Thị Vân', 'đặng.thị.vân@university.edu');
INSERT INTO giangvien (magv, hoten, email) VALUES ('GV015', 'Phùng Văn Yên', 'phùng.văn.yên@university.edu');

truncate table giangday;
-- Thêm dữ liệu cho bảng GIANGDAY
INSERT INTO giangday (magv, makh) VALUES ('GV015', 'KH004');
INSERT INTO giangday (magv, makh) VALUES ('GV009', 'KH001');
INSERT INTO giangday (magv, makh) VALUES ('GV008', 'KH001');
INSERT INTO giangday (magv, makh) VALUES ('GV007', 'KH005');
INSERT INTO giangday (magv, makh) VALUES ('GV014', 'KH012');
INSERT INTO giangday (magv, makh) VALUES ('GV015', 'KH006');
INSERT INTO giangday (magv, makh) VALUES ('GV004', 'KH004');
INSERT INTO giangday (magv, makh) VALUES ('GV009', 'KH013');
INSERT INTO giangday (magv, makh) VALUES ('GV003', 'KH002');
INSERT INTO giangday (magv, makh) VALUES ('GV009', 'KH006');
INSERT INTO giangday (magv, makh) VALUES ('GV007', 'KH014');
INSERT INTO giangday (magv, makh) VALUES ('GV012', 'KH003');
INSERT INTO giangday (magv, makh) VALUES ('GV004', 'KH013');
INSERT INTO giangday (magv, makh) VALUES ('GV001', 'KH002');
INSERT INTO giangday (magv, makh) VALUES ('GV006', 'KH015');

truncate table baihoc;
-- Thêm dữ liệu cho bảng BAIHOC
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH001', 'Giới thiệu Trí tuệ Nhân tạo', 'Tài liệu bài học Giới thiệu Trí tuệ Nhân tạo', 'KH002');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH002', 'Mạng Nơ-ron Nhân tạo', 'Tài liệu bài học Mạng Nơ-ron Nhân tạo', 'KH003');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH003', 'Xử lý Ngôn ngữ Tự nhiên', 'Tài liệu bài học Xử lý Ngôn ngữ Tự nhiên', 'KH004');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH004', 'Học Sâu Nâng cao', 'Tài liệu bài học Học Sâu Nâng cao', 'KH005');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH005', 'Hệ thống Đề xuất', 'Tài liệu bài học Hệ thống Đề xuất', 'KH006');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH006', 'Khai phá Dữ liệu', 'Tài liệu bài học Khai phá Dữ liệu', 'KH007');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH007', 'Phân tích Dữ liệu Sinh học', 'Tài liệu bài học Phân tích Dữ liệu Sinh học', 'KH008');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH008', 'Thị giác Máy tính', 'Tài liệu bài học Thị giác Máy tính', 'KH009');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH009', 'Robot Tự động', 'Tài liệu bài học Robot Tự động', 'KH010');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH010', 'Điện toán Biểu diễn', 'Tài liệu bài học Điện toán Biểu diễn', 'KH011');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH011', 'Toán Ứng dụng trong AI', 'Tài liệu bài học Toán Ứng dụng trong AI', 'KH012');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH012', 'Thuật toán Tối ưu', 'Tài liệu bài học Thuật toán Tối ưu', 'KH013');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH013', 'Kiến trúc Phần mềm', 'Tài liệu bài học Kiến trúc Phần mềm', 'KH014');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH014', 'Phát triển Ứng dụng Di động', 'Tài liệu bài học Phát triển Ứng dụng Di động', 'KH015');
INSERT INTO baihoc (mabh, ten_baihoc, mota,  makh) VALUES ('BH015', 'Blockchain và AI', 'Tài liệu bài học Blockchain và AI', 'KH001');

truncate table CHUDE;
-- Thêm dữ liệu cho bảng CHUDE
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD001', 'Trí tuệ Nhân tạo', 'Chủ đề về Trí tuệ Nhân tạo');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD002', 'Học Sâu', 'Chủ đề về Học Sâu');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD003', 'Xử lý Ngôn ngữ Tự nhiên', 'Chủ đề về Xử lý Ngôn ngữ Tự nhiên');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD004', 'Thị giác Máy tính', 'Chủ đề về Thị giác Máy tính');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD005', 'Khoa Học Dữ liệu', 'Chủ đề về Khoa Học Dữ liệu');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD006', 'Hệ thống Đề xuất', 'Chủ đề về Hệ thống Đề xuất');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD007', 'Phân tích Sinh học', 'Chủ đề về Phân tích Sinh học');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD008', 'Toán Ứng dụng', 'Chủ đề về Toán Ứng dụng');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD009', 'An toàn Thông tin', 'Chủ đề về An toàn Thông tin');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD010', 'Công nghệ Phần mềm', 'Chủ đề về Công nghệ Phần mềm');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD011', 'Blockchain', 'Chủ đề về Blockchain');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD012', 'Điện toán Lý thuyết', 'Chủ đề về Điện toán Lý thuyết');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD013', 'Mạng Nơ-ron', 'Chủ đề về Mạng Nơ-ron');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD014', 'Robot Học', 'Chủ đề về Robot Học');
INSERT INTO chude (machude, tenchude, mota) VALUES ('CD015', 'Thuật toán Tối ưu', 'Chủ đề về Thuật toán Tối ưu');

truncate table tailieu;
-- Thêm dữ liệu cho bảng TAILIEU
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL001', 'Tài liệu 1', 'DOCX', 'Nguồn từ giảng viên GV013', TO_DATE('2025-05-26','YYYY-MM-DD'), 'CD001', 'GV002');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL002', 'Tài liệu 2', 'PDF', 'Nguồn từ giảng viên GV014', TO_DATE('2025-05-25','YYYY-MM-DD'), 'CD002', 'GV003');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL003', 'Tài liệu 3', 'DOCX', 'Nguồn từ giảng viên GV006', TO_DATE('2025-05-29','YYYY-MM-DD'), 'CD003', 'GV004');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL004', 'Tài liệu 4', 'PDF', 'Nguồn từ giảng viên GV015', TO_DATE('2025-05-09','YYYY-MM-DD'), 'CD004', 'GV005');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL005', 'Tài liệu 5', 'DOCX', 'Nguồn từ giảng viên GV012', TO_DATE('2025-05-30','YYYY-MM-DD'), 'CD005', 'GV006');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL006', 'Tài liệu 6', 'PPTX', 'Nguồn từ giảng viên GV005', TO_DATE('2025-05-16','YYYY-MM-DD'), 'CD006', 'GV007');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL007', 'Tài liệu 7', 'PPTX', 'Nguồn từ giảng viên GV002', TO_DATE('2025-05-28','YYYY-MM-DD'), 'CD007', 'GV008');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL008', 'Tài liệu 8', 'PDF', 'Nguồn từ giảng viên GV002', TO_DATE('2025-05-17','YYYY-MM-DD'), 'CD008', 'GV009');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL009', 'Tài liệu 9', 'DOCX', 'Nguồn từ giảng viên GV015', TO_DATE('2025-05-19','YYYY-MM-DD'), 'CD009', 'GV010');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL010', 'Tài liệu 10', 'DOCX', 'Nguồn từ giảng viên GV005', TO_DATE('2025-05-25','YYYY-MM-DD'), 'CD010', 'GV011');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL011', 'Tài liệu 11', 'PPTX', 'Nguồn từ giảng viên GV006', TO_DATE('2025-05-20','YYYY-MM-DD'), 'CD011', 'GV012');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL012', 'Tài liệu 12', 'PDF', 'Nguồn từ giảng viên GV015', TO_DATE('2025-05-21','YYYY-MM-DD'), 'CD012', 'GV013');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL013', 'Tài liệu 13', 'DOCX', 'Nguồn từ giảng viên GV002', TO_DATE('2025-05-02','YYYY-MM-DD'), 'CD013', 'GV014');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL014', 'Tài liệu 14', 'PPTX', 'Nguồn từ giảng viên GV006', TO_DATE('2025-05-11','YYYY-MM-DD'), 'CD014', 'GV015');
INSERT INTO tailieu (matl, ten_tailieu, loaitl, nguon, ngay_dang_tai, machude, magv) VALUES ('TL015', 'Tài liệu 15', 'PPTX', 'Nguồn từ giảng viên GV005', TO_DATE('2025-05-25','YYYY-MM-DD'), 'CD015', 'GV001');

truncate table baitap;
-- Thêm dữ liệu cho bảng BAITAP
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT001', 'Bài tập 1', 'Hướng dẫn giải bài tập 1', 'Tự luận', TO_DATE('2025-06-02','YYYY-MM-DD'), 'BH001');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT002', 'Bài tập 2', 'Hướng dẫn giải bài tập 2', 'MCQ', TO_DATE('2025-05-15','YYYY-MM-DD'), 'BH002');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT003', 'Bài tập 3', 'Hướng dẫn giải bài tập 3', 'MCQ', TO_DATE('2025-06-10','YYYY-MM-DD'), 'BH003');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT004', 'Bài tập 4', 'Hướng dẫn giải bài tập 4', 'MCQ', TO_DATE('2025-06-10','YYYY-MM-DD'), 'BH004');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT005', 'Bài tập 5', 'Hướng dẫn giải bài tập 5', 'MCQ', TO_DATE('2025-05-22','YYYY-MM-DD'), 'BH005');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT006', 'Bài tập 6', 'Hướng dẫn giải bài tập 6', 'Tự luận', TO_DATE('2025-05-12','YYYY-MM-DD'), 'BH006');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT007', 'Bài tập 7', 'Hướng dẫn giải bài tập 7', 'MCQ', TO_DATE('2025-06-27','YYYY-MM-DD'), 'BH007');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT008', 'Bài tập 8', 'Hướng dẫn giải bài tập 8', 'Tự luận', TO_DATE('2025-05-12','YYYY-MM-DD'), 'BH008');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT009', 'Bài tập 9', 'Hướng dẫn giải bài tập 9', 'MCQ', TO_DATE('2025-06-08','YYYY-MM-DD'), 'BH009');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT010', 'Bài tập 10', 'Hướng dẫn giải bài tập 10', 'Tự luận', TO_DATE('2025-05-21','YYYY-MM-DD'), 'BH010');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT011', 'Bài tập 11', 'Hướng dẫn giải bài tập 11', 'Tự luận', TO_DATE('2025-06-26','YYYY-MM-DD'), 'BH011');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT012', 'Bài tập 12', 'Hướng dẫn giải bài tập 12', 'MCQ', TO_DATE('2025-05-16','YYYY-MM-DD'), 'BH012');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT013', 'Bài tập 13', 'Hướng dẫn giải bài tập 13', 'Tự luận', TO_DATE('2025-06-07','YYYY-MM-DD'), 'BH013');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT014', 'Bài tập 14', 'Hướng dẫn giải bài tập 14', 'MCQ', TO_DATE('2025-06-01','YYYY-MM-DD'), 'BH014');
INSERT INTO baitap (mabt, ten_bt, mota, loaibt, hannop, mabh) VALUES ('BT015', 'Bài tập 15', 'Hướng dẫn giải bài tập 15', 'MCQ', TO_DATE('2025-05-30','YYYY-MM-DD'), 'BH015');

truncate table bainop;
-- Thêm dữ liệu cho bảng BAINOP
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT002', 'HV006', TO_DATE('2025-05-14','YYYY-MM-DD'), 'đã nộp', 5.08, 'Nhận xét cho bài tập 1');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT005', 'HV010', TO_DATE('2025-05-21','YYYY-MM-DD'), 'đã nộp', 7.67, 'Nhận xét cho bài tập 2');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT014', 'HV010', TO_DATE('2025-06-19','YYYY-MM-DD'), 'trễ hạn', 8.24, 'Nhận xét cho bài tập 3');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT013', 'HV009', TO_DATE('2025-05-15','YYYY-MM-DD'), 'đã nộp', 5.76, 'Nhận xét cho bài tập 4');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT011', 'HV006', TO_DATE('2025-05-27','YYYY-MM-DD'), 'đã nộp', 9.33, 'Nhận xét cho bài tập 5');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT013', 'HV015', TO_DATE('2025-05-13','YYYY-MM-DD'), 'đã nộp', 9.78, 'Nhận xét cho bài tập 6');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT001', 'HV002', TO_DATE('2025-06-30','YYYY-MM-DD'), 'trễ hạn', 6.86, 'Nhận xét cho bài tập 7');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT004', 'HV013', TO_DATE('2025-05-14','YYYY-MM-DD'), 'trễ hạn', 7.65, 'Nhận xét cho bài tập 8');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT015', 'HV011', TO_DATE('2025-05-22','YYYY-MM-DD'), 'trễ hạn', 9.47, 'Nhận xét cho bài tập 9');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT007', 'HV001', TO_DATE('2025-05-04','YYYY-MM-DD'), 'trễ hạn', 7.21, 'Nhận xét cho bài tập 10');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT011', 'HV008', TO_DATE('2025-06-22','YYYY-MM-DD'), 'trễ hạn', 5.98, 'Nhận xét cho bài tập 11');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT005', 'HV008', TO_DATE('2025-06-17','YYYY-MM-DD'), 'đã nộp', 5.16, 'Nhận xét cho bài tập 12');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT004', 'HV012', TO_DATE('2025-06-04','YYYY-MM-DD'), 'đã nộp', 7.64, 'Nhận xét cho bài tập 13');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT011', 'HV009', TO_DATE('2025-05-13','YYYY-MM-DD'), 'đã nộp', 5.67, 'Nhận xét cho bài tập 14');
INSERT INTO bainop (mabt, mahv, ngaynop, trangthai, diem, nhan_xet) VALUES ('BT014', 'HV006', TO_DATE('2025-06-25','YYYY-MM-DD'), 'đã nộp', 8.97, 'Nhận xét cho bài tập 15');

truncate table baogom;
-- Thêm dữ liệu cho bảng BAOGOM
INSERT INTO BAOGOM (machude, matl) VALUES ('CD001', 'TL001');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD002', 'TL002');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD003', 'TL003');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD004', 'TL004');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD005', 'TL005');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD006', 'TL006');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD007', 'TL007');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD008', 'TL008');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD009', 'TL009');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD010', 'TL010');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD011', 'TL011');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD012', 'TL012');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD013', 'TL013');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD014', 'TL014');
INSERT INTO BAOGOM (machude, matl) VALUES ('CD015', 'TL015');

truncate table hocvien_baihoc;
-- Thêm dữ liệu cho bảng HOCVIEN_BAIHOC
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV001', 'BH001', 'đang học', TO_DATE('2025-05-25','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV002', 'BH002', 'đã hoàn thành', TO_DATE('2025-05-23','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV003', 'BH003', 'đang học', TO_DATE('2025-06-21','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV004', 'BH004', 'đã hoàn thành', TO_DATE('2025-06-26','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV005', 'BH005', 'đang học', TO_DATE('2025-05-09','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV006', 'BH006', 'đã hoàn thành', TO_DATE('2025-05-20','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV007', 'BH007', 'đang học', TO_DATE('2025-05-01','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV008', 'BH008', 'đã hoàn thành', TO_DATE('2025-05-02','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV009', 'BH009', 'đang học', TO_DATE('2025-06-05','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV010', 'BH010', 'đã hoàn thành', TO_DATE('2025-06-10','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV011', 'BH011', 'đang học', TO_DATE('2025-05-06','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV012', 'BH012', 'đã hoàn thành', TO_DATE('2025-05-23','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV013', 'BH013', 'đang học', TO_DATE('2025-05-30','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV014', 'BH014', 'đã hoàn thành', TO_DATE('2025-06-22','YYYY-MM-DD'));
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh) VALUES ('HV015', 'BH015', 'đang học', TO_DATE('2025-05-30','YYYY-MM-DD'));

                        ----- TRUY VẤN TÌM KIẾM, LIỆT KÊ -----

-- truy vấn dữ liệu từ tất cả các bảng:

SELECT *
FROM hocvien;

SELECT *
FROM diendan;

SELECT *
FROM THAMGIA;

SELECT *
FROM khoahoc;

SELECT *
FROM co;

SELECT *
FROM dangky;

SELECT *
FROM linhvuc;

SELECT *
FROM thuoc_lv;

SELECT *
FROM giangvien;

SELECT *
FROM giangday;

SELECT *
FROM baihoc;

SELECT *
FROM chude;

SELECT *
FROM tailieu;

SELECT *
FROM baitap;

SELECT *
FROM bainop;

SELECT *
FROM BAOGOM;

SELECT *
FROM hocvien_baihoc;

--...

-- 1. Tìm kiếm khóa học theo mã (ví dụ: KH001)
SELECT * 
FROM KHOAHOC 
WHERE MAKH = 'KH001';


-- 2. Tìm kiếm khóa học có tên gần đúng (ví dụ chứa "Java")
SELECT * 
FROM KHOAHOC 
WHERE ten_khoahoc LIKE '%Bảo%';


-- 3. Tìm khóa học được đăng ký nhiều nhất
SELECT kh.makh, kh.ten_khoahoc, COUNT(dk.mahv) AS so_luong_hoc_vien
FROM DANGKY dk
JOIN KHOAHOC kh ON dk.makh = kh.makh
GROUP BY kh.makh, kh.ten_khoahoc
ORDER BY so_luong_hoc_vien DESC
FETCH FIRST 1 ROWS ONLY;


-- 4. Tìm các khóa học thuộc một lĩnh vực cụ thể (ví dụ: 'Khoa học dữ liệu')
SELECT kh.makh, kh.ten_khoahoc, lv.ten_linhvuc
FROM KHOAHOC kh
JOIN THUOC_LV tlv ON kh.makh = tlv.makh
JOIN LINHVUC lv ON tlv.malv = lv.malv
WHERE lv.ten_linhvuc = 'Thống kê';


-- 5. Tìm thông tin giảng viên giảng dạy một khóa học (ví dụ: 'Java Basic')
SELECT gv.magv, gv.hoten, gv.email, kh.ten_khoahoc
FROM GIANGVIEN gv
JOIN GIANGDAY gd ON gv.magv = gd.magv
JOIN KHOAHOC kh ON gd.makh = kh.makh
WHERE kh.ten_khoahoc = 'Khóa học Xử lý ngôn ngữ tự nhiên';


-- 6. Liệt kê thông tin học viên đăng ký một khóa học cụ thể (ví dụ: 'Photoshop Pro')
SELECT hv.mahv, hv.hoten, hv.email, kh.ten_khoahoc
FROM HOCVIEN hv
JOIN DANGKY dk ON hv.mahv = dk.mahv
JOIN KHOAHOC kh ON dk.makh = kh.makh
WHERE kh.ten_khoahoc = 'Khóa học Xử lý ngôn ngữ tự nhiên';

-- 7. Liệt kê thông tin giảng viên có tên bằng đầu bằng họ cụ thể

SELECT *
FROM giangvien
WHERE hoten LIKE 'Nguyễn%';

                        ----- VIEW -----

-- 1. Tạo view cho truy vấn khóa học được đăng ký nhiều nhất
CREATE OR REPLACE VIEW v_khoahoc_dangkynhieunhat AS
SELECT kh.makh, kh.ten_khoahoc, COUNT(dk.mahv) AS so_luong_hoc_vien
FROM DANGKY dk
JOIN KHOAHOC kh ON dk.makh = kh.makh
GROUP BY kh.makh, kh.ten_khoahoc
ORDER BY so_luong_hoc_vien DESC
FETCH FIRST 1 ROWS ONLY;

-- test view khóa học được đăng ký nhiều nhất
SELECT * FROM v_khoahoc_dangkynhieunhat;


-- 2. Tạo view cho truy vấn khóa học thuộc một lĩnh vực cụ thể
CREATE OR REPLACE VIEW v_kh_thuoc_lvcuthe AS
SELECT kh.makh, kh.ten_khoahoc, lv.ten_linhvuc
FROM KHOAHOC kh
JOIN THUOC_LV tlv ON kh.makh = tlv.makh
JOIN LINHVUC lv ON tlv.malv = lv.malv;

-- test view khóa học thuộc một lĩnh vực cụ thể

SELECT * FROM v_kh_thuoc_lvcuthe WHERE ten_linhvuc = 'Thống kê';

-- 3. View cho truy vấn thông tin giảng viên giảng dạy một khóa học cụ thể:

CREATE OR REPLACE VIEW v_giangvien_khoahoc AS
SELECT gv.magv, gv.hoten, gv.email, kh.ten_khoahoc
FROM GIANGVIEN gv
JOIN GIANGDAY gd ON gv.magv = gd.magv
JOIN KHOAHOC kh ON gd.makh = kh.makh; 

-- Test view

SELECT * FROM v_giangvien_khoahoc WHERE ten_khoahoc = 'Khóa học Khoa học dữ liệu';

-- 4. View truy van tat ca giao vien 
CREATE OR REPLACE VIEW v_tatca_giangvien AS
SELECT magv, hoten
FROM GIANGVIEN;

-- Test view
SELECT * FROM v_tatca_giangvien;

-- 5. View truy vấn điểm trung bình của từng khóa học của sinh viên
CREATE OR REPLACE VIEW v_diemtb_khoahoc AS
SELECT
    hv.mahv,
    hv.hoten,
    kh.makh,
    kh.ten_khoahoc,
    ROUND(AVG(bn.diem), 2) AS diem_tb
FROM
    hocvien hv
JOIN
    bainop bn ON hv.mahv = bn.mahv
JOIN
    baitap bt ON bn.mabt = bt.mabt
JOIN
    baihoc bh ON bt.mabh = bh.mabh
JOIN
    khoahoc kh ON bh.makh = kh.makh
GROUP BY
    hv.mahv, hv.hoten, kh.makh, kh.ten_khoahoc
ORDER BY
    hv.mahv, kh.makh;

-- Test view
SELECT * FROM v_diemtb_khoahoc;  

                        ----- TRIGGER -----
                 
                        
-- 1. Trigger: Học viên tạo tài khoản thành công
CREATE OR REPLACE TRIGGER trg_dangky_hocvien
BEFORE INSERT ON HOCVIEN
FOR EACH ROW
DECLARE
    hv_count NUMBER;
BEGIN 
    SELECT COUNT(*) INTO hv_count
    FROM HOCVIEN
    WHERE email = :NEW.email;
    
    IF hv_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email này đã tồn tại, vui lòng sử dụng email khác để tạo tài khoản.');
    
    ELSE
        -- Nếu không trùng, in thông báo thành công kèm họ tên
        DBMS_OUTPUT.PUT_LINE(
            'Tài khoản đã được đăng ký thành công cho: ' || :NEW.hoten
        );
    END IF;
END;
/    

-- 2. trigger kiểm insert bài diễn đàn có thành công không
CREATE OR REPLACE TRIGGER trg_insert_diendan
AFTER INSERT ON diendan
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Đăng bài thảo luận thành công! Chủ đề: ' || :NEW.tieude);
END;
/

-- 3. Trigger giảng viên đăng tài liệu thành công
CREATE OR REPLACE TRIGGER trg_insert_tailieu
BEFORE INSERT ON tailieu
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM tailieu WHERE matl = :NEW.matl;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Mã tài liệu đã tồn tại!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Tải tài liệu thành công!');
    END IF;
END;
/

-- 4. trigger insert bài tập có thành công không
CREATE OR REPLACE TRIGGER trg_insert_baitap
BEFORE INSERT ON baitap
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM baitap WHERE mabt = :NEW.mabt;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Mã bài tập đã tồn tại!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Tải bài tập thành công!');
    END IF;
END;
/

-- 5. Trigger: Cập nhật tổng số học viên đăng ký một khóa học
CREATE OR REPLACE TRIGGER trg_capnhat_tong_hocvien
AFTER INSERT OR DELETE ON dangky
DECLARE
  v_makh   VARCHAR2(20);
  v_count  NUMBER;
BEGIN
  -- Lấy mỗi makh hiện có và đếm học viên
  FOR rec IN (
    SELECT makh, COUNT(*) AS cnt
      FROM dangky
     GROUP BY makh
  ) LOOP
    v_makh  := rec.makh;
    v_count := rec.cnt;
    DBMS_OUTPUT.PUT_LINE(
      'Tổng số học viên đang tham gia khóa học '
      || v_makh || ': ' || v_count
    );
  END LOOP;
END;
/

-- 6. CREATE OR REPLACE TRIGGER trg_update_course_completion

CREATE OR REPLACE TRIGGER trg_update_course_completion
  FOR INSERT OR UPDATE OF trangthai ON hocvien_baihoc
  COMPOUND TRIGGER

  -- 1. Collection lưu tạm các bản ghi row-level
  TYPE t_pair IS RECORD (
    mahv hocvien_baihoc.mahv%TYPE,
    mabh hocvien_baihoc.mabh%TYPE
  );
  TYPE t_list IS TABLE OF t_pair INDEX BY PLS_INTEGER;
  g_changes t_list;
  g_cnt     PLS_INTEGER := 0;

  -- 2. Trước khi statement bắt đầu, reset collection
  BEFORE STATEMENT IS
  BEGIN
    g_changes.DELETE;
    g_cnt := 0;
  END BEFORE STATEMENT;

  -- 3. Sau mỗi row-level, nếu trạng thái mới là 'DaHoanThanh' thì gom vào collection
  AFTER EACH ROW IS
  BEGIN
    IF :NEW.trangthai = 'DaHoanThanh' THEN
      g_cnt := g_cnt + 1;
      g_changes(g_cnt).mahv := :NEW.mahv;
      g_changes(g_cnt).mabh := :NEW.mabh;
    END IF;
  END AFTER EACH ROW;

  -- 4. Sau khi statement xong, duyệt collection và cập nhật hocvien_khoahoc
  AFTER STATEMENT IS
    v_course     VARCHAR2(20);
    v_total_less NUMBER;
    v_done_less  NUMBER;
  BEGIN
    FOR i IN 1 .. g_cnt LOOP
      -- a) Lấy mã khóa của bài học
      SELECT makh
        INTO v_course
        FROM baihoc
       WHERE mabh = g_changes(i).mabh;

      -- b) Tổng số bài học trong khóa
      SELECT COUNT(*) INTO v_total_less
        FROM baihoc
       WHERE makh = v_course;

      -- c) Số bài học học viên đã hoàn thành
      SELECT COUNT(*) INTO v_done_less
        FROM hocvien_baihoc hb
        JOIN baihoc bh ON hb.mabh = bh.mabh
       WHERE hb.mahv      = g_changes(i).mahv
         AND bh.makh      = v_course
         AND hb.trangthai = 'DaHoanThanh';

      -- d) Nếu hoàn thành đủ, MERGE vào hocvien_khoahoc
      IF v_done_less = v_total_less THEN
        MERGE INTO dangky dk
        USING (
          SELECT g_changes(i).mahv AS mahv,
                 v_course          AS makh
            FROM dual
        ) src
          ON (dk.mahv = src.mahv AND dk.makh = src.makh)
        WHEN MATCHED THEN
          UPDATE SET
            dk.trangthai     = 'DaHoanThanh',
            dk.ngayhoanthanh = SYSDATE
        WHEN NOT MATCHED THEN
          INSERT (mahv, makh, trangthai, ngayhoanthanh)
          VALUES (src.mahv, src.makh, 'DaHoanThanh', SYSDATE);
      END IF;
    END LOOP;
  END AFTER STATEMENT;

END trg_update_course_completion;
/

-- 7. trigger cập nhật trạng thái bài tập khi bài nộp có điểm >=5 và bài học khi số lượng bài nộp đủ
CREATE OR REPLACE TRIGGER trg_bainop_status
  FOR INSERT OR UPDATE ON bainop
  COMPOUND TRIGGER

  -- 1) Collection lưu tạm các row-level thay đổi
  TYPE t_rec IS RECORD (
    mabt       bainop.mabt%TYPE,
    mahv       bainop.mahv%TYPE,
    trangthai  bainop.trangthai%TYPE
  );
  TYPE t_tab IS TABLE OF t_rec INDEX BY PLS_INTEGER;
  g_rows t_tab;
  g_idx  PLS_INTEGER := 0;

  -- 2) Trước mỗi row, set trangthai ngay trên :NEW
  BEFORE EACH ROW IS
  BEGIN
    IF :NEW.diem >= 5 THEN
      :NEW.trangthai := 'đã hoàn thành';
    ELSE
      :NEW.trangthai := 'chưa hoàn thành';
    END IF;
  END BEFORE EACH ROW;

  -- 3) Sau mỗi row-level, gom thông tin vào collection
  AFTER EACH ROW IS
  BEGIN
    g_idx := g_idx + 1;
    g_rows(g_idx) := t_rec(
      mabt       => :NEW.mabt,
      mahv       => :NEW.mahv,
      trangthai  => :NEW.trangthai
    );
  END AFTER EACH ROW;

  -- 4) Sau khi toàn bộ statement xong, xử lý cập nhật HOCVIEN_BAIHOC
  AFTER STATEMENT IS
    v_mabh      baitap.mabh%TYPE;
    v_completed NUMBER;
    v_total     NUMBER;
  BEGIN
    FOR i IN 1..g_idx LOOP
      -- Lấy mã bài học từ BAI TAP
      SELECT mabh
        INTO v_mabh
        FROM baitap
       WHERE mabt = g_rows(i).mabt;

      -- Đếm số bài đã hoàn thành của học viên trong bài học đó
      SELECT COUNT(*)
        INTO v_completed
        FROM bainop bp
        JOIN baitap bt ON bp.mabt = bt.mabt
       WHERE bp.mahv      = g_rows(i).mahv
         AND bt.mabh      = v_mabh
         AND bp.trangthai = 'đã hoàn thành';

      -- Đếm tổng số bài tập của bài học
      SELECT COUNT(*)
        INTO v_total
        FROM baitap
       WHERE mabh = v_mabh;

      -- Nếu đủ, cập nhật học viên-bài học
      IF v_completed = v_total THEN
        UPDATE hocvien_baihoc
           SET trangthai     = 'đã hoàn thành',
               ngayhoanthanh = SYSDATE
         WHERE mahv = g_rows(i).mahv
           AND mabh = v_mabh;
      END IF;
    END LOOP;
  END AFTER STATEMENT;

END trg_bainop_status;
/


-- 8. Trigger thông báo nhập nguồn cho tài liệu nếu không có nguồn
drop trigger trg_insert_tailieu;

CREATE OR REPLACE TRIGGER trg_tailieu_require_nguon
BEFORE INSERT ON tailieu
FOR EACH ROW
BEGIN
  IF :NEW.nguon IS NULL OR TRIM(:NEW.nguon) = '' THEN
    RAISE_APPLICATION_ERROR(
      -20010,
      'Vui lòng cung cấp nguồn của tài liệu.'
    );
  END IF;
END;
/

-- 9. Trigger không cho insert bài tập nếu ngày nộp muộn 
CREATE OR REPLACE TRIGGER trg_bainop_deadline_check
BEFORE INSERT ON bainop
FOR EACH ROW
DECLARE
    v_hannop DATE;
BEGIN
    SELECT hannop
      INTO v_hannop
      FROM baitap
     WHERE mabt = :NEW.mabt;

    IF :NEW.ngaynop > v_hannop THEN
      RAISE_APPLICATION_ERROR(
        -20011,
        'Bạn đã trễ hạn nộp bài: Ngày nộp '||TO_CHAR(:NEW.ngaynop,'YYYY-MM-DD')||
        ' muộn hơn hạn nộp '||TO_CHAR(v_hannop,'YYYY-MM-DD')
      );
    END IF;
END;
/

-- 10. Trigger thông báo đăng nhập thành công nếu đúng mật khẩu

CREATE OR REPLACE TRIGGER trg_kiemtra_dangnhap
BEFORE INSERT ON lichsu_dangnhap
FOR EACH ROW
DECLARE
    matkhau_dung VARCHAR2(100);
BEGIN
    -- Lấy mật khẩu thật từ hocvien
    SELECT matkhau
      INTO matkhau_dung
      FROM hocvien
     WHERE mahv = :NEW.mahv;

    IF :NEW.nhap_matkhau = matkhau_dung THEN
      :NEW.trangthai := 'Thành công';
      DBMS_OUTPUT.PUT_LINE('Đăng nhập thành công cho tài khoản '||:NEW.mahv);
    ELSE
      :NEW.trangthai := 'Không thành công';
      DBMS_OUTPUT.PUT_LINE('Đăng nhập thất bại cho tài khoản '||:NEW.mahv);
    END IF;
END;
/

            ----- FUNCTION -----


-- 1) Tính điểm trung bình học viên
CREATE OR REPLACE FUNCTION fnc_tinh_diem_tb(p_mahv VARCHAR2)
RETURN NUMBER
IS
    v_avg NUMBER;
BEGIN
    SELECT AVG(diem) INTO v_avg
    FROM bainop
    WHERE mahv = p_mahv;

    RETURN v_avg;
END;
/

-- 2) Kiểm tra bài tập nộp trễ
CREATE OR REPLACE FUNCTION fnc_kiemtra_nop_tre(p_mabt VARCHAR2)
RETURN VARCHAR2
IS
    v_result VARCHAR2(100);
BEGIN
    SELECT CASE
             WHEN ngaynop > hannop THEN 'Nộp trễ'
             ELSE 'Đúng hạn'
           END
    INTO v_result
    FROM bainop JOIN baitap ON bainop.mabt = baitap.mabt
    WHERE bainop.mabt = p_mabt;

    RETURN v_result;
END;
/
-- 3) Kiểm tra khóa học đã hoàn thành hay chưa

CREATE OR REPLACE FUNCTION fnc_kiemtra_hoanthanh(p_mahv VARCHAR2)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
    SELECT kh.makh, kh.ten_khoahoc, dk.trangthai
    FROM dangky dk
    JOIN khoahoc kh ON dk.makh = kh.makh
    WHERE dk.mahv = p_mahv;

    RETURN v_cursor;
END;
/

-- 4) Tính tỷ lệ hoàn thành khóa học
CREATE OR REPLACE FUNCTION fnc_ty_le_hoanthanh(p_makh VARCHAR2)
RETURN NUMBER
IS
    v_done NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM baihoc WHERE makh = p_makh;
    SELECT COUNT(*) INTO v_done FROM dangky WHERE makh = p_makh AND trangthai = 'Đã hoàn thành';

    RETURN (v_done / v_total) * 100;
END;
/

-- 5) tinh diem trung binh bai tapfnc_tinh_diem_tb_baitap
create or replace FUNCTION fnc_tinh_diem_tb_baitap(p_mabt VARCHAR2)
RETURN NUMBER
IS
    v_avg NUMBER;
BEGIN
    SELECT NVL(AVG(diem), 0) INTO v_avg
    FROM bainop
    WHERE mabt = p_mabt;

    RETURN v_avg;
END;
/

-- 6) tim khoa hoc
create or replace FUNCTION tim_khoahoc(p_keyword VARCHAR2)
RETURN SYS_REFCURSOR
IS
  l_cursor SYS_REFCURSOR;
BEGIN
  OPEN l_cursor FOR
    SELECT makh, ten_khoahoc, mota
    FROM khoahoc
    WHERE LOWER(ten_khoahoc) LIKE '%' || LOWER(p_keyword) || '%';
  RETURN l_cursor;
END;
/

                        ----- PROCEDURE -----


-- 1) Thủ tục tao khóa học

CREATE OR REPLACE PROCEDURE prc_tao_khoahoc (
  p_makh        IN VARCHAR2,
  p_ten         IN VARCHAR2,
  p_ngaytao     IN DATE,
  p_ngaycapnhat IN DATE,
  p_mota        IN VARCHAR2,
  p_ngoaingu   IN VARCHAR2,
  p_chungchi    IN VARCHAR2
)
IS
  v_exist NUMBER;
BEGIN
  -- Kiểm tra mã khóa học đã tồn tại chưa
  SELECT COUNT(*) 
    INTO v_exist 
    FROM khoahoc 
   WHERE makh = p_makh;

  IF v_exist = 0 THEN
    INSERT INTO khoahoc (
      makh, ten_khoahoc, ngaytao_kh, ngaycapnhat, mota, ngoaingu, chungchi
    ) VALUES (
      p_makh, p_ten, p_ngaytao, p_ngaycapnhat, p_mota, p_ngoaingu, p_chungchi
    );
    DBMS_OUTPUT.PUT_LINE('Thêm khóa học thành công: ' || p_makh || ' - ' || p_ten);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Mã khóa học đã tồn tại: ' || p_makh);
  END IF;
END;
/

-- 2) thu tuc dang ky khoa hoc
create or replace PROCEDURE prc_dangky_khoahoc(p_mahv VARCHAR2, p_makh VARCHAR2) IS
  v_exist NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_exist FROM dangky WHERE mahv = p_mahv AND makh = p_makh;
  IF v_exist = 0 THEN
    INSERT INTO dangky(mahv, makh, ngaydangky) VALUES(p_mahv, p_makh, SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Đăng ký thành công.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Đã đăng ký khóa học này.');
  END IF;
END;
/

-- 3) dang ky hoc vien moi
CREATE OR REPLACE PROCEDURE prc_dangky_hocvien_moi (
    p_mahv     VARCHAR2,
    p_hoten    VARCHAR2,
    p_ngaysinh DATE,
    p_email    VARCHAR2,
    p_matkhau VARCHAR2
)
IS
    v_count NUMBER;
BEGIN
    -- Kiểm tra xem email đã tồn tại chưa
    SELECT COUNT(*) INTO v_count
    FROM hocvien
    WHERE LOWER(email) = LOWER(p_email);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email đã tồn tại. Vui lòng dùng email khác!');
    ELSE
        INSERT INTO hocvien (mahv, hoten, ngaysinh, email)
        VALUES (p_mahv, p_hoten, p_ngaysinh, p_email);
        DBMS_OUTPUT.PUT_LINE('Đăng ký học viên thành công!');
    END IF;
END;
/


                        ----- PHÂN QUYỀN -----

-- Role dành cho Học viên
CREATE ROLE role_hocvien;

-- Role dành cho Giảng viên
CREATE ROLE role_giangvien;

-- Role dành cho Quản trị viên
CREATE ROLE role_quantrivien;

-- Chỉ role quản trị viên được phép CONNECT (CREATE SESSION)
GRANT CREATE SESSION TO role_quantrivien;

-- 1. Cấp quyền cho học viên
-- Cho phép xem thông tin khóa học, bài học, bài tập, bài nộp
GRANT SELECT ON khoahoc      TO role_hocvien;
GRANT SELECT ON baihoc       TO role_hocvien;
GRANT SELECT ON baitap       TO role_hocvien;
GRANT SELECT ON bainop       TO role_hocvien;

-- Cho phép đăng ký khóa học
GRANT INSERT ON dangky       TO role_hocvien;
GRANT EXECUTE ON prc_dangky_khoahoc TO role_hocvien;

-- Cho phép tạo và tham gia diễn đàn
GRANT INSERT ON diendan      TO role_hocvien;
GRANT INSERT ON thamgia      TO role_hocvien;

-- Cho phép nộp bài (chưa chấm)
GRANT INSERT ON bainop       TO role_hocvien;


-- 2. cấp quyền cho giảng viên 
-- Xem danh sách học viên, đăng ký, bài nộp
GRANT SELECT ON hocvien      TO role_giangvien;
GRANT SELECT ON dangky       TO role_giangvien;

-- Cho phép xem thông tin khóa học, bài học, bài tập, bài nộp
GRANT SELECT ON khoahoc      TO role_giangvien;
GRANT SELECT ON baihoc       TO role_giangvien;
GRANT SELECT ON baitap       TO role_giangvien;
GRANT SELECT ON bainop       TO role_giangvien;


-- Tạo / sửa khóa học & gọi procedure
GRANT INSERT, UPDATE ON khoahoc       TO role_giangvien;
GRANT EXECUTE ON prc_tao_khoahoc      TO role_giangvien;

-- Tải tài liệu
GRANT INSERT, UPDATE ON tailieu       TO role_giangvien;

-- Tạo / sửa bài học, bài tập
GRANT INSERT, UPDATE ON baihoc        TO role_giangvien;
GRANT INSERT, UPDATE ON baitap        TO role_giangvien;

-- Nhận xét bài nộp (ví dụ cột nhan_xet trong bainop)
GRANT UPDATE ON bainop        TO role_giangvien;
--

-- 3. cấp quyền cho quản trị viên

-- Cho phép xem thông tin khóa học, bài học, bài tập, bài nộp, diễn đàn
GRANT SELECT ON khoahoc      TO role_quantrivien;
GRANT SELECT ON baihoc       TO role_quantrivien;
GRANT SELECT ON baitap       TO role_quantrivien;
GRANT SELECT ON bainop       TO role_quantrivien;
GRANT SELECT ON diendan       TO role_quantrivien;

--- 4. Gán role khác nhau cho các user:

-- Gán role_hocvien cho các tài khoản học viên
GRANT role_hocvien TO HV001;
-- …

-- Gán role_giangvien cho các tài khoản giảng viên
GRANT role_giangvien TO GV001;

-- Gán role_quantrivien cho các tài khoản quản trị viên
GRANT role_quantrivien TO QTV001;
                    
                    
                      ------- INSERT TEST TRIGGER, FUNCTION VÀ PROCEDURE -------
                        
--------------------------------------------------------------------------------
-- 1. test trigger: Học viên tạo tài khoản thành công
--------------------------------------------------------------------------------
-- Trường hợp lỗi:

-- Insert data into HOCVIEN
INSERT INTO HOCVIEN
    VALUES ('HV010', 'Nguyễn Thị Hồng', TO_DATE('24/10/2005', 'DD/MM/YYYY'), 'nva@example.com', 'hihi');

-- Trường hợp không lỗi”
INSERT INTO HOCVIEN
    VALUES ('HV009', 'Hứa Gia Bảo', TO_DATE('24/10/2005', 'DD/MM/YYYY'), 'HGB11221@gm.uit.edu.vn', 'hihi');


--------------------------------------------------------------------------------
-- 2. Test trigger trg_insert_diendan
--------------------------------------------------------------------------------
-- Case thành công (in ra: Đăng bài thảo luận thành công! Chủ đề: Test chủ đề)
INSERT INTO diendan (
  madd, tieude, ngay_thaoluan, noidung_thaoluan, manguoitao
) VALUES (
  'DD992','Test chủ đề',TO_DATE('01/06/2025','DD-MM-YYYY'),
  'Nội dung test','HV001'
);

--------------------------------------------------------------------------------
-- 3. Test trigger trg_insert_tailieu
--------------------------------------------------------------------------------
-- 3.1 Case lỗi duplicate matl
BEGIN
  INSERT INTO tailieu VALUES(
    'TL001','Duplicate','PDF','src',SYSDATE,'CD001','GV001'
  );
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Error trg_insert_tailieu (dup matl): '||SQLERRM);
END;
/
-- 3.2 Case thành công
INSERT INTO tailieu VALUES(
  'TL050','Test TL','PDF','src',SYSDATE,'CD001','GV001'
);

SELECT * FROM TAILIEU;
--------------------------------------------------------------------------------
-- 4. Test trigger trg_insert_baitap
--------------------------------------------------------------------------------
-- 4.1 Case lỗi duplicate mabt
BEGIN
  INSERT INTO baitap VALUES(
    'BT382','Duplicate BT','mota','Code',
    TO_DATE('01/01/2025','YYYY-MM-DD'),'BH001'
  );
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Error trg_insert_baitap (dup mabt): '||SQLERRM);
END;
/

-- 4.2 Case lỗi
INSERT INTO baitap VALUES(
  'BT999','Test BT','mota','Quiz',SYSDATE,'BH001'
);

--------------------------------------------------------------------------------
-- 5. Test trigger trg_update_total_students
--------------------------------------------------------------------------------
-- 5.1 Insert mới (in ra tổng số học viên cho KH002)
INSERT INTO dangky(mahv, makh, ngaydangky) VALUES('HV002','KH002',SYSDATE);
-- 5.2 Delete (in ra sau khi delete)
DELETE FROM dangky WHERE mahv='HV002' AND makh='KH002';

----------------------------------------------------
-- 6. Test trigger trạng thái khóa học
--  Dọn dẹp lại:
DELETE FROM hocvien_baihoc  WHERE mahv = 'HV006';
DELETE FROM hocvien_khoahoc WHERE mahv = 'HV006';
COMMIT;

-- Nộp xong bài BH001:
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai, ngayhoanthanh)
VALUES ('HV006','BH001','DaHoanThanh',SYSDATE);
COMMIT;

--  Kiểm tra kết quả:
SELECT * 
  FROM hocvien_khoahoc 
 WHERE mahv = 'HV006' 
   AND makh = 'KH001';

-- BẬT IN THÔNG BÁO
SET SERVEROUTPUT ON;


--------------------------------------------------------------------------------
-- 7) Test trg_bainop_update_status
--------------------------------------------------------------------------------
-- Giả sử:
--   • Bài học BH100 có 1 bài tập BT100
--   • Học viên HV100 đã có trong HOCVIEN_BAIHOC với trạng thái 'đang học'

-- Chuẩn bị dữ liệu
INSERT INTO baihoc  (mabh, ten_baihoc, mota, makh) VALUES ('BH100','Test Bài học','...', 'KH001');
INSERT INTO baitap  (mabt, ten_bt, mota, loaibt, hannop, mabh) 
                      VALUES ('BT100','Test Bài tập','...','MCQ',TO_DATE('2025-06-30','YYYY-MM-DD'),'BH100');
INSERT INTO hocvien (mahv, hoten, ngaysinh, email, matkhau) 
                      VALUES ('HV100','Test User',TO_DATE('2000-01-01','YYYY-MM-DD'),'test.user@example.com','pw');
INSERT INTO hocvien_baihoc (mahv, mabh, trangthai) 
                      VALUES ('HV100','BH100','đang học');

COMMIT;

-- 7.1: Chèn BAINOP điểm ≥5 → BAINOP.trangthai = 'đã hoàn thành' & HOCVIEN_BAIHOC.trangthai → 'đã hoàn thành'
INSERT INTO bainop (mabt, mahv, ngaynop, diem) VALUES ('BT100','HV100',SYSDATE, 7);
COMMIT;

-- Kiểm tra kết quả
SELECT trangthai 
  FROM bainop 
 WHERE mabt='BT100' AND mahv='HV100';

SELECT trangthai, ngayhoanthanh 
  FROM hocvien_baihoc 
 WHERE mahv='HV100' AND mabh='BH100';


-- 7.2: Chèn BAINOP điểm <5 → BAINOP.trangthai = 'chưa hoàn thành' & không ảnh hưởng HOCVIEN_BAIHOC
DELETE FROM bainop WHERE mabt='BT100' AND mahv='HV100'; COMMIT;
UPDATE hocvien_baihoc SET trangthai='đang học', ngayhoanthanh=NULL
 WHERE mahv='HV100' AND mabh='BH100'; COMMIT;

INSERT INTO bainop (mabt, mahv, ngaynop, diem) VALUES ('BT100','HV100',SYSDATE, 3);
COMMIT;

SELECT trangthai 
  FROM bainop 
 WHERE mabt='BT100' AND mahv='HV100';

SELECT trangthai 
  FROM hocvien_baihoc 
 WHERE mahv='HV100' AND mabh='BH100';


--------------------------------------------------------------------------------
-- 8) Test trg_tailieu_require_nguon
--------------------------------------------------------------------------------
-- 8.1: Case lỗi (nguồn NULL)
BEGIN
  INSERT INTO tailieu (matl,ten_tailieu,loaitl,nguon,ngay_dang_tai,machude,magv)
  VALUES ('TLX01','Test TL lỗi','PDF',NULL,SYSDATE,'CD001','GV001');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Lỗi Trigger 8: '||SQLERRM);
END;
/

-- 8.2: Case thành công
INSERT INTO tailieu (matl,ten_tailieu,loaitl,nguon,ngay_dang_tai,machude,magv)
VALUES ('TLX02','Test TL OK','PDF','Nguồn mẫu',SYSDATE,'CD001','GV001');
COMMIT;
SELECT * FROM tailieu WHERE matl='TLX02';


--------------------------------------------------------------------------------
-- 9) Test trg_bainop_deadline_check
--------------------------------------------------------------------------------
-- Giả sử BT200 có hannop = 2025-06-15
INSERT INTO baitap (mabt,ten_bt,mota,loaibt,hannop,mabh)
VALUES ('BT200','Test Hạn','...','MCQ',TO_DATE('2025-06-15','YYYY-MM-DD'),'BH001');
COMMIT;

-- 9.1: Case thành công (ngaynop ≤ hannop)
INSERT INTO bainop (mabt,mahv,ngaynop,diem)
VALUES ('BT001','HV001',TO_DATE('2025-05-10','YYYY-MM-DD'),8);
COMMIT;

SELECT * FROM bainop WHERE mabt='BT200' AND mahv='HV001';

-- 9.2: Case lỗi (ngaynop > hannop)
BEGIN
  INSERT INTO bainop (mabt,mahv,ngaynop,diem)
  VALUES ('BT001','HV001',TO_DATE('2025-07-20','YYYY-MM-DD'),9);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Lỗi Trigger 9: '||SQLERRM);
END;
/


--------------------------------------------------------------------------------
-- 10) Test trg_kiemtra_dangnhap
--------------------------------------------------------------------------------
-- 10.1: Case đúng mật khẩu
INSERT INTO lichsu_dangnhap (ma_dangnhap,mahv,nhap_matkhau)
VALUES ('LOG001','HV001','matkhau123');
-- Xem màn hình: DBMS_OUTPUT 'Đăng nhập thành công cho tài khoản HV001'
SELECT * FROM lichsu_dangnhap WHERE ma_dangnap='LOG001';

-- 10.2: Case sai mật khẩu
INSERT INTO lichsu_dangnhap (ma_dangnhap,mahv,nhap_matkhau)
VALUES ('LOG002','HV001','vai');
-- Xem màn hình: DBMS_OUTPUT 'Đăng nhập thất bại cho tài khoản HV001'
SELECT * FROM lichsu_dangnhap WHERE ma_dangnhap='LOG002';


SELECT * FROM hocvien;

SELECT * FROM  lichsu_dangnhap;

--------------------------------------------------------------------------------
-- 9. Test function fnc_tinh_diem_tb
--------------------------------------------------------------------------------
SELECT fnc_tinh_diem_tb('HV001')    AS diem_tb_exist  FROM dual;
SELECT fnc_tinh_diem_tb('HV999')    AS diem_tb_missing FROM dual;

--------------------------------------------------------------------------------
-- 10. Test function fnc_kiemtra_nop_tre
--------------------------------------------------------------------------------
SELECT fnc_kiemtra_nop_tre('BT001') AS ketqua_late   FROM dual;
-- Tạo 1 nộp đúng hạn để test
INSERT INTO bainop VALUES('BT100','HV001',TO_DATE('10/01/2024','DD/MM/YYYY'),'Đã nộp',5,'OK');
SELECT fnc_kiemtra_nop_tre('BT100') AS ketqua_ontime FROM dual;

--------------------------------------------------------------------------------
-- 11. Test function fnc_kiemtra_hoanthanh
--------------------------------------------------------------------------------
VAR rc REFCURSOR;
EXEC :rc := fnc_kiemtra_hoanthanh('HV001');
PRINT rc;

--------------------------------------------------------------------------------
-- 12. Test function fnc_ty_le_hoanthanh
--------------------------------------------------------------------------------
SELECT fnc_ty_le_hoanthanh('KH001') AS tyle_kh1 FROM dual;
SELECT fnc_ty_le_hoanthanh('KH002') AS tyle_kh2 FROM dual;

--------------------------------------------------------------------------------
-- 13. Test function fnc_tinh_diem_tb_baitap
--------------------------------------------------------------------------------
SELECT fnc_tinh_diem_tb_baitap('BT001') AS avg_bt1 FROM dual;

--------------------------------------------------------------------------------
-- 14. Test function tim_khoahoc
--------------------------------------------------------------------------------
VAR rc2 REFCURSOR;
EXEC :rc2 := tim_khoahoc('Java');
PRINT rc2;

--------------------------------------------------------------------------------
-- 15. Test procedure prc_tao_khoahoc
--------------------------------------------------------------------------------
BEGIN
  prc_tao_khoahoc(
    'KH006','SQL Testing',SYSDATE,SYSDATE,
    'mô tả','active','Anh','Cert'
  );
END;
/
BEGIN
  prc_tao_khoahoc(
    'KH001','Duplicate',SYSDATE,SYSDATE,
    'mô tả','Anh','Cert'
  );
END;
/

--------------------------------------------------------------------------------
-- 16. Test procedure prc_dangky_khoahoc
--------------------------------------------------------------------------------
BEGIN prc_dangky_khoahoc('HV001','KH002'); END;
/  -- còn mới
BEGIN prc_dangky_khoahoc('HV001','KH001'); END;/  -- đã đăng ký

--------------------------------------------------------------------------------
-- 17. Test procedure prc_dangky_hocvien_moi
--------------------------------------------------------------------------------
BEGIN
  prc_dangky_hocvien_moi(
    'HV008','Test User',TO_DATE('01/01/2001','DD/MM/YYYY'),
    'nva@example.com', '12345678'
  );
END;
/
BEGIN
  prc_dangky_hocvien_moi(
    'HV009','Test User2',TO_DATE('01/01/2002','DD/MM/YYYY'),
    'unique@example.com', 'hihihi'
  );
END;
/


SELECT *
FROM HOCVIEN;