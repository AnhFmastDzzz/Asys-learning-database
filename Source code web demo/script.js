window.logout = function() {
  localStorage.removeItem('mahv');
  localStorage.removeItem('magv');
  location.reload();
};
document.addEventListener('DOMContentLoaded', () => {
  let currentCourseId = null;
  let currentLessonId = null;

  // Tham chiếu nhanh các phần tử
  const sidebar    = document.getElementById('sidebar');
  const forumBtn   = document.getElementById('forumBtn');
  const homeBtn    = document.getElementById('homeBtn');
  const forumSec   = document.getElementById('forumSection');
  const lessonSec  = document.getElementById('lessonSection');
  const resultsTbl = document.getElementById('results').parentElement;
  const topicList  = document.getElementById('topicList');
  const helpBtn = document.getElementById('helpBtn');
const helpSec = document.getElementById('helpSection');
  // ── Sidebar: nút Diễn đàn
  // ── Sidebar: nút Diễn đàn
  if (helpBtn) {
    helpBtn.addEventListener('click', () => {
      helpSec.style.display = 'block';
      lessonSec.style.display = 'none';
      forumSec.style.display = 'none';
      resultsTbl.style.display = 'none';
    });
  }
  
  // Nội dung trợ giúp
  const helpData = {
    q1: [
      "Nhấn nút 'Thanh toán' ở khóa học bạn chọn.",
      "Chọn hình thức: chuyển khoản, ví điện tử...",
      "Xác nhận và hoàn tất thanh toán."
    ],
    q2: [
      "Chuyển khoản ngân hàng",
      "Ví điện tử Momo, ZaloPay",
      "Thẻ ATM nội địa có Internet Banking"
    ],
    q3: [
      "Kiểm tra email xác nhận giao dịch.",
      "Đăng nhập lại để làm mới danh sách.",
      "Liên hệ hỗ trợ nếu sau 15 phút chưa thấy khóa học."
    ]
  };
  
  // Bắt sự kiện khi click vào câu hỏi
  document.querySelectorAll('.help-question').forEach(item => {
    item.style.cursor = 'pointer';
    item.style.padding = '8px';
    item.addEventListener('click', () => {
      const id = item.dataset.id;
      const list = helpData[id];
      const ansBox = document.getElementById('helpAnswer');
      ansBox.innerHTML = `<h4 style="color:#333;">Trả lời:</h4><ul>${list.map(i => `<li>${i}</li>`).join('')}</ul>`;
    });
  });
if (forumBtn) {
  forumBtn.addEventListener('click', () => {
    window.location.href = 'forum.html';
  });
  
}

  // ── Sidebar: nút Trang chủ
  if (homeBtn) {
    homeBtn.addEventListener('click', () => {
      // Ẩn diễn đàn và bài học
      forumSec.style.display    = 'none';
      lessonSec.style.display   = 'none';
      // Hiện lại bảng kết quả
      resultsTbl.style.display  = '';
    });
  }

  // ── 1) Login học viên
  document.getElementById('loginHvBtn').addEventListener('click', async () => {
    const mahv = document.getElementById('mahvInput').value.trim();
    if (!mahv) return alert('Vui lòng nhập mã học viên!');
    const res  = await fetch('/login',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ mahv })
    });
    const data = await res.json();
    if (data.success) {
      localStorage.setItem('mahv', mahv);
      checkLogin();
    } else {
      alert(data.message || 'Đăng nhập thất bại!');
    }
  });

  // ── 2) Login giảng viên
  document.getElementById('loginGvBtn').addEventListener('click', async () => {
    const magv = document.getElementById('magvInput').value.trim();
    if (!magv) return alert('Vui lòng nhập mã giảng viên!');
    const res  = await fetch('/login-gv',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ magv })
    });
    const data = await res.json();
    if (data.success) {
      localStorage.setItem('magv', magv);
      checkLogin();
    } else {
      alert(data.message || 'Đăng nhập thất bại!');
    }
  });

  // ── 3) Đăng ký học viên
  document.getElementById('registerBtn').addEventListener('click', async () => {
    const mahv     = document.getElementById('regMahv').value.trim();
    const hoten    = document.getElementById('regHoten').value.trim();
    const ngaysinh = document.getElementById('regNgaysinh').value;
    const email    = document.getElementById('regEmail').value.trim();
    const msgE     = document.getElementById('registerResult');
    if (!mahv || !hoten || !ngaysinh || !email) {
      msgE.style.color = 'red'; msgE.textContent = 'Nhập đầy đủ thông tin!';
      return;
    }
    try {
      const res  = await fetch('/register',{
        method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ mahv, hoten, ngaysinh, email })
      });
      const data = await res.json();
      msgE.style.color = data.success ? 'green' : 'red';
      msgE.textContent = data.message;
    } catch (e) {
      console.error(e);
      msgE.style.color = 'red'; msgE.textContent = 'Lỗi kết nối.';
    }
  });

  // ── 4) Tìm khóa học
  document.getElementById('searchBtn').addEventListener('click', async () => {
    const kw  = document.getElementById('searchInput').value.trim();
    const res = await fetch('/search',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ keyword: kw })
    });
    const courses = await res.json();
    const tb      = document.getElementById('results');
    tb.innerHTML  = '';
    const dbg     = document.getElementById('debugMessage');
    if (!courses.length) {
      dbg.textContent = 'Không tìm thấy khóa nào.';
      return;
    }
    dbg.textContent = `Tìm thấy ${courses.length} khóa.`;
    courses.forEach(c => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${c[0]}</td>
        <td>${c[1]}</td>
        <td>${c[2]}</td>
        <td><button class="regBtn" data-makh="${c[0]}">Đăng ký</button></td>`;
      tb.appendChild(row);
    });
    document.querySelectorAll('.regBtn').forEach(btn => {
      btn.addEventListener('click', async () => {
        const mahv = localStorage.getItem('mahv');
        if(!mahv) return alert('Chưa đăng nhập!');
        const makh = btn.dataset.makh;
        const r    = await fetch('/register-course',{
          method:'POST', headers:{'Content-Type':'application/json'},
          body: JSON.stringify({ mahv, makh })
        });
        const d    = await r.json();
        dbg.style.color = d.success ? 'green' : 'red';
        dbg.textContent = d.message;
      });
    });
  });

  // ── 5) Xem khóa đã đăng ký
  document.getElementById('viewMyCoursesBtn').addEventListener('click', async () => {
    const mahv = localStorage.getItem('mahv');
    if (!mahv) return alert('Chưa đăng nhập!');
    const res = await fetch('/my-courses',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ mahv })
    });
    const courses = await res.json();
    const tb      = document.getElementById('results');
    tb.innerHTML  = '';
    const dbg     = document.getElementById('debugMessage');
    if (!courses.length) {
      dbg.style.color   = 'red';
      dbg.textContent   = 'Chưa đăng ký khóa nào.';
      return;
    }
    dbg.style.color = 'green';
    dbg.textContent = `Bạn đã đăng ký ${courses.length} khóa.`;
    courses.forEach(c => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${c[0]}</td>
        <td>${c[1]}</td>
        <td>${c[2]}</td>
        <td><button class="btn-view-course" data-makh="${c[0]}">Vào học</button></td>`;
      tb.appendChild(row);
    });
  });

  // ── 6) Click “Vào học”
  document.addEventListener('click', async e => {
    if (!e.target.classList.contains('btn-view-course')) return;
    currentCourseId = e.target.dataset.makh;
    // show lesson
    lessonSec.style.display = 'flex';
    // show forum
    //forumSec.style.display  = 'block';
    // load bài & chủ đề
    console.log("vao hoc");
    //loadTopics();
    // (và bạn có thể gọi thêm loadLessons nếu cần)
    await loadLessons();
  });

  // ── Hàm loadTopics
  async function loadTopics() {
    topicList.innerHTML = 'Loading...';
    const res = await fetch('/course-topics',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ makh: currentCourseId })
    });
    const ts = await res.json();
    topicList.innerHTML = '';
    ts.forEach(([madd, tieude, ngay, noidung]) => {
      const div = document.createElement('div');
      div.innerHTML = `
        <h5>${tieude}</h5>
        <small>${new Date(ngay).toLocaleString()}</small>
        <p>${noidung}</p>
        <button class="btn-view-comments" data-madd="${madd}">Xem bình luận</button>
        <div id="comments-${madd}" style="margin-left:20px;display:none;"></div>
        <hr>`;
      topicList.appendChild(div);
    });
  }
 // 1) Định nghĩa loadLessons
