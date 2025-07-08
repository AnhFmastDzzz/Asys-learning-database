const express    = require('express');
const oracledb   = require('oracledb');
const cors       = require('cors');
const path       = require('path');
const crypto     = require('crypto');

const app  = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Serve index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

const dbConfig = {
  user: 'hoanganh',
  password: 'Anh2172005',
  connectString: 'localhost:1521/hoanganh'
};

// 1) Search courses
app.post('/search', async (req, res) => {
  const { keyword } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `BEGIN :c := tim_khoahoc(:keyword); END;`,
      { c: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR }, keyword }
    );
    const rs   = result.outBinds.c;
    const rows = await rs.getRows();
    console.log(rows);
    await rs.close(); await conn.close();
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Lỗi server khi tìm kiếm khóa học');
  }
});

// 2) Login học viên
app.post('/login', async (req, res) => {
  const { mahv } = req.body;
  try {
    const conn   = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `SELECT COUNT(*) FROM hocvien WHERE mahv = :mahv`,
      [mahv]
    );
    await conn.close();
    const ok = result.rows[0][0] > 0;
    res.json({ success: ok, message: ok ? null : 'Mã học viên không tồn tại!' });
  } catch (err) {
    console.error(err);
    res.status(500).send('Lỗi server khi đăng nhập học viên');
  }
});

// 3) Login giảng viên
app.post('/login-gv', async (req, res) => {
  const { magv } = req.body;
  try {
    const conn   = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `SELECT COUNT(*) FROM giangvien WHERE magv = :magv`,
      [magv]
    );
    await conn.close();
    const ok = result.rows[0][0] > 0;
    res.json({ success: ok, message: ok ? null : 'Mã giảng viên không tồn tại!' });
  } catch (err) {
    console.error(err);
    res.status(500).send('Lỗi server khi đăng nhập giảng viên');
  }
});

// 4) Đăng ký học viên mới
app.post('/register', async (req, res) => {
  const { mahv, hoten, ngaysinh, email } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    await conn.execute(
      `BEGIN prc_dangky_hocvien_moi(
         :mahv, :hoten,
         TO_DATE(:ngaysinh,'YYYY-MM-DD'),
         :email
       ); END;`,
      { mahv, hoten, ngaysinh, email }
    );
    await conn.commit(); await conn.close();
    res.json({ success: true, message: 'Đăng ký học viên thành công!' });
  } catch (err) {
    console.error(err);
    const msg = err.errorNum === 20001
      ? 'Email đã tồn tại!'
      : 'Lỗi đăng ký học viên!';
    res.json({ success: false, message: msg });
  }
});

// 5) Đăng ký khóa học cho học viên
app.post('/register-course', async (req, res) => {
  const { mahv, makh } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    console.log(mahv, makh);
    const binds = {
      mahv:    { dir: oracledb.BIND_IN,  val: mahv },
      makh:    { dir: oracledb.BIND_IN,  val: makh },
      message: { dir: oracledb.BIND_OUT}
    };
    
    const response =  await conn.execute(`BEGIN prc_dangky_khoahoc(:mahv, :makh, :message); END;`, binds,  { autoCommit: true }
    );
    console
    if (response.outBinds.message === "Đã đăng ký khóa học này.")
        throw new Error(response.outBinds.message)


    //   const lines = [];
  // let buff;
  // do {
  //   buff = await conn.getDbmsOutput();        // { line: string|null, done: boolean }
  //   if (buff.line !== null) lines.push(buff.line);
  // } while (!buff.done);
  // console.log(lines);

    await conn.commit(); await conn.close();
    res.json({ success: true, message: 'Đăng ký khóa học thành công!' });
  } catch (err) {
    console.error(err);
    res.json({ success: false, message: err.toString().slice(7) });
  }
});

// 6) Xem khóa học đã đăng ký
app.post('/my-courses', async (req, res) => {
  const { mahv } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `BEGIN :c := tim_khoahoc_dangky(:mahv); END;`,
      { c: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR }, mahv }
    );
    const rs   = result.outBinds.c;
    const rows = await rs.getRows();
    await rs.close(); await conn.close();
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Lỗi lấy khóa đã đăng ký');
  }
});

