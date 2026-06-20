export interface SQLTable {
  name: string;
  description: string;
  ddl: string;
}

export const sqliteTables: SQLTable[] = [
  {
    name: 'users',
    description: 'جدول المستخدمين لتسجيل الدخول وإسناد الصلاحيات (مدير / موظف استقبال).',
    ddl: `CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK(role IN ('admin', 'receptionist')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);`
  },
  {
    name: 'apartments',
    description: 'جدول الشقق لتخزين مواصفات كل شقة، أسعارها وحالتها الحالية بشكل مستقل.',
    ddl: `CREATE TABLE IF NOT EXISTS apartments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  rooms_count INTEGER NOT NULL CHECK(rooms_count > 0),
  beds_count INTEGER NOT NULL CHECK(beds_count > 0),
  nightly_price REAL NOT NULL CHECK(nightly_price >= 0),
  notes TEXT,
  images TEXT, -- يتم تخزين مسارات الصور كسلسلة JSON نصية (مثل: ["path1.jpg", "path2.jpg"])
  status TEXT NOT NULL CHECK(status IN ('available', 'occupied', 'cleaning', 'maintenance')) DEFAULT 'available'
);`
  },
  {
    name: 'guests',
    description: 'جدول الزبائن لحفظ سجل الهوية والبيانات الشخصية لجميع النزلاء.',
    ddl: `CREATE TABLE IF NOT EXISTS guests (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL_OR_EMPTY,
  id_card_number TEXT NOT NULL UNIQUE,
  nationality TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);`
  },
  {
    name: 'bookings',
    description: 'جدول الحجوزات يربط الزبون بالشقة مع مواعيد الدخول والخروج مع الحساب المالي.',
    ddl: `CREATE TABLE IF NOT EXISTS bookings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  booking_number TEXT NOT NULL UNIQUE,
  guest_id INTEGER NOT NULL,
  apartment_id INTEGER NOT NULL,
  check_in_date TEXT NOT NULL,  -- صيغة ISO (YYYY-MM-DD) لسهولة المقارنة
  check_out_date TEXT NOT NULL, -- صيغة ISO (YYYY-MM-DD) لسهولة المقارنة
  nights_count INTEGER NOT NULL CHECK(nights_count > 0),
  total_price REAL NOT NULL CHECK(total_price >= 0),
  paid_amount REAL NOT NULL CHECK(paid_amount >= 0) DEFAULT 0,
  remaining_amount REAL GENERATED ALWAYS AS (total_price - paid_amount) STORED, -- حساب تلقائي للمبلغ المتبقي
  status TEXT NOT NULL CHECK(status IN ('confirmed', 'pending_arrival', 'checked_in', 'completed', 'cancelled')) DEFAULT 'confirmed',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE RESTRICT,
  FOREIGN KEY (apartment_id) REFERENCES apartments(id) ON DELETE RESTRICT
);`
  },
  {
    name: 'backups',
    description: 'جدول أرشفة النسخ الاحتياطية لمتابعة عمليات الحفظ والاسترجاع محلياً.',
    ddl: `CREATE TABLE IF NOT EXISTS backups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  backup_size INTEGER, -- بحجم الكيلوبايت
  created_by INTEGER,
  FOREIGN KEY (created_by) REFERENCES users(id)
);`
  }
];

export const sqliteIndexes: string[] = [
  `-- تسريع البحث عن الحجوزات حسب تاريخ الدخول والخروج ومنع التداخل البيني`,
  `CREATE INDEX IF NOT EXISTS idx_bookings_dates ON bookings(check_in_date, check_out_date);`,
  `-- تسريع البحث عن الشقة`,
  `CREATE INDEX IF NOT EXISTS idx_bookings_apartment ON bookings(apartment_id);`,
  `-- تسريع البحث عن الزبائن بالاسم ورقم الهوية والهاتف`,
  `CREATE INDEX IF NOT EXISTS idx_guests_search ON guests(full_name, id_card_number, phone);`
];

export const doubleBookingValidationQuery = `
-- استعلام منع الحجز المزدوج لنفس الشقة في نفس الفترة المحددة
-- نتحقق من وجود أي حجز متداخل وغير ملغى للشقة المطلوبة
SELECT COUNT(*) FROM bookings 
WHERE apartment_id = :apartment_id 
  AND status != 'cancelled'
  AND (
    (check_in_date < :new_checkout_date AND check_out_date > :new_checkin_date)
  );
`;