// 1. Hàm hiện chi tiết bài học
function showLessonDetail(title, mota) {
  document.getElementById('lessonTitle').textContent = title;
  // hoặc .innerHTML = `<p>${mota}</p>` nếu bạn cần HTML trong mota
  document.getElementById('lessonIntro').textContent = mota;
  // hiện phần Hỏi đáp
  //document.getElementById('qaSection').style.display = 'block';
}

// 2. Hàm load danh sách bài học
async function loadLessons() {
  // 1) Gọi API lấy bài học
  const res = await fetch('http://localhost:3000/course-lessons', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ makh: currentCourseId })
  });
  const lessons = await res.json();  // mảng [ [mabh, ten, mota, ...], ... ]

  // 2) Lấy 2 container: list & detail
  const ul        = document.querySelector('#lessonList ul');
  const detailDiv = document.getElementById('lessonDetail');

  // 3) Reset nội dung cũ
  ul.innerHTML        = '';
  detailDiv.innerHTML = '';

  // 4) Duyệt từng bài, thêm vào list và detail
  lessons.forEach(([mabh, ten, mota]) => {
    // 4.1 Tạo <li> cho tiêu đề bên trái
    const li = document.createElement('li');
    li.textContent = ten;
    li.style.cursor = 'pointer';
    ul.appendChild(li);

    // 4.2 Tạo block mô tả bên phải
    const block = document.createElement('div');
    block.classList.add('lesson-block');
    block.innerHTML = `
      <h4 style="margin-bottom:8px; color: var(--primary);">${ten}</h4>
      <p style="margin-bottom: 16px;">${mota}</p>
      <hr>`;
    detailDiv.appendChild(block);

    // 4.3 (Tùy chọn) click vào li chỉ highlight block tương ứng
    li.addEventListener('click', () => {
      // cuộn đến block tương ứng
      block.scrollIntoView({ behavior: 'smooth' });
      // bạn cũng có thể thêm class active để tô nền block
    });
  });
}