// 7) Lấy bài học của khóa
app.post('/course-lessons', async (req, res) => {
  const { makh } = req.body;
  try {
    const conn   = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `BEGIN :c := tim_baihoc_theo_khoahoc(:makh); END;`,
      { c: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR }, makh }
    );
    const rs      = result.outBinds.c;
    const lessons = await rs.getRows();
    await rs.close(); await conn.close();
    res.json(lessons);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// --- Forum: thread & comment ---

// 8) Tạo chủ đề (thread)
app.post('/create-topic', async (req, res) => {
  const { makh, tieude, noidung } = req.body;
  const madd = crypto.randomBytes(8).toString('hex').toUpperCase();
  try {
    const conn = await oracledb.getConnection(dbConfig);
    await conn.execute(
      `INSERT INTO diendan(madd, makh, tieude, ngay_thaoluan, noidung_thaoluan)
       VALUES(:madd, :makh, :tieude, SYSDATE, :noidung)`,
      { madd, makh, tieude, noidung }
    );
    await conn.execute(`INSERT INTO co(madd, makh) VALUES(:madd, :makh)`, { madd, makh });
    await conn.commit(); await conn.close();
    res.json({ success: true, madd });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// 9) Lấy chủ đề của khóa
app.post('/course-topics', async (req, res) => {
  const { makh } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `SELECT d.madd, d.tieude, d.ngay_thaoluan, d.noidung_thaoluan
         FROM diendan d
         JOIN co c ON c.madd = d.madd
        WHERE c.makh = :makh
        ORDER BY d.ngay_thaoluan DESC`,
      { makh }
    );
    await conn.close();
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});
// 13) Lấy tất cả chủ đề (diễn đàn chung)
app.get('/all-topics', async (req, res) => {
  try {
    const conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `SELECT d.madd, d.tieude, d.ngay_thaoluan, d.noidung_thaoluan
         FROM diendan d
        ORDER BY d.ngay_thaoluan DESC`
    );
    await conn.close();
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});


// 10) Gửi bình luận
app.post('/forum-comment', async (req, res) => {
  const { madd, mahv, noidung } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    await conn.execute(
      `INSERT INTO thamgia(madd, mantg, noidung, created_at)
       VALUES(:madd, :mahv, :noidung, SYSTIMESTAMP)`,
      { madd, mahv, noidung }
    );
    await conn.commit(); await conn.close();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message });
  }
});
// server.js

// 12) Tạo khóa học (giảng viên)
app.post('/create-course', async (req, res) => {
  const {
    makh, ten, ngaytao, ngaycapnhat,
    mota, trangthai, ngoaingu, chungchi
  } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    await conn.execute(`BEGIN DBMS_OUTPUT.ENABLE(NULL); END;`);
    await conn.execute(
      `BEGIN prc_tao_khoahoc(
         :makh, :ten,
         TO_DATE(:ngaytao,'YYYY-MM-DD'),
         TO_DATE(:ngaycapnhat,'YYYY-MM-DD'),
         :mota, :trangthai, :ngoaingu, :chungchi
       ); END;`,
      { makh, ten, ngaytao, ngaycapnhat, mota, trangthai, ngoaingu, chungchi }
    );
    const out = await conn.execute(
      `BEGIN DBMS_OUTPUT.GET_LINE(:line, :status); END;`,
      {
        line:   { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 32767 },
        status: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
      }
    );
    await conn.commit(); await conn.close();
    res.json({ success: true, message: out.outBinds.line });
  } catch (err) {
    console.error(err);
    res.json({ success: false, message: 'Lỗi tạo khóa học.' });
  }
});
// 14) Lấy bình luận của 1 chủ đề qua PL/SQL function show_binhluan
// Lấy bình luận của một chủ đề
app.post('/topic-comments', async (req, res) => {
  const { madd } = req.body;
  let conn;
  try {
    conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `BEGIN :c := show_binhluan(:madd); END;`,
      {
        c:    { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
        madd: { dir: oracledb.BIND_IN,  val: madd }
      }
    );
    const rs   = result.outBinds.c;
    const rows = await rs.getRows();    // <-- mảng thuần!
    await rs.close();
    console.log('⮕ rows bình luận:', rows);
    res.json(rows);                     // <-- chỉ gửi mảng rows
  } catch (err) {
    console.error('Error in /topic-comments:', err);
    res.status(500).json({ error: err.message });
  } finally {
    if (conn) await conn.close().catch(()=>{});
  }
});

// Cuối file chỉ gọi listen một lần
app.listen(PORT, () => {
  console.log(`✅ Server chạy tại http://localhost:${PORT}`);
});

// Lấy bài học của khóa
app.post('/course-lessons', async (req, res) => {
  const { makh } = req.body;
  try {
    const conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(
      `BEGIN :c := tim_baihoc_theo_khoahoc(:makh); END;`,
      { c: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR }, makh }
    );
    const rs      = result.outBinds.c;
    const lessons = await rs.getRows();
    await rs.close();
    await conn.close();
    res.json(lessons);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});


app.listen(PORT, () => {
  console.log(`✅ Server chạy tại http://localhost:${PORT}`);
});
app.use(express.static(__dirname));
app.listen(3000, '0.0.0.0', () => console.log('Server chạy 3000'));
