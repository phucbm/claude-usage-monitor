import type {Translations} from './en'

export const vi: Translations = {
  nav: {
    features: 'Tính năng',
    faq: 'FAQ',
    github: 'GitHub',
    download: 'Tải về',
  },
  hero: {
    badge: '/// ỨNG DỤNG MACOS MIỄN PHÍ & MÃ NGUỒN MỞ',
      description: 'Theo dõi lượng sử dụng Claude từ <strong>nhiều tài khoản</strong> ngay trên thanh menu bar của MacBook.',
    downloadBtn: '↓ Tải .dmg',
    githubBtn: 'Xem trên GitHub →',
      meta: 'Mã nguồn mở · Không cần tài khoản · Không lưu data của bạn',
    mockup: {
      live: '● TRỰC TIẾP',
      personal: 'Cá nhân',
      work: 'Công việc',
      session: 'Phiên',
      weekly: 'Tuần',
      resetsIn: 'Đặt lại sau',
      resetsMon: 'Đặt lại T2 9:00 SA',
      updated: 'Vừa cập nhật',
      randomize: 'Ngẫu nhiên →',
    },
  },
  ticker: [
      'NHIỀU TÀI KHOẢN', 'MÃ NGUỒN MỞ', 'MACBOOK',
      'KHÔNG LƯU DỮ LIỆU', 'SESSION & WEEKLY LIMITS',
      'MENUBAR',
  ],
  features: {
    heading: 'TÍNH NĂNG',
    count: '04 MODULE',
    items: [
      { id: '01', label: 'NHIỀU TÀI KHOẢN',   body: 'Theo dõi nhiều tài khoản Claude tùy ý — công việc, cá nhân, nhóm — mỗi tài khoản có vòng tròn và badge riêng trên thanh menu.' },
      { id: '02', label: 'MACBOOK MENUBAR',  body: 'Nằm trên thanh menu macOS. Một cú nhấp để mở bảng đầy đủ. Không có icon dock, không có cửa sổ, không ma sát.' },
      { id: '03', label: 'KHÔNG LƯU DỮ LIỆU',    body: 'Cookie phiên và dữ liệu sử dụng không bao giờ rời khỏi máy của bạn. Không phân tích, không đồng bộ đám mây, mãi mãi.' },
      { id: '04', label: 'MÃ NGUỒN MỞ',        body: 'Toàn bộ mã nguồn trên GitHub. Giấy phép MIT. Fork nó, kiểm tra nó, cải thiện nó — nó là của bạn.' },
    ],
  },
  howItWorks: {
    heading: 'HƯỚNG DẪN CÀI ĐẶT',
    count: '04 BƯỚC',
    steps: [
      {
        n: '01',
        title: 'MỞ CLAUDE USAGE TRÊN WEB',
        body: 'Truy cập claude.ai/settings/usage — đây là nơi Claude hiển thị giới hạn sử dụng của session hiện tại.',
      },
      {
        n: '02',
        title: 'MỞ TAB NETWORK TRONG DEVTOOLS',
        body: 'Nhấn Cmd+Option+I để mở Developer Tools, sau đó nhấp vào tab Network. Bật bộ lọc "Fetch/XHR".',
      },
      {
        n: '03',
        title: 'COPY COOKIE',
        body: 'Refresh trang, nhấp vào request trên "usage" trong danh sách, vào tab Headers, và sao chép toàn bộ giá trị "Cookie" từ Request Headers.',
      },
      {
        n: '04',
        title: 'THÊM TÀI KHOẢN VÀO ỨNG DỤNG',
        body: 'Mở Claude Usage Monitor từ thanh menu, nhấp "+ Add account", đặt tên gợi nhớ cho tài khoản, dán cookie vào, và nhấn Save Account.',
      },
    ],
  },
  faq: {
    heading: 'CÂU HỎI THƯỜNG GẶP',
    items: [
      { q: 'LÀM SAO THÊM TÀI KHOẢN?',             a: 'Mở ứng dụng, nhấp nút "+ Add account", dán cookie từ claude.ai vào, và đặt tên cho tài khoản. Lặp lại cho mỗi tài khoản bạn muốn theo dõi.' },
      { q: 'CÓ THEO DÕI NHIỀU TÀI KHOẢN ĐƯỢC KHÔNG?', a: 'Có — đó là tính năng cốt lõi. Thêm bao nhiêu tài khoản tùy ý (cá nhân, công việc, nhóm). Mỗi tài khoản có vòng tròn riêng và có thể hiển thị độc lập trên thanh menu.' },
      { q: 'LẤY COOKIE Ở ĐÂU?',              a: 'Vào claude.ai, mở DevTools (Cmd+Option+I), mở tab Network, làm mới trang, nhấp bất kỳ yêu cầu nào, và sao chép toàn bộ giá trị "Cookie" từ Request Headers.' },
      { q: 'DỮ LIỆU CỦA TÔI CÓ AN TOÀN KHÔNG?',   a: 'Cookie và dữ liệu sử dụng được lưu trữ cục bộ trên máy Mac của bạn. Không có gì được gửi đến bất kỳ máy chủ nào — không phải của chúng tôi, không phải của ai. Mã nguồn là công khai, hãy tự xác minh.' },
      { q: 'HAI VÒNG TRÒN CÓ Ý NGHĨA GÌ?',        a: 'Vòng ngoài theo dõi giới hạn sử dụng hàng tuần. Vòng trong theo dõi sử dụng phiên 5 giờ hiện tại. Cả hai đều hiển thị đếm ngược đến lần đặt lại tiếp theo.' },
      { q: 'CÓ HOẠT ĐỘNG VỚI CLAUDE CODE KHÔNG?',  a: 'Có. Lượng sử dụng Claude Code được tính vào cùng giới hạn tài khoản với claude.ai. Trình theo dõi hiển thị con số tổng hợp.' },
      { q: 'CÓ MIỄN PHÍ KHÔNG?',                  a: 'Hoàn toàn miễn phí, mãi mãi. Giấy phép MIT, mã nguồn mở, không có gói trả phí, không có đăng ký, không có gì ẩn.' },
    ],
  },
  cta: {
    heading: 'OWN YOUR\nLIMITS.',
    meta: 'Tải miễn phí · Không đăng ký · Mã nguồn mở',
    downloadBtn: '↓ Tải về cho macOS',
    githubBtn: 'GitHub →',
  },
  footer: {
    copyright: '© 2026 Claude Usage Monitor · Giấy phép MIT',
    releases: 'Phiên bản',
  },
}