// 2) Trong chỗ xử lý click “Vào học”, gọi cả 2 hàm:
document.addEventListener('click', async e => {
  if (!e.target.classList.contains('btn-view-course')) return;
  currentCourseId = e.target.dataset.makh;
  // hiện giao diện bài học & diễn đàn
  //lessonSec.style.display = 'flex';
  //forumSec.style.display  = 'block';

  //loadTopics();   // đã có
  loadLessons();  // thêm vào để load bài học
});

  
  // ── Toggle & post comment
  forumSec.addEventListener('click', async ev => {
    if (ev.target.classList.contains('btn-view-comments')) {
      const madd = ev.target.dataset.madd;
      const sec  = document.getElementById(`comments-${madd}`);
      sec.style.display = sec.style.display==='none'?'block':'none';
      if (sec.style.display==='block') {
        const r  = await fetch('/topic-comments',{
          method:'POST', headers:{'Content-Type':'application/json'},
          body: JSON.stringify({ madd })
        });
        const cs = await r.json();
        sec.innerHTML = cs.map(([u, txt, dt]) =>
          `<p><strong>${u}</strong> (${new Date(dt).toLocaleString()}): ${txt}</p>`
        ).join('') + `
          <textarea id="newComment-${madd}" rows="2" style="width:100%;"></textarea>
          <button class="btn-post-comment" data-madd="${madd}">Gửi bình luận</button>
        `;
      }
    }
    if (ev.target.classList.contains('btn-post-comment')) {
      const madd = ev.target.dataset.madd;
      const ta   = document.getElementById(`newComment-${madd}`);
      const txt  = ta.value.trim(); if (!txt) return;
      await fetch('/forum-comment',{
        method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ madd, mahv: localStorage.getItem('mahv'), noidung: txt })
      });
      loadTopics();
    }
  });

  // ── 7) Tạo khóa học (giảng viên)…
  document.getElementById('createCourseBtn').addEventListener('click', async () => {
    // … giữ nguyên code cũ …
  });

  // ── Hàm checkLogin
  function checkLogin() {
    const mahv = localStorage.getItem('mahv');
    const magv = localStorage.getItem('magv');

    // Show / hide sidebar
    if (sidebar) sidebar.classList.toggle('visible', !!mahv);

    if (mahv) {
      // hiển thị giao diện học viên
      document.getElementById('loginSection').style.display    = 'none';
      document.getElementById('registerSection').style.display = 'none';
      document.getElementById('mainSection').style.display     = 'block';
      document.getElementById('gvSection').style.display       = 'none';
      document.getElementById('welcomeMsg').textContent        = `Xin chào, học viên: ${mahv}`;
    } else if (magv) {
      // hiển thị giao diện giảng viên
      document.getElementById('loginSection').style.display    = 'none';
      document.getElementById('registerSection').style.display = 'none';
      document.getElementById('mainSection').style.display     = 'none';
      document.getElementById('gvSection').style.display       = 'block';
      document.getElementById('gvWelcomeMsg').textContent      = `Mã giảng viên: ${magv}`;
    } else {
      // chưa login
      document.getElementById('loginSection').style.display    = 'block';
      document.getElementById('registerSection').style.display = 'block';
      document.getElementById('mainSection').style.display     = 'none';
      document.getElementById('gvSection').style.display       = 'none';
    }
  }

  // Chạy kiểm tra login ngay khi load
  checkLogin();
});
