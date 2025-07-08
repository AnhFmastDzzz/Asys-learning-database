// forum.js

function goHome() {
    window.location.href = 'index.html';
  }
  
  document.addEventListener('DOMContentLoaded', () => {
    const topicsDiv = document.getElementById('topicsList');
  
    // 1. Load toàn bộ chủ đề
    async function loadTopics() {
      topicsDiv.innerHTML = '<p>Đang tải diễn đàn…</p>';
      try {
        const res = await fetch('/all-topics');
        if (!res.ok) {
          const text = await res.text();
          throw new Error(`HTTP ${res.status}: ${text}`);
        }
        const topics = await res.json();
        topicsDiv.innerHTML = '';
        topics.forEach(([madd, tieude, ngay, noidung]) => {
          const div = document.createElement('div');
          div.className = 'topic';
          div.innerHTML = `
            <h3>${tieude}</h3>
            <small>${new Date(ngay).toLocaleString()}</small>
            <p>${noidung}</p>
            <button data-madd="${madd}" class="btn-view-comments btn">Xem bình luận</button>
            <div id="comments-${madd}" class="comment-list" style="display:none; margin-top:10px;"></div>
            <hr>
          `;
          topicsDiv.appendChild(div);
        });
      } catch (err) {
        console.error('Lỗi loadTopics:', err);
        topicsDiv.innerHTML = `<p style="color:red;">Lỗi tải diễn đàn: ${err.message}</p>`;
      }
    }
  
    // 2. Xem & gửi bình luận
    topicsDiv.addEventListener('click', async ev => {
      const target = ev.target;
  
      // 2.1 Xem/ẩn bình luận
      if (target.classList.contains('btn-view-comments')) {
        const madd = target.dataset.madd;
        const commentDiv = document.getElementById(`comments-${madd}`);
        const isHidden = commentDiv.style.display === 'none';
        commentDiv.style.display = isHidden ? 'block' : 'none';
  
        if (isHidden && !commentDiv.innerHTML.trim()) {
          commentDiv.innerHTML = '<p>Đang tải bình luận…</p>';
          try {
            const r = await fetch('/topic-comments', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ madd })
            });
            if (!r.ok) {
              const text = await r.text();
              throw new Error(`HTTP ${r.status}: ${text}`);
            }
            const comments = await r.json();
            // Hiển thị comment và form gửi mới
        //     commentDiv.innerHTML = comments.map(
        //       ([u, txt, dt]) =>
        //         `<p><strong>${u}</strong> (${new Date(dt).toLocaleString()}): ${txt}</p>`
        //     ).join('') + `
        //       <textarea id="newComment-${madd}" rows="2" style="width:100%; margin-top:8px;"></textarea>
        //       <button class="btn-post-comment btn" data-madd="${madd}" style="margin-top:4px;">Gửi bình luận</button>
        //     `;
        //   
        } 
        catch (err) {
            console.error('Lỗi fetch topic-comments:', err);
            commentDiv.innerHTML = `<p style="color:red;">Lỗi tải bình luận: ${err.message}</p>`;
          }
        }
      }
  
      // 2.2 Gửi bình luận mới
      if (target.classList.contains('btn-post-comment')) {
        const madd = target.dataset.madd;
        const ta   = document.getElementById(`newComment-${madd}`);
        const txt  = ta.value.trim();
        if (!txt) {
          alert('Nhập nội dung bình luận!');
          return;
        }
        try {
          const r = await fetch('/forum-comment', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              madd,
              mahv: localStorage.getItem('mahv'),
              noidung: txt
            })
          });
          if (!r.ok) {
            const text = await r.text();
            throw new Error(`HTTP ${r.status}: ${text}`);
          }
          const result = await r.json();
          if (!result.success) {
            throw new Error(result.error || 'Server trả về success=false');
          }
          ta.value = '';
          // Reload lại bình luận
          commentDiv = document.getElementById(`comments-${madd}`);
          commentDiv.style.display = 'none';
          target.closest('.topic').querySelector('.btn-view-comments').click();
          target.closest('.topic').querySelector('.btn-view-comments').click();
        } catch (err) {
          console.error('Lỗi fetch forum-comment:', err);
          alert(`Gửi bình luận thất bại: ${err.message}`);
        }
      }
    });
  
    // 3. Khởi động
    loadTopics();
  });
      