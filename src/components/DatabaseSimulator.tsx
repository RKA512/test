import React, { useState, useEffect } from 'react';
import { 
  BarChart3, Calendar as CalendarIcon, Users, Home, ClipboardList, 
  Share2, Shield, Plus, Search, Trash2, Check, X, FileText, 
  Download, Database, Key, CheckCircle, RefreshCw, AlertTriangle
} from 'lucide-react';
import { Apartment, Booking, Guest, BookingStatus, ApartmentStatus, UserRole, Expense } from '../types/rental';
import { TimelineCalendar } from './TimelineCalendar';
import { FinancialWorkspace } from './FinancialWorkspace';

export const DatabaseSimulator: React.FC = () => {
  // --- Core Simulated State ---
  const [apartments, setApartments] = useState<Apartment[]>(() => {
    const saved = localStorage.getItem('rental_apartments');
    return saved ? JSON.parse(saved) : [
      { id: '1', name: 'شقة 101 (دوبلكس)', roomsCount: 3, bedsCount: 4, nightlyPrice: 8500, notes: 'شقة عائلية هادئة مجهزة بتكييف كامل وإطلالة متميزة.', images: [], status: 'occupied' },
      { id: '2', name: 'شقة 102 (مطلة)', roomsCount: 2, bedsCount: 3, nightlyPrice: 6000, notes: 'إطلالة جانبية، مثالية للأزواج.', images: [], status: 'available' },
      { id: '3', name: 'شقة 103 (وسطية)', roomsCount: 2, bedsCount: 2, nightlyPrice: 5500, notes: 'قريبة من المصنع، مفروشة بالكامل.', images: [], status: 'cleaning' },
      { id: '4', name: 'شقة 201 (رئيسية)', roomsCount: 4, bedsCount: 6, nightlyPrice: 12000, notes: 'شقة فخمة مكيفة بالكامل، صالون تركي.', images: [], status: 'available' },
      { id: '5', name: 'شقة 202 (اقتصادية)', roomsCount: 1, bedsCount: 2, nightlyPrice: 4000, notes: 'سعر مناسب جداً، مجهزة بضروريات الطبخ.', images: [], status: 'maintenance' },
      { id: '6', name: 'شقة 203 (شرفة)', roomsCount: 3, bedsCount: 4, nightlyPrice: 7500, notes: 'تحتوي على شرفة واسعة مطلة على البحر.', images: [], status: 'available' },
    ];
  });

  const [guests, setGuests] = useState<Guest[]>(() => {
    const saved = localStorage.getItem('rental_guests');
    return saved ? JSON.parse(saved) : [
      { id: '1', fullName: 'أحمد زكريا رفيس', phone: '0555123456', idCardNumber: '192837465012', nationality: 'جزائرية', notes: 'نزيل دائم وموثوق، يحب الطوابق العليا.' },
      { id: '2', fullName: 'ياسين بن علي', phone: '0661987654', idCardNumber: '109283746500', nationality: 'جزائرية', notes: 'يطلب غالباً مفتاح إضافي للسيارة.' },
      { id: '3', fullName: 'أمينة بلقاسم', phone: '0772345678', idCardNumber: '293847561029', nationality: 'تونسية', notes: 'تفضل شقق الشرفة.' },
    ];
  });

  const [bookings, setBookings] = useState<Booking[]>(() => {
    const saved = localStorage.getItem('rental_bookings');
    return saved ? JSON.parse(saved) : [
      { id: '1', bookingNumber: 'B-2026-101', guestId: '1', apartmentId: '1', checkInDate: '2026-05-30', checkOutDate: '2026-06-03', nightsCount: 4, totalPrice: 34000, paidAmount: 34000, remainingAmount: 0, status: 'checked_in', notes: 'تم تسليم المفاتيح بعد فحص الهوية.' },
      { id: '2', bookingNumber: 'B-2026-102', guestId: '2', apartmentId: '4', checkInDate: '2026-06-01', checkOutDate: '2026-06-05', nightsCount: 4, totalPrice: 48000, paidAmount: 20000, remainingAmount: 28000, status: 'confirmed', notes: 'دفع عربون تأكيدي 20,000 د.ج.' },
      { id: '3', bookingNumber: 'B-2026-103', guestId: '3', apartmentId: '6', checkInDate: '2026-06-07', checkOutDate: '2026-06-12', nightsCount: 5, totalPrice: 37500, paidAmount: 0, remainingAmount: 37500, status: 'pending_arrival', notes: 'حجز قيد تأطير الوصول للزبونة.' },
    ];
  });

  const [backups, setBackups] = useState<Array<{ id: string; name: string; date: string; size: string }>>(() => {
    const saved = localStorage.getItem('rental_backups');
    return saved ? JSON.parse(saved) : [
      { id: 'BK-1', name: 'قاعدة_بيانات_حجوزات_أولية.db', date: '2026-05-25 10:20', size: '1.24 MB' },
      { id: 'BK-2', name: 'نسخة_تأكيدية_أسبوعية.db', date: '2026-05-29 18:45', size: '1.31 MB' }
    ];
  });

  const [expenses, setExpenses] = useState<Expense[]>(() => {
    const saved = localStorage.getItem('rental_expenses');
    return saved ? JSON.parse(saved) : [
      { id: 'E-1', amount: 4500, date: '2026-05-28', category: 'maintenance', notes: 'إصلاح تسرب مياه الحمام وتغيير الحنفية', apartmentId: '1' },
      { id: 'E-2', amount: 1500, date: '2026-05-29', category: 'cleaning', notes: 'اقتناء مواد تنظيف الشقة ومطهّرات', apartmentId: '2' },
      { id: 'E-3', amount: 8000, date: '2026-05-30', category: 'bills', notes: 'تسديد فاتورة الكهرباء لشهر أفريل', apartmentId: '4' },
      { id: 'E-4', amount: 25000, date: '2026-05-25', category: 'furniture', notes: 'شراء مكرويف جديد للمطبخ وسخان ماء', apartmentId: '1' },
      { id: 'E-5', amount: 3000, date: '2026-06-01', category: 'other', notes: 'شراء مفاتيح وإكسسوارات أبواب جديدة' }
    ];
  });

  // --- Sync State to LocalStorage ---
  useEffect(() => {
    localStorage.setItem('rental_apartments', JSON.stringify(apartments));
  }, [apartments]);

  useEffect(() => {
    localStorage.setItem('rental_guests', JSON.stringify(guests));
  }, [guests]);

  useEffect(() => {
    localStorage.setItem('rental_bookings', JSON.stringify(bookings));
  }, [bookings]);

  useEffect(() => {
    localStorage.setItem('rental_backups', JSON.stringify(backups));
  }, [backups]);

  useEffect(() => {
    localStorage.setItem('rental_expenses', JSON.stringify(expenses));
  }, [expenses]);

  // --- UI Control State ---
  const [activeTab, setActiveTab] = useState<'dash' | 'calendar' | 'payments' | 'bookings' | 'apartments' | 'guests' | 'backups'>('dash');
  const [currentRole, setCurrentRole] = useState<UserRole>('admin');
  const [searchQuery, setSearchQuery] = useState<string>('');
  
  // Feedback Messages
  const [notice, setNotice] = useState<{ type: 'success' | 'error' | 'info'; text: string } | null>(null);

  // Forms State
  const [showBookingForm, setShowBookingForm] = useState<boolean>(false);
  const [newBooking, setNewBooking] = useState({
    apartmentId: '',
    guestId: '',
    checkInDate: '',
    checkOutDate: '',
    paidAmount: '0',
    notes: '',
    personsCount: '1',
  });

  // Unique client customization states
  const [bookingGuestMode, setBookingGuestMode] = useState<'select' | 'custom'>('custom');
  const [customGuestName, setCustomGuestName] = useState<string>('');
  const [customGuestPhone, setCustomGuestPhone] = useState<string>('');
  const [customGuestIdCard, setCustomGuestIdCard] = useState<string>('');
  const [customGuestNationality, setCustomGuestNationality] = useState<string>('جزائرية');
  const [customNightlyPrice, setCustomNightlyPrice] = useState<string>('');
  const [customTotalPrice, setCustomTotalPrice] = useState<string>('');
  const [numNightsState, setNumNightsState] = useState<string>('1');

  // Inner state for adding custom payments in the Payments Tab
  const [addingAmounts, setAddingAmounts] = useState<Record<string, string>>({});

  // Financial Sub-system Tabs & Forms
  const [paymentsSubTab, setPaymentsSubTab] = useState<'invoices' | 'expenses' | 'reports'>('invoices');
  const [showExpenseForm, setShowExpenseForm] = useState<boolean>(false);
  const [newExpense, setNewExpense] = useState({
    amount: '',
    date: '2026-06-01', // Matches metadata local time June 2026
    category: 'maintenance' as 'maintenance' | 'cleaning' | 'bills' | 'furniture' | 'other',
    notes: '',
    apartmentId: '',
  });

  // Financial Study & Reporting Filter States
  const [reportFilterType, setReportFilterType] = useState<'day' | 'month' | 'year' | 'custom'>('month');
  const [reportFilterDay, setReportFilterDay] = useState<string>('2026-06-01');
  const [reportFilterMonth, setReportFilterMonth] = useState<string>('2026-06');
  const [reportFilterYear, setReportFilterYear] = useState<string>('2026');
  const [reportFilterStartDate, setReportFilterStartDate] = useState<string>('2026-05-01');
  const [reportFilterEndDate, setReportFilterEndDate] = useState<string>('2026-06-30');

  // Dynamic system-wide custom colors with local persistence
  const [customColors, setCustomColors] = useState<Record<string, string>>(() => {
    const saved = localStorage.getItem('sqlite_rental_custom_colors');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {}
    }
    return {
      confirmed: '#3b82f6',      // default blue
      pending_arrival: '#f59e0b', // default amber
      checked_in: '#059669',      // default emerald-600
      completed: '#6b7280',       // default slate-500
      cancelled: '#ef4444',       // default rose-500
      paid_full: '#059669',       // default emerald-600
      paid_partial: '#f59e0b',    // default amber
      paid_none: '#ef4444',       // default rose-500
    };
  });

  const handleUpdateColor = (key: string, value: string) => {
    setCustomColors(prev => {
      const updated = { ...prev, [key]: value };
      localStorage.setItem('sqlite_rental_custom_colors', JSON.stringify(updated));
      return updated;
    });
  };

  const [showAptForm, setShowAptForm] = useState<boolean>(false);
  const [newApt, setNewApt] = useState({
    name: '',
    roomsCount: '2',
    bedsCount: '2',
    nightlyPrice: '5000',
    notes: '',
  });
  const [editingApt, setEditingApt] = useState<Apartment | null>(null);

  const [showGuestForm, setShowGuestForm] = useState<boolean>(false);
  const [newGuest, setNewGuest] = useState({
    fullName: '',
    phone: '',
    idCardNumber: '',
    nationality: 'جزائرية',
    notes: '',
  });

  // Trigger Local Alerts
  const triggerAlert = (type: 'success' | 'error' | 'info', text: string) => {
    setNotice({ type, text });
    setTimeout(() => setNotice(null), 5000);
  };

  // --- Helper Functions ---
  const getGuestDetails = (guestId: string) => guests.find(g => g.id === guestId);
  const getApartmentDetails = (apartmentId: string) => apartments.find(a => a.id === apartmentId);

  // --- Logic Checks (Overlapping Checker) ---
  const checkOverlappingBookings = (apartmentId: string, checkIn: string, checkOut: string, excludeBookingId?: string) => {
    // Return true if overlapping occurs
    return bookings.some(b => {
      if (b.apartmentId !== apartmentId) return false;
      if (b.status === 'cancelled') return false; // Cancelled bookings don't block dates
      if (excludeBookingId && b.id === excludeBookingId) return false;
      
      // Overlap condition logic: (StartA < EndB) and (EndA > StartB)
      return (checkIn < b.checkOutDate && checkOut > b.checkInDate);
    });
  };

  // Create Booking Action
  const handleCreateBooking = (e: React.FormEvent) => {
    e.preventDefault();
    let { apartmentId, guestId, checkInDate, checkOutDate, paidAmount, notes, personsCount } = newBooking;

    if (!apartmentId || !checkInDate || !checkOutDate) {
      triggerAlert('error', 'الرجاء ملء جميع الحقول المطلوبة لإنشاء حجز صحيح.');
      return;
    }

    const personsVal = personsCount ? parseInt(personsCount) : 1;
    if (personsCount && (isNaN(personsVal) || personsVal <= 0)) {
      triggerAlert('error', 'يرجى إدخال عدد أشخاص صحيح أكبر من الصفر.');
      return;
    }

    if (bookingGuestMode === 'custom') {
      if (!customGuestName.trim()) {
        triggerAlert('error', 'سجل الزبون الجديد يتطلب إدخال الاسم على الأقل.');
        return;
      }
      // Create guest automatically
      const newGuestId = 'G-' + Date.now();
      const customGuestObj: Guest = {
        id: newGuestId,
        fullName: customGuestName.trim(),
        phone: customGuestPhone.trim() || 'غير مدرج',
        idCardNumber: customGuestIdCard.trim() || 'غير مدرجة',
        nationality: customGuestNationality.trim() || 'جزائرية',
        notes: 'تم تسجيل الزبون يدوياً أثناء إضافة الحجز.',
      };
      setGuests(prevGuests => [...prevGuests, customGuestObj]);
      guestId = newGuestId;
    } else {
      if (!guestId) {
        triggerAlert('error', 'الرجاء تحديد الزبون/النزيل لإتمام العملية.');
        return;
      }
    }

    if (checkInDate >= checkOutDate) {
      triggerAlert('error', 'يجب أن يكون تاريخ المغادرة لاحقاً لتاريخ الوصول.');
      return;
    }

    // SQLite overlap query simulated locally
    const isOverlapping = checkOverlappingBookings(apartmentId, checkInDate, checkOutDate);
    if (isOverlapping) {
      triggerAlert('error', '⚠️ تنبيه ازدواجية: الشقة محجوزة مسبقاً خلال الفترات المحددة. تم إيقاف الحجز محلياً لمنع التداخل البيني!');
      return;
    }

    const apt = getApartmentDetails(apartmentId);
    if (!apt) return;

    const checkInTime = new Date(checkInDate).getTime();
    const checkOutTime = new Date(checkOutDate).getTime();
    const nights = Math.max(1, Math.round((checkOutTime - checkInTime) / (1000 * 60 * 60 * 24)));
    
    // Support customized pricing with fully manual overrides
    const finalRate = parseFloat(customNightlyPrice) >= 0 ? parseFloat(customNightlyPrice) : apt.nightlyPrice;
    const total = parseFloat(customTotalPrice) >= 0 ? parseFloat(customTotalPrice) : (finalRate * nights);
    const paid = parseFloat(paidAmount) || 0;

    const bNumber = `B-2026-${Math.floor(100 + Math.random() * 900)}`;

    const bookingItem: Booking = {
      id: 'B-' + Date.now(),
      bookingNumber: bNumber,
      guestId,
      apartmentId,
      checkInDate,
      checkOutDate,
      nightsCount: nights,
      totalPrice: total,
      paidAmount: paid,
      remainingAmount: total - paid,
      status: 'confirmed',
      notes,
      personsCount: personsVal,
    };

    setBookings([bookingItem, ...bookings]);
    
    // Update Apartment status
    setApartments(apartments.map(a => a.id === apartmentId ? { ...a, status: 'occupied' } : a));

    setShowBookingForm(false);
    setNewBooking({ apartmentId: '', guestId: '', checkInDate: '', checkOutDate: '', paidAmount: '0', notes: '', personsCount: '1' });
    setCustomGuestName('');
    setCustomGuestPhone('');
    setCustomGuestIdCard('');
    setCustomGuestNationality('جزائرية');
    setCustomNightlyPrice('');
    setCustomTotalPrice('');
    setBookingGuestMode('custom');
    triggerAlert('success', `تم تحصين وحفظ حجز النزيل بنجاح برقم: ${bNumber}`);
  };

  // Create Apartment Action
  const handleCreateApartment = (e: React.FormEvent) => {
    e.preventDefault();
    const { name, roomsCount, bedsCount, nightlyPrice, notes } = newApt;

    if (!name) {
      triggerAlert('error', 'الاسم أو رقم الشقة مطلوب لتسجيل الشقة.');
      return;
    }

    const newAptItem: Apartment = {
      id: String(apartments.length + 1),
      name,
      roomsCount: parseInt(roomsCount) || 2,
      bedsCount: parseInt(bedsCount) || 2,
      nightlyPrice: parseFloat(nightlyPrice) || 5000,
      notes,
      images: [],
      status: 'available',
    };

    setApartments([...apartments, newAptItem]);
    setShowAptForm(false);
    setNewApt({ name: '', roomsCount: '2', bedsCount: '2', nightlyPrice: '5000', notes: '' });
    triggerAlert('success', `تم تسجيل الشقة الجديدة بالكامل تحت المعرف SQLite: #${apartments.length + 1}`);
  };

  // Update Apartment Action
  const handleUpdateApartment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingApt) return;

    if (!editingApt.name) {
      triggerAlert('error', 'الاسم أو رقم الشقة مطلوب لحفظ التعديلات.');
      return;
    }

    setApartments(apartments.map(a => a.id === editingApt.id ? editingApt : a));
    setEditingApt(null);
    triggerAlert('success', `تم تعديل وتحديث بيانات الشقة: "${editingApt.name}" بنجاح في قاعدة البيانات.`);
  };

  // Create Guest Action
  const handleCreateGuest = (e: React.FormEvent) => {
    e.preventDefault();
    const { fullName, phone, idCardNumber, nationality, notes } = newGuest;

    if (!fullName || !phone || !idCardNumber) {
      triggerAlert('error', 'الاسم، الهاتف، ورقم بطاقة الهوية حقول إلزامية للتحقق الأمني.');
      return;
    }

    const idExists = guests.some(g => g.idCardNumber === idCardNumber);
    if (idExists) {
      triggerAlert('error', 'تنبيه أمني: يوجد زبون مسجل مسبقاً بنفس رقم بطاقة الهوية!');
      return;
    }

    const newGuestItem: Guest = {
      id: String(guests.length + 1),
      fullName,
      phone,
      idCardNumber,
      nationality,
      notes,
    };

    setGuests([...guests, newGuestItem]);
    setShowGuestForm(false);
    setNewGuest({ fullName: '', phone: '', idCardNumber: '', nationality: 'جزائرية', notes: '' });
    triggerAlert('success', 'تم تدوين وحفظ سجل الزبون الجديد بنجاح في قاعدة البيانات المحلية.');
  };

  // Toggle Booking Status (Double checking triggers)
  const handleUpdateBookingStatus = (bookingId: string, newStatus: BookingStatus) => {
    setBookings(bookings.map(b => {
      if (b.id !== bookingId) return b;
      
      // Update apartment status as well based on checkout or cancel
      if (newStatus === 'cancelled' || newStatus === 'completed') {
        setApartments(apartments.map(a => a.id === b.apartmentId ? { ...a, status: 'available' } : a));
      } else if (newStatus === 'checked_in') {
        setApartments(apartments.map(a => a.id === b.apartmentId ? { ...a, status: 'occupied' } : a));
      }

      return { ...b, status: newStatus };
    }));
    triggerAlert('success', 'تم تعديل حالة الحجز ومزامنة الشقة آلياً.');
  };

  // Helper to re-calculate total price when dates or nightly price changes
  const updateCalculatedTotals = (aptId: string, checkIn: string, checkOut: string, nightlyRate: string) => {
    const apt = apartments.find(a => a.id === aptId);
    const rate = parseFloat(nightlyRate) >= 0 ? parseFloat(nightlyRate) : (apt ? apt.nightlyPrice : 0);
    
    if (checkIn && checkOut) {
      const inDate = new Date(checkIn);
      const outDate = new Date(checkOut);
      if (!isNaN(inDate.getTime()) && !isNaN(outDate.getTime()) && inDate < outDate) {
        const nights = Math.max(1, Math.round((outDate.getTime() - inDate.getTime()) / (1000 * 60 * 60 * 24)));
        setCustomTotalPrice(String(rate * nights));
        setNumNightsState(String(nights));
        return;
      }
    }
    setCustomTotalPrice(String(rate));
  };

  const handleNumNightsChange = (nightsStr: string) => {
    setNumNightsState(nightsStr);
    const nights = parseInt(nightsStr);
    if (!isNaN(nights) && nights > 0 && newBooking.checkInDate) {
      const inDate = new Date(newBooking.checkInDate);
      const outDate = new Date(inDate.getTime() + nights * 24 * 60 * 60 * 1000);
      const year = outDate.getFullYear();
      const month = String(outDate.getMonth() + 1).padStart(2, '0');
      const day = String(outDate.getDate()).padStart(2, '0');
      const checkOutStr = `${year}-${month}-${day}`;
      
      setNewBooking(prev => ({ ...prev, checkOutDate: checkOutStr }));
      updateCalculatedTotals(newBooking.apartmentId, newBooking.checkInDate, checkOutStr, customNightlyPrice);
    }
  };

  // Add direct payments to a booking (Payments tab handler)
  const handleAddPayment = (bookingId: string) => {
    const rawVal = addingAmounts[bookingId];
    const val = parseFloat(rawVal);
    if (!rawVal || isNaN(val) || val <= 0) {
      triggerAlert('error', 'الرجاء إدخال مبلغ صحيح لإضافته.');
      return;
    }
    
    setBookings(prevBookings => prevBookings.map(b => {
      if (b.id !== bookingId) return b;
      const newPaid = b.paidAmount + val;
      const cappedPaid = Math.min(b.totalPrice, newPaid);
      return {
        ...b,
        paidAmount: cappedPaid,
        remainingAmount: Math.max(0, b.totalPrice - cappedPaid)
      };
    }));

    setAddingAmounts(prev => ({ ...prev, [bookingId]: '' }));
    triggerAlert('success', `تم تسجيل وتحصيل دفعة مالية إضافية بقيمة ${val.toLocaleString()} د.ج بنجاح.`);
  };

  const handlePayFullInvoice = (bookingId: string) => {
    setBookings(prevBookings => prevBookings.map(b => {
      if (b.id !== bookingId) return b;
      return {
        ...b,
        paidAmount: b.totalPrice,
        remainingAmount: 0
      };
    }));
    triggerAlert('success', 'تم دفع كامل المبلغ المتبقي وتصفية الفاتورة بنجاح.');
  };

  // --- Operating Expenses Management Handlers ---
  const handleCreateExpense = (e: React.FormEvent) => {
    e.preventDefault();
    const { amount, date, category, notes, apartmentId } = newExpense;
    
    if (!amount || isNaN(parseFloat(amount)) || parseFloat(amount) <= 0) {
      triggerAlert('error', 'يرجى إدخال قيمة مبلغ صحيحة أكبر من الصفر للمصروف.');
      return;
    }
    if (!date) {
      triggerAlert('error', 'يرجى تحديد تاريخ العملية كحقل إلزامي.');
      return;
    }
    if (!notes.trim()) {
      triggerAlert('error', 'يرجى إدخال وصف أو بيان مختصر للمصروف.');
      return;
    }

    const createdExpense: Expense = {
      id: 'E-' + Date.now(),
      amount: parseFloat(amount),
      date,
      category,
      notes: notes.trim(),
      apartmentId: apartmentId || undefined
    };

    setExpenses(prev => [createdExpense, ...prev]);
    setShowExpenseForm(false);
    setNewExpense({
      amount: '',
      date: '2026-06-01',
      category: 'maintenance',
      notes: '',
      apartmentId: ''
    });
    triggerAlert('success', 'تم تسجيل وإسقاط المصروف بنجاح بقاعدة البيانات المحلية SQLite.');
  };

  const handleDeleteExpense = (id: string) => {
    setExpenses(prev => prev.filter(exp => exp.id !== id));
    triggerAlert('success', 'تم شطب وحذف المصروف المالي بنجاح وتحديث التقارير المتأثرة.');
  };

  // Generate Local Backup Simulated Action
  const triggerLocalBackup = () => {
    const timeStamp = new Date().toISOString().replace('T', ' ').substring(0, 16);
    const backupName = `نسخة_احتياطية_${timeStamp.replace(/ /g, '_').replace(/:/g, '-')}.db`;
    const newBackup = {
      id: `BK-${backups.length + 1}`,
      name: backupName,
      date: timeStamp,
      size: `${(1.3 + Math.random() * 0.1).toFixed(2)} MB`
    };
    setBackups([newBackup, ...backups]);
    triggerAlert('success', `تم تخليق ملف SQLite مع أرشفة احتياطية كاملة باسم: "${backupName}" في مسار التخزين المكتبي المستقل.`);
  };

  // Simulate local database restore
  const triggerRestoreLocally = (bkName: string) => {
    triggerAlert('info', `تم استعادة قاعدة بيانات SQLite بنجاح من نقطة الأرشفة: "${bkName}". أعيد تحميل الحجوزات والشقق!`);
  };

  // Export Reports
  const generateSimulatedCSV = (reportType: string) => {
    triggerAlert('success', `تم توليد وتصدير تقرير الإيرادات ${reportType} محلياً بصيغة Excel/PDF دون الاتصال بالشبكة! (جاهز للتحميل)`);
  };

  // --- Statistics Calculation ---
  const statsAvailableCount = apartments.filter(a => a.status === 'available').length;
  const statsOccupiedCount = apartments.filter(a => a.status === 'occupied').length;
  const statsGuestsCount = bookings.filter(b => b.status === 'checked_in').length;
  
  // Daily / Monthly Revenue
  const statsDailyRevenue = bookings
    .filter(b => b.status === 'checked_in' || b.status === 'completed')
    .reduce((sum, b) => sum + (b.totalPrice / b.nightsCount), 0);

  const statsMonthlyRevenue = bookings
    .filter(b => b.status !== 'cancelled')
    .reduce((sum, b) => sum + b.totalPrice, 0);

  // --- Apartment Vacancy & Occupancy Analyzer for Dashboard ---
  const getApartmentVacancyInfo = (aptId: string) => {
    // Current Reference Date
    const todayStr = '2026-05-31';
    
    // Sort active bookings of this apartment by date
    const aptBookings = bookings.filter(b => b.apartmentId === aptId && b.status !== 'cancelled');
    
    // Find active booking covering today
    const currentBooking = aptBookings.find(b => b.checkInDate <= todayStr && b.checkOutDate > todayStr);
    
    // Find any future bookings starting after today
    const futureBookings = aptBookings
      .filter(b => b.checkInDate > todayStr)
      .sort((a, b) => a.checkInDate.localeCompare(b.checkInDate));
    
    const nextBooking = futureBookings[0];
    
    if (currentBooking) {
      const gDetail = guests.find(g => g.id === currentBooking.guestId);
      return {
        isAvailableNow: false,
        statusText: `مشغولة حالياً`,
        checkoutDate: currentBooking.checkOutDate,
        nextBookingDate: nextBooking ? nextBooking.nextBookingDate : (nextBooking ? nextBooking.checkInDate : null),
        currentGuest: gDetail ? gDetail.fullName : 'نزيل نشط'
      };
    } else {
      return {
        isAvailableNow: true,
        statusText: 'متاحة حالياً فوراً (شاغرة)',
        checkoutDate: null,
        nextBookingDate: nextBooking ? nextBooking.checkInDate : null,
        currentGuest: null
      };
    }
  };

  // Search Filter Implementation
  const filteredBookings = bookings.filter(b => {
    const guest = getGuestDetails(b.guestId);
    const apt = getApartmentDetails(b.apartmentId);
    if (!guest || !apt) return false;
    
    const query = searchQuery.toLowerCase();
    return (
      guest.fullName.toLowerCase().includes(query) ||
      guest.phone.includes(query) ||
      b.bookingNumber.toLowerCase().includes(query) ||
      apt.name.toLowerCase().includes(query)
    );
  });

  return (
    <div className="space-y-6">
      {/* Dynamic Alerts Banner */}
      {notice && (
        <div className={`p-4 rounded-xl shadow-xs border transition-all duration-300 flex items-center justify-between ${
          notice.type === 'success' ? 'bg-emerald-50 border-emerald-100 text-emerald-950' :
          notice.type === 'error' ? 'bg-rose-50 border-rose-100 text-rose-950' : 'bg-blue-50 border-blue-100 text-blue-950'
        }`}>
          <div className="flex items-center gap-2">
            {notice.type === 'error' ? <AlertTriangle className="w-5 h-5 text-rose-500" /> : <CheckCircle className="w-5 h-5 text-emerald-500" />}
            <span className="text-xs font-bold leading-relaxed">{notice.text}</span>
          </div>
          <button type="button" onClick={() => setNotice(null)} className="p-1 hover:bg-slate-200/50 rounded-lg">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Simulator Management Panel Header */}
      <div className="bg-white rounded-2xl border border-slate-100 p-5 flex flex-col gap-4 shadow-2xs">
        <div className="flex items-center gap-2 border-b border-slate-100 pb-3">
          <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse shrink-0"></span>
          <h2 className="text-sm sm:text-base md:text-lg font-black text-slate-800 tracking-tight">برنامج الاستقبال وإدارة الحجوزات اليومية</h2>
        </div>

        {/* Security / Role Selection */}
        <div className="flex flex-col sm:flex-row justify-between items-stretch sm:items-center gap-3 bg-slate-50/50 p-2.5 rounded-xl border border-slate-100">
          <div className="flex items-center gap-2">
            <Shield className="w-4 h-4 text-indigo-600 shrink-0" />
            <span className="text-xs font-bold text-slate-600">صلاحية المستخدم النشط:</span>
          </div>
          <div className="flex bg-slate-200 p-1 rounded-lg self-end sm:self-auto">
            <button
              type="button"
              onClick={() => { setCurrentRole('admin'); triggerAlert('info', 'تم التحول لصلاحيات "المدير العام": يمكنك مطالعة السجلات المالية وتصدير البيانات بالكامل.'); }}
              className={`p-1 px-3 text-[10px] font-extrabold rounded-md cursor-pointer transition-all ${currentRole === 'admin' ? 'bg-white text-indigo-950 shadow-2xs' : 'text-slate-500'}`}
            >
              مدير التطبيق
            </button>
            <button
              type="button"
              onClick={() => { setCurrentRole('receptionist'); triggerAlert('info', 'تم التحول لصلاحيات "موظف الاستقبال": تم تعمية النوافذ المالية وتقارير التصدير الإجمالية.'); }}
              className={`p-1 px-3 text-[10px] font-extrabold rounded-md cursor-pointer transition-all ${currentRole === 'receptionist' ? 'bg-white text-indigo-950 shadow-2xs' : 'text-slate-500'}`}
            >
              موظف الاستقبال
            </button>
          </div>
        </div>
      </div>

      {/* Visual Navigation Tabs */}
      <div className="flex overflow-x-auto pb-2.5 gap-2 border-b border-slate-100 flex-nowrap shrink-0 touch-pan-x scroll-smooth [&::-webkit-scrollbar]:h-1.5 [&::-webkit-scrollbar-track]:bg-slate-50 [&::-webkit-scrollbar-track]:rounded-full [&::-webkit-scrollbar-thumb]:bg-indigo-200 [&::-webkit-scrollbar-thumb]:rounded-full hover:[&::-webkit-scrollbar-thumb]:bg-indigo-300">
        {[
          { id: 'dash', label: 'لوحة التحكم والماليات', icon: BarChart3 },
          { id: 'calendar', label: 'تقويم الحجوزات (Timeline)', icon: CalendarIcon },
          { id: 'payments', label: 'المدفوعات والتحصيل المالي', icon: FileText },
          { id: 'bookings', label: 'الحجوزات النشطة', icon: ClipboardList },
          { id: 'apartments', label: 'الشقق الحالية', icon: Home },
          { id: 'guests', label: 'سجلات الزبائن', icon: Users },
          { id: 'backups', label: 'النسخ الاحتياطي والأمان', icon: Database },
        ].map((tab) => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              type="button"
              onClick={() => setActiveTab(tab.id as any)}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer whitespace-nowrap shrink-0 ${
                activeTab === tab.id
                  ? 'bg-indigo-600 text-white shadow-xs'
                  : 'bg-white border border-slate-100 text-slate-600 hover:bg-slate-50'
              }`}
            >
              <Icon className="w-4 h-4 shrink-0" />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>

      {/* --- Tab Content 1: Dashboard Stats --- */}
      {activeTab === 'dash' && (
        <div className="space-y-6">
          {/* Dashboard Summary Cards Grid */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            
            <div className="bg-white border border-slate-100 rounded-2xl p-5 shadow-2xs flex flex-row justify-between items-center">
              <div>
                <span className="text-[10px] font-extrabold text-slate-400">الشقق المتاحة حالياً</span>
                <div className="text-2xl font-black text-emerald-600 mt-1">{statsAvailableCount} / {apartments.length}</div>
                <div className="text-[10px] text-emerald-500 mt-1">جاهزة فوراً للتسجيل</div>
              </div>
              <div className="w-10 h-10 bg-emerald-50 rounded-xl flex items-center justify-center text-emerald-600">
                <Home className="w-5 h-5" />
              </div>
            </div>

            <div className="bg-white border border-slate-100 rounded-2xl p-5 shadow-2xs flex flex-row justify-between items-center">
              <div>
                <span className="text-[10px] font-extrabold text-slate-400">الشقق المشغولة</span>
                <div className="text-2xl font-black text-rose-500 mt-1">{statsOccupiedCount}</div>
                <div className="text-[10px] text-rose-400 mt-1">شغلت من عائلات ونزلاء</div>
              </div>
              <div className="w-10 h-10 bg-rose-50 rounded-xl flex items-center justify-center text-rose-600">
                <Shield className="w-5 h-5" />
              </div>
            </div>

            <div className="bg-white border border-slate-100 rounded-2xl p-5 shadow-2xs flex flex-row justify-between items-center">
              <div>
                <span className="text-[10px] font-extrabold text-slate-400">النزلاء المقيمون الآن</span>
                <div className="text-2xl font-black text-slate-800 mt-1">{statsGuestsCount}</div>
                <div className="text-[10px] text-slate-400 mt-1">تم توثيق هوياتهم أمنياً</div>
              </div>
              <div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-600">
                <Users className="w-5 h-5" />
              </div>
            </div>

            <div className="bg-white border border-slate-100 rounded-2xl p-5 shadow-2xs flex flex-row justify-between items-center">
              <div>
                <span className="text-[10px] font-extrabold text-slate-400">إجمالي إيراد المقاصة اليومية</span>
                <div className="text-2xl font-black text-indigo-700 mt-1">
                  {currentRole === 'admin' ? `${statsDailyRevenue.toLocaleString('en-US')} د.ج` : '••••'}
                </div>
                <div className="text-[10px] text-indigo-500 mt-1">
                  {currentRole === 'admin' ? 'متوسط مقدر تداول اليوم' : 'تتطلب رتبة مدير'}
                </div>
              </div>
              <div className="w-10 h-10 bg-indigo-50 rounded-xl flex items-center justify-center text-indigo-600">
                <BarChart3 className="w-5 h-5" />
              </div>
            </div>

          </div>

          {/* --- DB-Dashboard Apartment Availability & Vacancy Schedule Component --- */}
          <div className="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm space-y-4">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
                <h3 className="font-extrabold text-[13px] text-slate-800">حالة جاهزية وجدول شغور وتوفر الشقق</h3>
              </div>
              <span className="text-[10px] bg-slate-100 text-slate-600 px-2.5 py-1 rounded-full font-mono font-bold leading-none">
                التوقيت المرجعي للخروج والدخول: 10:00 صباحاً
              </span>
            </div>
            
            <p className="text-xs text-slate-500 leading-relaxed">
              توضيح فوري لمتى تفرغ وتحضر كل شقة. الخروج على 10:00 صباحاً يمكّنك من استقبال حجز جديد لشخص ثانٍ في نفس اليوم مباشرةً دون تعارض!
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {apartments.map((apt) => {
                const info = getApartmentVacancyInfo(apt.id);
                return (
                  <div key={apt.id} className={`p-4 rounded-xl border transition-all duration-300 ${info.isAvailableNow ? 'bg-emerald-50/20 border-emerald-100/70 hover:shadow-xs' : 'bg-slate-50/50 border-slate-200/50'}`}>
                    <div className="flex justify-between items-start gap-2">
                      <div className="truncate">
                        <span className="font-extrabold text-xs text-slate-800 block truncate">{apt.name}</span>
                        <span className="text-[9.5px] text-slate-400 font-bold block mt-0.5">{apt.roomsCount} غرف • {apt.nightlyPrice.toLocaleString()} د.ج/ليلة</span>
                      </div>
                      
                      <span className={`text-[9px] font-black px-2 py-0.5 rounded-full whitespace-nowrap ${info.isAvailableNow ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'}`}>
                        {info.isAvailableNow ? 'شاغرة الآن' : 'محجوزة'}
                      </span>
                    </div>

                    <div className="mt-3 pt-3 border-t border-dashed border-slate-200 text-xs space-y-1.5 text-slate-650">
                      <div className="flex justify-between items-center gap-2">
                        <span className="text-slate-400 text-[10px]">جاهزية الشقة:</span>
                        <span className={`font-extrabold text-[11px] ${info.isAvailableNow ? 'text-emerald-700' : 'text-amber-700'}`}>
                          {info.isAvailableNow ? 'متاحة فوراً للدخول اليوم' : `تفرغ يوم ${info.checkoutDate}`}
                        </span>
                      </div>

                      {info.currentGuest && (
                        <div className="flex justify-between items-center gap-2 text-[10px]">
                          <span className="text-slate-400">النزيل النشط حالياً:</span>
                          <span className="text-slate-700 font-bold max-w-[120px] truncate">{info.currentGuest}</span>
                        </div>
                      )}

                      <div className="flex justify-between items-center gap-2 text-[10px]">
                        <span className="text-slate-400">الاستلام القادم:</span>
                        <span className="text-slate-600 font-mono font-bold truncate">
                          {info.isAvailableNow 
                            ? (info.nextBookingDate ? `حجز مبرم يوم ${info.nextBookingDate}` : 'شاغرة بشكل كلي بمستقبل الآجال') 
                            : (info.nextBookingDate ? `مستسلمة لحجز يوم ${info.nextBookingDate}` : 'شاغرة مباشرة بعد الخروج')
                          }
                        </span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Quick Booking Actions/Reports Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            
            {/* Quick Actions Panel */}
            <div className="lg:col-span-2 bg-white rounded-2xl border border-slate-100 p-6 shadow-sm space-y-4">
              <h3 className="font-extrabold text-sm text-slate-800 border-b border-slate-50 pb-3">إجراءات سريعة فورية للكراء</h3>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <button
                  type="button"
                  onClick={() => setShowBookingForm(true)}
                  className="bg-indigo-600 hover:bg-indigo-700 text-white p-4 rounded-xl text-center font-bold text-xs shadow-xs hover:shadow-md transition-all cursor-pointer flex flex-col items-center justify-center gap-2"
                >
                  <Plus className="w-5 h-5" />
                  تسجيل حجز جديد
                </button>
                <button
                  type="button"
                  onClick={() => setShowAptForm(true)}
                  className="bg-slate-50 hover:bg-slate-100 border border-slate-100 text-slate-700 p-4 rounded-xl text-center font-bold text-xs shadow-2xs transition-all cursor-pointer flex flex-col items-center justify-center gap-2"
                >
                  <Home className="w-5 h-5 text-indigo-600" />
                  إضافة شقة جديدة لشجرتنا
                </button>
                <button
                  type="button"
                  onClick={() => setShowGuestForm(true)}
                  className="bg-slate-50 hover:bg-slate-100 border border-slate-100 text-slate-700 p-4 rounded-xl text-center font-bold text-xs shadow-2xs transition-all cursor-pointer flex flex-col items-center justify-center gap-2"
                >
                  <Users className="w-5 h-5 text-indigo-600" />
                  تسجيل بطاقة زبون أمنية
                </button>
              </div>

              {/* Financial Box Mock for Admin */}
              {currentRole === 'admin' ? (
                <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 mt-2 space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-xs font-bold text-slate-700">تقديرات مبيعات الشهر (إجمالي تداول):</span>
                    <span className="text-sm font-extrabold text-indigo-700">{(statsMonthlyRevenue).toLocaleString('en-US')} د.ج</span>
                  </div>
                  <div className="flex justify-between items-center text-[11px] text-slate-500">
                    <span>مجموع مبالغ الحجوزات المدفوعة:</span>
                    <span>{bookings.reduce((sum, b) => sum + b.paidAmount, 0).toLocaleString('en-US')} د.ج</span>
                  </div>
                  <div className="flex justify-between items-center text-[11px] text-rose-600 font-bold border-t border-slate-200/50 pt-2">
                    <span>إجمالي المبالغ المعلقة المتبقية للاستخلاص:</span>
                    <span>{bookings.reduce((sum, b) => sum + b.remainingAmount, 0).toLocaleString('en-US')} د.ج</span>
                  </div>
                </div>
              ) : (
                <div className="p-4 bg-slate-50 rounded-xl border border-dashed border-slate-200 text-center text-xs text-slate-400">
                  ⚠️ معلومات الإحصائيات والأرقام المجمعة للمنظومة مخفية الآن. الموظف العادي يتابع جداول الإشغال فقط.
                </div>
              )}
            </div>

            {/* Print & Local Reporting Box */}
            <div className="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm space-y-4">
              <h3 className="font-extrabold text-sm text-slate-800 border-b border-slate-50 pb-3">أدوات إعداد التقارير المحلية والمستندات</h3>
              <p className="text-xs text-slate-500 leading-relaxed">
                لوائح المطبوعات والتصدير المدمجة التي تستخدم مكتبات <code className="text-indigo-600 font-mono">pdf</code> و <code className="text-indigo-600 font-mono">excel</code> في المشروع لتوليد الملفات بالكامل أوفلاين:
              </p>
              
              <div className="space-y-2">
                <button
                  type="button"
                  disabled={currentRole !== 'admin'}
                  onClick={() => generateSimulatedCSV('اليومية')}
                  className={`w-full text-right p-3 rounded-xl border flex items-center justify-between text-xs font-bold transition-all ${
                    currentRole === 'admin'
                      ? 'bg-indigo-50/50 hover:bg-indigo-50 border-indigo-100 text-indigo-950 cursor-pointer'
                      : 'bg-slate-50 border-slate-150 text-slate-400 cursor-not-allowed'
                  }`}
                >
                  <span className="flex items-center gap-2">
                    <FileText className="w-4 h-4 text-indigo-600" />
                    استخراج التقرير المالي اليومي
                  </span>
                  <Download className="w-4 h-4 shrink-0" />
                </button>

                <button
                  type="button"
                  disabled={currentRole !== 'admin'}
                  onClick={() => generateSimulatedCSV('الأسبوعية')}
                  className={`w-full text-right p-3 rounded-xl border flex items-center justify-between text-xs font-bold transition-all ${
                    currentRole === 'admin'
                      ? 'bg-indigo-50/50 hover:bg-indigo-50 border-indigo-100 text-indigo-950 cursor-pointer'
                      : 'bg-slate-50 border-slate-150 text-slate-400 cursor-not-allowed'
                  }`}
                >
                  <span className="flex items-center gap-2">
                    <FileText className="w-4 h-4 text-indigo-600" />
                    استخراج تقارير الأسبوع النشطة
                  </span>
                  <Download className="w-4 h-4 shrink-0" />
                </button>

                <button
                  type="button"
                  disabled={currentRole !== 'admin'}
                  onClick={() => generateSimulatedCSV('الشهرية')}
                  className={`w-full text-right p-3 rounded-xl border flex items-center justify-between text-xs font-bold transition-all ${
                    currentRole === 'admin'
                      ? 'bg-indigo-50/50 hover:bg-indigo-50 border-indigo-100 text-indigo-950 cursor-pointer'
                      : 'bg-slate-50 border-slate-150 text-slate-400 cursor-not-allowed'
                  }`}
                >
                  <span className="flex items-center gap-2">
                    <FileText className="w-4 h-4 text-indigo-600" />
                    تصدير تقرير الإيرادات هذا الشهر (Excel)
                  </span>
                  <Download className="w-4 h-4 shrink-0" />
                </button>
              </div>

              {currentRole !== 'admin' && (
                <div className="text-[10px] text-rose-500 font-bold bg-rose-50 p-2 rounded-lg text-center mt-1">
                  * تصدير التقارير المالية متاح لقسم المدراء فقط.
                </div>
              )}
            </div>

          </div>
        </div>
      )}

      {/* --- Tab Content 2: Calendar Timeline --- */}
      {activeTab === 'calendar' && (
        <TimelineCalendar
          apartments={apartments}
          bookings={bookings}
          guests={guests}
          customColors={customColors}
          onUpdateColor={handleUpdateColor}
          onSelectBooking={(b) => {
            const guest = getGuestDetails(b.guestId);
            const apt = getApartmentDetails(b.apartmentId);
            triggerAlert('info', `تفاصيل الحجز النشط المحدد: رقم الحجز #${b.bookingNumber} | الزبون: ${guest?.fullName} | الشقة والنوع: ${apt?.name} | السعر: ${b.totalPrice} د.ج | المبلغ المدفوع: ${b.paidAmount} د.ج`);
          }}
          onNewBookingAt={(aptId, dateStr) => {
            const apt = getApartmentDetails(aptId);
            setNewBooking(prev => ({
              ...prev,
              apartmentId: aptId,
              checkInDate: dateStr,
              checkOutDate: (() => {
                const d = new Date(dateStr);
                d.setDate(d.getDate() + 1);
                return d.toISOString().split('T')[0];
              })()
            }));
            setShowBookingForm(true);
            triggerAlert('info', `تم تحديد شقة العطلات: "${apt?.name}" فوراً برسم الدخول: ${dateStr}`);
          }}
        />
      )}

      {/* --- Tab Content: Payments & Invoices (Our newly added Payments Tab) --- */}
      {activeTab === 'payments' && (
        <FinancialWorkspace
          bookings={bookings}
          expenses={expenses}
          apartments={apartments}
          guests={guests}
          setExpenses={setExpenses}
          addingAmounts={addingAmounts}
          setAddingAmounts={setAddingAmounts}
          handleAddPayment={handleAddPayment}
          handlePayFullInvoice={handlePayFullInvoice}
          triggerAlert={triggerAlert}
        />
      )}

      {/* --- OLD DISABLED PAYMENTS --- */}
      {false && activeTab === 'payments' && (
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-6 animate-fade-in">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b border-slate-50 pb-4">
            <div>
              <h3 className="font-extrabold text-sm text-slate-800">إدارة المدفوعات والتحصيل المالي (SQLite Billing)</h3>
              <p className="text-xs text-slate-500 mt-1">مطالعة الفواتير، تحديث المبالغ المستخلصة، وتنزيل الوصولات المالية</p>
            </div>
            
            {/* Quick Stats overview of Payments */}
            <div className="flex flex-wrap gap-4">
              <div className="bg-slate-50 p-2.5 px-4 rounded-xl border border-slate-100 text-center">
                <div className="text-[10px] text-slate-400 font-bold">إجمالي المطالبات</div>
                <div className="text-sm font-black text-indigo-700">
                  {bookings.reduce((sum, b) => b.status !== 'cancelled' ? sum + b.totalPrice : sum, 0).toLocaleString()} د.ج
                </div>
              </div>
              <div className="bg-emerald-50 p-2.5 px-4 rounded-xl border border-emerald-150 text-center">
                <div className="text-[10px] text-emerald-600 font-bold">المبالغ المقبوضة</div>
                <div className="text-sm font-black text-emerald-800">
                  {bookings.reduce((sum, b) => b.status !== 'cancelled' ? sum + b.paidAmount : sum, 0).toLocaleString()} د.ج
                </div>
              </div>
              <div className="bg-rose-50 p-2.5 px-4 rounded-xl border border-rose-150 text-center">
                <div className="text-[10px] text-rose-500 font-bold">الديون المتبقية</div>
                <div className="text-sm font-black text-rose-800">
                  {bookings.reduce((sum, b) => b.status !== 'cancelled' ? sum + b.remainingAmount : sum, 0).toLocaleString()} د.ج
                </div>
              </div>
            </div>
          </div>

          {/* Quick Search Tool */}
          <div className="relative flex items-center">
            <Search className="absolute right-4 w-4 h-4 text-slate-400" />
            <input
              type="text"
              placeholder="البحث برقم الفاتورة/الحجز، اسم النزيل، أو الشقة للتحصيل المالي..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full text-right p-3 pr-11 bg-slate-50 rounded-xl border border-slate-100 text-xs focus:bg-white focus:outline-indigo-500 font-semibold"
            />
          </div>

          {/* List/Table of Outstanding Payments */}
          <div className="overflow-x-auto rounded-xl border border-slate-100">
            <table className="w-full text-right border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/70 text-slate-700 border-b border-slate-100">
                  <th className="p-4 font-bold">رقم الفاتورة/الحجز</th>
                  <th className="p-4 font-bold">النزيل</th>
                  <th className="p-4 font-bold">الشقة المستأجرة</th>
                  <th className="p-4 font-bold">قيمة الحجز الإجمالية</th>
                  <th className="p-4 font-bold">دفعة العربون (مدفوع)</th>
                  <th className="p-4 font-bold">المبلغ المتبقي المعلق</th>
                  <th className="p-4 font-bold">تسجيل مالي / استيراد دفع</th>
                  <th className="p-4 font-bold text-center">تصفية سريعة</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-600 font-semibold">
                {bookings.filter(b => {
                  const guest = guests.find(g => g.id === b.guestId);
                  const apt = apartments.find(a => a.id === b.apartmentId);
                  if (!guest || !apt) return false;
                  const query = searchQuery.toLowerCase();
                  return (
                    guest.fullName.toLowerCase().includes(query) ||
                    b.bookingNumber.toLowerCase().includes(query) ||
                    apt.name.toLowerCase().includes(query)
                  );
                }).length > 0 ? (
                  bookings.filter(b => {
                    const guest = guests.find(g => g.id === b.guestId);
                    const apt = apartments.find(a => a.id === b.apartmentId);
                    if (!guest || !apt) return false;
                    const query = searchQuery.toLowerCase();
                    return (
                      guest.fullName.toLowerCase().includes(query) ||
                      b.bookingNumber.toLowerCase().includes(query) ||
                      apt.name.toLowerCase().includes(query)
                    );
                  }).map((b) => {
                    const guest = guests.find(g => g.id === b.guestId);
                    const apt = apartments.find(a => a.id === b.apartmentId);
                    const percentPaid = Math.min(100, Math.round((b.paidAmount / b.totalPrice) * 100)) || 0;
                    
                    return (
                      <tr key={b.id} className={`hover:bg-slate-50/40 ${b.status === 'cancelled' ? 'opacity-55 bg-slate-50/20' : ''}`}>
                        {/* Booking Number */}
                        <td className="p-4 font-mono font-bold text-slate-800">
                          <div className="flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: b.status === 'cancelled' ? '#94a3b8' : b.remainingAmount === 0 ? '#059669' : '#f59e0b' }}></span>
                            <span>{b.bookingNumber}</span>
                          </div>
                        </td>
                        
                        {/* Guest details */}
                        <td className="p-4">
                          <div className="font-bold text-slate-800">{guest?.fullName}</div>
                          <div className="text-[10px] text-slate-400 mt-0.5">{guest?.phone}</div>
                        </td>

                        {/* Apartment */}
                        <td className="p-4 font-extrabold text-indigo-950">{apt?.name}</td>

                        {/* Total Price */}
                        <td className="p-4 font-extrabold text-slate-800">{b.totalPrice.toLocaleString()} د.ج</td>

                        {/* Paid Amount */}
                        <td className="p-4">
                          <div className="font-bold text-emerald-600">{b.paidAmount.toLocaleString()} د.ج</div>
                          <div className="w-20 bg-slate-100 rounded-full h-1 mt-1 overflow-hidden" title={`${percentPaid}% مدفوع`}>
                            <div className="bg-emerald-500 h-1 rounded-full transition-all" style={{ width: `${percentPaid}%` }}></div>
                          </div>
                        </td>

                        {/* Remaining Amount */}
                        <td className="p-4">
                          <span className={`font-black text-xs ${b.remainingAmount > 0 && b.status !== 'cancelled' ? 'text-rose-600' : 'text-slate-500'}`}>
                            {b.status === 'cancelled' ? 'ملغى' : b.remainingAmount === 0 ? 'لا يوجد (خالص)' : `${b.remainingAmount.toLocaleString()} د.ج`}
                          </span>
                        </td>

                        {/* Custom Pay register input */}
                        <td className="p-4">
                          {b.status !== 'cancelled' && b.remainingAmount > 0 ? (
                            <div className="flex gap-1.5 items-center max-w-[150px]">
                              <input
                                type="number"
                                placeholder="المبلغ"
                                value={addingAmounts[b.id] || ''}
                                onChange={(e) => setAddingAmounts({ ...addingAmounts, [b.id]: e.target.value })}
                                className="w-20 p-1 bg-slate-50 border border-slate-200 rounded-md text-right text-xs outline-indigo-500 font-bold"
                              />
                              <button
                                type="button"
                                onClick={() => handleAddPayment(b.id)}
                                className="px-2 py-1 bg-indigo-600 hover:bg-indigo-700 text-white rounded-md font-bold text-[10px] cursor-pointer"
                              >
                                تحصيل
                              </button>
                            </div>
                          ) : (
                            <span className="text-slate-400 text-[10px] italic">
                              {b.status === 'cancelled' ? 'دورة ملغاة' : 'تم تسوية الفاتورة'}
                            </span>
                          )}
                        </td>

                        {/* Quick Action pay remaining */}
                        <td className="p-4 text-center">
                          {b.status !== 'cancelled' && b.remainingAmount > 0 ? (
                            <button
                              type="button"
                              onClick={() => handlePayFullInvoice(b.id)}
                              className="px-2.5 py-1 bg-emerald-50 hover:bg-emerald-100 border border-emerald-250 text-emerald-800 rounded-lg text-[10px] font-bold cursor-pointer"
                            >
                              دفع كامل المتبقي
                            </button>
                          ) : (
                            <span className="text-emerald-700 bg-emerald-50 border border-emerald-100 px-2 py-0.5 rounded-full text-[9px] font-bold">
                              {b.status === 'cancelled' ? 'ملغى وسحب' : 'مكتمل الدفع'}
                            </span>
                          )}
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan={8} className="p-8 text-center text-slate-400 font-semibold bg-slate-50/20">
                      لا توجد فواتير أو حجوزات تطابق البحث الفوري.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* --- Tab Content 3: Bookings Tracking --- */}
      {activeTab === 'bookings' && (
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-6">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b border-slate-50 pb-4">
            <div>
              <h3 className="font-extrabold text-sm text-slate-800">سجلات وإدارة الحجوزات</h3>
              <p className="text-xs text-slate-500 mt-1">تتبع الحجوزات، التحصيل المالي، الدفع والولاية الحالية</p>
            </div>
            
            <button
              type="button"
              onClick={() => setShowBookingForm(true)}
              className="bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold px-4 py-2 rounded-xl transition-all cursor-pointer flex items-center gap-1.5 self-end md:self-auto"
            >
              <Plus className="w-4 h-4" />
              حجز جديد
            </button>
          </div>

          {/* Quick Search Tool */}
          <div className="relative flex items-center">
            <Search className="absolute right-4 w-4 h-4 text-slate-400" />
            <input
              type="text"
              placeholder="البحث برقم الحجز، اسم النزيل، رقم الهاتف، أو رقم شقة الإقامة..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full text-right p-3 pr-11 bg-slate-50 rounded-xl border border-slate-100 text-xs focus:bg-white focus:outline-indigo-500"
            />
          </div>

          <div className="overflow-x-auto rounded-xl border border-slate-100">
            <table className="w-full text-right border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/70 text-slate-700 border-b border-slate-100">
                  <th className="p-4 font-bold">رقم الحجز</th>
                  <th className="p-4 font-bold">الزبون</th>
                  <th className="p-4 font-bold">الشقة المتخذة</th>
                  <th className="p-4 font-bold">فترة الحجز</th>
                  <th className="p-4 font-bold">الحساب المالي</th>
                  <th className="p-4 font-bold">الحالة الإدارية</th>
                  <th className="p-4 font-bold text-center">أدوات التحكم</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-600 font-medium">
                {filteredBookings.length > 0 ? (
                  filteredBookings.map((b) => {
                    const guest = getGuestDetails(b.guestId);
                    const apt = getApartmentDetails(b.apartmentId);
                    return (
                      <tr key={b.id} className="hover:bg-slate-50/40">
                        <td className="p-4 font-mono font-bold text-slate-800">{b.bookingNumber}</td>
                        <td className="p-4">
                          <div className="font-bold text-slate-800">{guest?.fullName}</div>
                          <div className="text-[10px] text-slate-400 mt-0.5">{guest?.phone}</div>
                        </td>
                        <td className="p-4 font-extrabold text-indigo-950">{apt?.name}</td>
                        <td className="p-4">
                          <div className="font-mono text-slate-700">{b.checkInDate} ← {b.checkOutDate}</div>
                          <div className="text-[10px] text-slate-400 mt-0.5">({b.nightsCount} ليالٍ)</div>
                        </td>
                        <td className="p-4">
                          <div className="font-bold text-slate-800">{b.totalPrice.toLocaleString('en-US')} د.ج</div>
                          <div className="flex gap-2 text-[10px] items-center mt-1">
                            <span className="text-emerald-600 font-bold">مدفوع: {b.paidAmount.toLocaleString('en-US')} د.ج</span>
                            <span className="text-amber-600 font-bold">متبقي: {b.remainingAmount.toLocaleString('en-US')} د.ج</span>
                          </div>
                        </td>
                        <td className="p-4">
                          <span className={`px-2 py-1 rounded-full text-[9px] font-bold ${
                            b.status === 'confirmed' ? 'bg-blue-100 text-blue-800' :
                            b.status === 'pending_arrival' ? 'bg-amber-100 text-amber-800' :
                            b.status === 'checked_in' ? 'bg-emerald-100 text-emerald-800' :
                            b.status === 'completed' ? 'bg-slate-100 text-slate-600' : 'bg-rose-100 text-rose-800'
                          }`}>
                            {b.status === 'confirmed' ? 'مؤكد' :
                             b.status === 'pending_arrival' ? 'قيد الوصول' :
                             b.status === 'checked_in' ? 'مقيم حالياً' :
                             b.status === 'completed' ? 'مكتمل ومسترجع' : 'ملغى وتصفية'}
                          </span>
                        </td>
                        <td className="p-4">
                          <div className="flex gap-1.5 justify-center">
                            {b.status === 'confirmed' && (
                              <button
                                type="button"
                                onClick={() => handleUpdateBookingStatus(b.id, 'checked_in')}
                                className="px-2 py-1 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200 text-[10px] font-bold rounded-lg text-emerald-700 cursor-pointer"
                              >
                                وصول النزيل (Check-In)
                              </button>
                            )}
                            {b.status === 'checked_in' && (
                              <button
                                type="button"
                                onClick={() => handleUpdateBookingStatus(b.id, 'completed')}
                                className="px-2 py-1 bg-slate-100 hover:bg-slate-200 border border-slate-200 text-[10px] font-bold rounded-lg text-slate-700 cursor-pointer"
                              >
                                تسوية الإخلاء (Checkout)
                              </button>
                            )}
                            {b.status !== 'cancelled' && b.status !== 'completed' && (
                              <button
                                type="button"
                                onClick={() => handleUpdateBookingStatus(b.id, 'cancelled')}
                                className="px-2 py-1 bg-rose-50 hover:bg-rose-100 border border-rose-200 text-[10px] font-bold rounded-lg text-rose-700 cursor-pointer"
                              >
                                إلغاء
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan={7} className="p-8 text-center text-slate-400 font-bold bg-slate-50/20">
                      لا توجد حجوزات متوفرة تطابق فلاتر البحث الحالية. يمكنك البدء بإضافة حجز جديد.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* --- Tab Content 4: Apartments Registry --- */}
      {activeTab === 'apartments' && (
        <div className="space-y-6">
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
            <div className="flex justify-between items-center border-b border-slate-50 pb-4">
              <div>
                <h3 className="font-extrabold text-sm text-slate-800">تعداد شقق الكراء اليومي</h3>
                <p className="text-xs text-slate-500 mt-1">تفريغ ومطالعة وضعية الغرف والخدمات الأساسية لكل وحدة</p>
              </div>
              <button
                type="button"
                onClick={() => setShowAptForm(true)}
                className="bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold px-4 py-2 rounded-xl transition-all cursor-pointer flex items-center gap-1.5"
              >
                <Plus className="w-4 h-4" />
                إضافة شقة جديدة
              </button>
            </div>

            {/* Grid list of Apartments */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {apartments.map((apt) => (
                <div key={apt.id} className="bg-slate-50/45 border border-slate-100 rounded-2xl p-5 shadow-2xs hover:shadow-xs hover:border-slate-200 transition-all flex flex-col justify-between">
                  <div>
                    <div className="flex justify-between items-start">
                      <span className={`text-[9px] font-extrabold px-2.5 py-1 rounded-full border ${
                        apt.status === 'available' ? 'bg-emerald-50 border-emerald-100 text-emerald-800' :
                        apt.status === 'occupied' ? 'bg-indigo-50 border-indigo-150 text-indigo-800' :
                        apt.status === 'cleaning' ? 'bg-amber-50 border-amber-100 text-amber-800' : 'bg-red-50 border-red-100 text-red-800'
                      }`}>
                        {apt.status === 'available' ? 'متاحة' :
                         apt.status === 'occupied' ? 'مشغولة' :
                         apt.status === 'cleaning' ? 'قيد التنظيف' : 'خارج الخدمة'}
                      </span>
                      <span className="text-[10px] font-bold text-slate-400">معرف SQLite: #{apt.id}</span>
                    </div>

                    <h4 className="text-sm font-extrabold text-slate-800 mt-4 flex items-center gap-1.5">
                      <Home className="w-4 h-4 text-indigo-600shrink-0" />
                      {apt.name}
                    </h4>

                    {/* Room Stats */}
                    <div className="flex gap-4 items-center text-xs text-slate-600 mt-3 font-semibold bg-white p-2.5 rounded-lg border border-slate-100">
                      <span>عدد الغرف: {apt.roomsCount}</span>
                      <span className="text-slate-300">|</span>
                      <span>عدد الأسرة: {apt.bedsCount}</span>
                    </div>

                    {apt.notes && (
                      <p className="text-[11px] text-slate-500 mt-3 leading-relaxed bg-white p-2 rounded-lg border border-slate-50/50">
                        {apt.notes}
                      </p>
                    )}
                  </div>

                  <div className="border-t border-slate-100 pt-3 mt-4 flex justify-between items-center bg-white/50 -mx-5 -mb-5 p-5 rounded-b-2xl">
                    <span className="text-xs font-black text-indigo-700">{apt.nightlyPrice.toLocaleString('en-US')} د.ج / الليلة</span>
                    
                    <div className="flex gap-1.5 items-center">
                      <button
                        type="button"
                        onClick={() => setEditingApt(apt)}
                        className="text-[10px] font-extrabold bg-indigo-50 border border-indigo-100 hover:bg-indigo-600 text-indigo-700 hover:text-white px-2 py-1 rounded-md transition-all cursor-pointer"
                      >
                        تعديل
                      </button>
                      {/* Dropdown/Quick Status toggler */}
                      <select
                        value={apt.status}
                        onChange={(e) => {
                          setApartments(apartments.map(a => a.id === apt.id ? { ...a, status: e.target.value as ApartmentStatus } : a));
                          triggerAlert('success', `تم تغيير وضعية الشقة: "${apt.name}"`);
                        }}
                        className="text-[10px] font-bold text-slate-600 bg-white border border-slate-200 outline-none p-1 rounded-md"
                      >
                        <option value="available">متاحة</option>
                        <option value="occupied">مشغولة</option>
                        <option value="cleaning">تنظيف</option>
                        <option value="maintenance">صيانة</option>
                      </select>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* --- Tab Content 5: Guest Registry --- */}
      {activeTab === 'guests' && (
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-6">
          <div className="flex justify-between items-center border-b border-slate-50 pb-4">
            <div>
              <h3 className="font-extrabold text-sm text-slate-800">قاعدة بيانات الزبائن</h3>
              <p className="text-xs text-slate-500 mt-1">تأمين ومطالعة البيانات الشخصية وسجل التحقق الأمني للنزلاء للشرطة والمتابعة</p>
            </div>
            <button
              type="button"
              onClick={() => setShowGuestForm(true)}
              className="bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold px-4 py-2 rounded-xl transition-all cursor-pointer flex items-center gap-1.5"
            >
              <Plus className="w-4 h-4" />
              تسجيل زبون جديد
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {guests.map((g) => (
              <div key={g.id} className="bg-slate-50/50 p-4 rounded-xl border border-slate-100 flex gap-4">
                <div className="w-10 h-10 bg-indigo-50 text-indigo-700 shrink-0 rounded-full flex items-center justify-center font-black text-xs">
                  {g.fullName.charAt(0)}
                </div>
                <div className="space-y-1 w-full">
                  <div className="flex justify-between">
                    <span className="font-bold text-xs text-slate-800">{g.fullName}</span>
                    <span className="text-[10px] text-slate-400 font-mono text-left">ID: #{g.id}</span>
                  </div>
                  <div className="grid grid-cols-2 gap-2 text-[10.5px] text-slate-600 font-semibold mt-2">
                    <div>الهاتف: {g.phone}</div>
                    <div>الجنسية: {g.nationality}</div>
                    <div className="col-span-2">بطاقة الهوية: <span className="font-mono text-slate-700">{g.idCardNumber}</span></div>
                  </div>
                  {g.notes && (
                    <div className="text-[10px] border-t border-slate-100 pt-2 text-slate-500 mt-2">
                      ملاحظة أمنية: {g.notes}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* --- Tab Content 6: Off-Line Backups & Admin Controls --- */}
      {activeTab === 'backups' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Backup Database management panel */}
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
            <div className="flex justify-between items-center border-b border-slate-50 pb-3">
              <h3 className="font-extrabold text-sm text-slate-800">قائمة النسخ الاحتياطي والحياد المادي</h3>
              <button
                type="button"
                onClick={triggerLocalBackup}
                className="bg-indigo-600 hover:bg-indigo-700 text-white text-[10.5px] font-bold px-3 py-2 rounded-xl transition-all cursor-pointer flex items-center gap-1"
              >
                <Plus className="w-3.5 h-3.5" />
                تخليق نسخة احتياطية فوراً
              </button>
            </div>
            
            <p className="text-xs text-slate-500 leading-relaxed">
              يقوم التطبيق بحفظ نسخة كاملة من ملف SQLite المضغوط في مجلد التخزين الخارجي الخاص بك. يمكن استعادة قاعدة العمل بالكامل عند ترقية الجهاز أو تلف نظام التشغيل:
            </p>

            <div className="space-y-3">
              {backups.map((bk) => (
                <div key={bk.id} className="p-3 bg-slate-50 rounded-xl border border-slate-100 flex justify-between items-center text-xs">
                  <div>
                    <div className="font-bold text-slate-700 font-mono text-right">{bk.name}</div>
                    <div className="flex gap-3 text-[10px] text-slate-400 mt-1">
                      <span>التاريخ: {bk.date}</span>
                      <span>•</span>
                      <span>الحجم: {bk.size}</span>
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => {
                      triggerAlert('success', `تم استرجاع قاعدة البيانات بنجاح من النسخة: ${bk.name}`);
                    }}
                    className="p-1 px-3 text-[10px] bg-slate-200 hover:bg-slate-300 text-slate-700 font-bold hover:text-slate-900 rounded-lg transition-all cursor-pointer"
                  >
                    استرجاع
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Offline Security & Permissions */}
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
            <h3 className="font-extrabold text-sm text-slate-800 border-b border-slate-50 pb-3">مسح أمني وإدارة الصلاحيات</h3>
            <p className="text-xs text-slate-500 leading-relaxed">
              صممت قواعد الحماية طبقاً لنظام الصلاحيات (Role-Based Access Control). يحتوي النظام على حسابين افتراضيين مدمجين مسبقاً في قاعدة بيانات SQLite لتأكيد المرونة الأمنية والتجربة دون إنترنت:
            </p>

            <div className="space-y-3">
              <div className="p-3.5 bg-indigo-500/5 rounded-xl border border-indigo-100 flex justify-between items-start text-xs">
                <div>
                  <div className="font-extrabold text-indigo-950 flex items-center gap-1">
                    <Shield className="w-4 h-4 text-indigo-600" />
                    حساب مدير النظام (Administrator)
                  </div>
                  <div className="grid grid-cols-2 gap-4 text-[11px] text-slate-600 mt-2 font-medium">
                    <div>المعرف البيني: <code className="font-mono text-indigo-700 text-xs">admin</code></div>
                    <div>كلمة المرور: <code className="font-mono text-indigo-700 text-xs">admin123</code></div>
                  </div>
                  <div className="text-[10px] text-emerald-600 font-bold mt-2">✔ صلاحيات كاملة: التصدير، تغيير الأسعار، ومطالعة الأرباح والتقارير المالية.</div>
                </div>
              </div>

              <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-100 flex justify-between items-start text-xs">
                <div>
                  <div className="font-extrabold text-slate-800 flex items-center gap-1">
                    <Users className="w-4 h-4 text-slate-500" />
                    حساب موظف الاستقبال (Receptionist)
                  </div>
                  <div className="grid grid-cols-2 gap-4 text-[11px] text-slate-600 mt-2 font-medium">
                    <div>المعرف البيني: <code className="font-mono text-slate-700 text-xs">staff</code></div>
                    <div>كلمة المرور: <code className="font-mono text-slate-700 text-xs">staff123</code></div>
                  </div>
                  <div className="text-[10px] text-slate-500 font-bold mt-2">✔ صلاحيات محدودة: الحجز اليومي، ترحيل الغسيل والتنظيف، تدوين هويات الزوار.</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {showBookingForm && (
        <div 
          onClick={() => setShowBookingForm(false)}
          className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex justify-center items-center p-4 z-50 animate-fade-in"
        >
          <div 
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl shadow-xl border border-slate-100 w-full max-w-lg flex flex-col max-h-[90vh] overflow-hidden"
          >
            {/* Header stays locked at the top */}
            <div className="flex justify-between items-center border-b border-slate-100 p-6 pb-4 shrink-0">
              <h3 className="font-black text-sm text-slate-800">إضافة وتوثيق حجز كراء جديد</h3>
              <button type="button" onClick={() => setShowBookingForm(false)} className="p-1.5 hover:bg-slate-100 rounded-lg cursor-pointer transition-all">
                <X className="w-4.5 h-4.5 text-slate-400 hover:text-slate-700" />
              </button>
            </div>

            <form onSubmit={handleCreateBooking} className="flex-1 overflow-y-auto p-6 pt-3 space-y-4 text-xs font-semibold text-slate-700">
              
              {/* Apartment and Required Persons Count */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-slate-600 mb-1.5 font-bold">شقة الكراء المطلوبة *</label>
                  <select
                    required
                    value={newBooking.apartmentId}
                    onChange={(e) => {
                      const aptId = e.target.value;
                      setNewBooking({ ...newBooking, apartmentId: aptId });
                      const apt = apartments.find(a => a.id === aptId);
                      if (apt) {
                        setCustomNightlyPrice(String(apt.nightlyPrice));
                        updateCalculatedTotals(aptId, newBooking.checkInDate, newBooking.checkOutDate, String(apt.nightlyPrice));
                      } else {
                        setCustomNightlyPrice('');
                        setCustomTotalPrice('');
                      }
                    }}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                  >
                    <option value="">-- اختر الشقة --</option>
                    {apartments.map((apt) => (
                      <option key={apt.id} value={apt.id}>
                        {apt.name} ({apt.status === 'occupied' ? 'محجوزة حالياً' : 'متاحة'})
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-slate-600 mb-1.5 font-bold flex items-center justify-between">
                    <span>عدد الأشخاص المقيمين</span>
                    <span className="text-[10px] text-slate-400 bg-slate-100 px-2 py-0.5 rounded-full">اختياري</span>
                  </label>
                  <input
                    type="number"
                    min="1"
                    placeholder="مثال: 2"
                    value={newBooking.personsCount}
                    onChange={(e) => setNewBooking({ ...newBooking, personsCount: e.target.value })}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 font-extrabold focus:bg-white"
                  />
                </div>
              </div>

              {/* Guest Information Tab Selection */}
              <div className="bg-slate-50/80 p-4 rounded-xl border border-slate-200/60 space-y-3">
                <div className="flex justify-between items-center border-b border-slate-200/40 pb-2">
                  <span className="text-xs font-black text-slate-800">بيانات الزبون / النزيل</span>
                  <div className="flex bg-slate-200 p-0.5 rounded-lg text-[10px]">
                    <button
                      type="button"
                      onClick={() => setBookingGuestMode('select')}
                      className={`px-3 py-1 rounded-md font-bold transition-all cursor-pointer ${
                        bookingGuestMode === 'select' ? 'bg-indigo-600 text-white shadow-xs' : 'text-slate-600 hover:text-slate-950'
                      }`}
                    >
                      نزيل سابق
                    </button>
                    <button
                      type="button"
                      onClick={() => setBookingGuestMode('custom')}
                      className={`px-3 py-1 rounded-md font-bold transition-all cursor-pointer ${
                        bookingGuestMode === 'custom' ? 'bg-indigo-600 text-white shadow-xs' : 'text-slate-600 hover:text-slate-950'
                      }`}
                    >
                      نزيل جديد
                    </button>
                  </div>
                </div>

                {bookingGuestMode === 'select' ? (
                  <div>
                    <label className="block text-slate-600 mb-1.5 font-bold">اختر نزيلًا سابقًا مسجلاً من قبل *</label>
                    <select
                      required={bookingGuestMode === 'select'}
                      value={newBooking.guestId}
                      onChange={(e) => setNewBooking({ ...newBooking, guestId: e.target.value })}
                      className="w-full text-right p-3 bg-white rounded-lg border border-slate-250 outline-indigo-500"
                    >
                      <option value="">-- اختر النزيل السابق --</option>
                      {guests.map((g) => (
                        <option key={g.id} value={g.id}>{g.fullName} - {g.phone}</option>
                      ))}
                    </select>
                  </div>
                ) : (
                  <div className="space-y-3">
                    <div>
                      <label className="block text-slate-600 mb-1.5 font-bold">اسم النزيل الكامل (يدوياً) *</label>
                      <input
                        type="text"
                        required={bookingGuestMode === 'custom'}
                        placeholder="مثال: يوسف بن حماد"
                        value={customGuestName}
                        onChange={(e) => setCustomGuestName(e.target.value)}
                        className="w-full text-right p-3 bg-white rounded-lg border border-slate-250 outline-indigo-500"
                      />
                    </div>
                    
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <div>
                        <label className="block text-slate-600 mb-1.5 font-bold">رقم الهاتف للزبون</label>
                        <input
                          type="text"
                          placeholder="مثال: 0555998877"
                          value={customGuestPhone}
                          onChange={(e) => setCustomGuestPhone(e.target.value)}
                          className="w-full text-right p-3 bg-white rounded-lg border border-slate-250 outline-indigo-500"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-slate-600 mb-1.5 font-bold">رقم بطاقة التعريف / جواز السفر</label>
                        <input
                          type="text"
                          placeholder="مثال: 21083746"
                          value={customGuestIdCard}
                          onChange={(e) => setCustomGuestIdCard(e.target.value)}
                          className="w-full text-right p-3 bg-white rounded-lg border border-slate-250 outline-indigo-500"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-slate-655 mb-1.5 font-bold">جنسية الزبون</label>
                      <input
                        type="text"
                        value={customGuestNationality}
                        onChange={(e) => setCustomGuestNationality(e.target.value)}
                        className="w-full text-right p-3 bg-white rounded-lg border border-slate-250 outline-indigo-500"
                      />
                    </div>
                  </div>
                )}
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="block text-slate-600 mb-1.5 font-bold">تاريخ الدخول والوصول *</label>
                  <input
                    type="date"
                    required
                    value={newBooking.checkInDate}
                    onChange={(e) => {
                      const val = e.target.value;
                      if (val) {
                        const nights = parseInt(numNightsState) || 1;
                        const inDate = new Date(val);
                        const outDate = new Date(inDate.getTime() + nights * 24 * 60 * 60 * 1000);
                        const year = outDate.getFullYear();
                        const month = String(outDate.getMonth() + 1).padStart(2, '0');
                        const day = String(outDate.getDate()).padStart(2, '0');
                        const checkOutStr = `${year}-${month}-${day}`;
                        setNewBooking(prev => ({ ...prev, checkInDate: val, checkOutDate: checkOutStr }));
                        updateCalculatedTotals(newBooking.apartmentId, val, checkOutStr, customNightlyPrice);
                      } else {
                        setNewBooking(prev => ({ ...prev, checkInDate: val }));
                        updateCalculatedTotals(newBooking.apartmentId, val, newBooking.checkOutDate, customNightlyPrice);
                      }
                    }}
                    className="w-full p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 text-right"
                  />
                </div>

                <div>
                  <label className="block text-slate-600 mb-1.5 font-bold">عدد ليالي الإقامة</label>
                  <input
                    type="number"
                    min="1"
                    placeholder="مثال: 5"
                    value={numNightsState}
                    onChange={(e) => handleNumNightsChange(e.target.value)}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 font-extrabold focus:bg-white"
                  />
                </div>

                <div>
                  <label className="block text-slate-600 mb-1.5 font-bold">تاريخ المغادرة والخروج *</label>
                  <input
                    type="date"
                    required
                    value={newBooking.checkOutDate}
                    onChange={(e) => {
                      const val = e.target.value;
                      setNewBooking(prev => ({ ...prev, checkOutDate: val }));
                      updateCalculatedTotals(newBooking.apartmentId, newBooking.checkInDate, val, customNightlyPrice);
                    }}
                    className="w-full p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 text-right"
                  />
                </div>
              </div>

              {/* --- Pricing and Manual Bill Overrides --- */}
              <div className="bg-slate-50/80 p-4 rounded-xl border border-slate-200/65 space-y-3">
                <span className="text-xs font-black text-slate-800 block border-b border-slate-200/40 pb-2">تفاصيل التسعير والتحصيل المالي (SQLite Billing)</span>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  <div>
                    <label className="block text-slate-600 mb-1.5 font-bold">سعر الليلة الواحدة المعتمد (د.ج) *</label>
                    <input
                      type="number"
                      required
                      placeholder="مثال: 5000"
                      value={customNightlyPrice}
                      onChange={(e) => {
                        const val = e.target.value;
                        setCustomNightlyPrice(val);
                        updateCalculatedTotals(newBooking.apartmentId, newBooking.checkInDate, newBooking.checkOutDate, val);
                      }}
                      className="w-full text-right p-3 bg-white border border-slate-250 text-indigo-950 font-black rounded-lg focus:ring-1 focus:ring-indigo-500 focus:outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-slate-600 mb-1.5 font-bold">السعر الإجمالي للحجز (د.ج) *</label>
                    <input
                      type="number"
                      required
                      placeholder="مثال: 15000"
                      value={customTotalPrice}
                      onChange={(e) => setCustomTotalPrice(e.target.value)}
                      className="w-full text-right p-3 bg-indigo-50 border border-indigo-200 text-indigo-950 font-black rounded-lg focus:ring-1 focus:ring-indigo-650 focus:bg-white focus:outline-none"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5 pt-1">
                  <div>
                    <label className="block text-slate-600 mb-1.5 font-bold">المبلغ المدفوع كعربون (د.ج)</label>
                    <input
                      type="number"
                      placeholder="مثال: 5000"
                      value={newBooking.paidAmount}
                      onChange={(e) => setNewBooking({ ...newBooking, paidAmount: e.target.value })}
                      className="w-full text-right p-3 bg-white rounded-lg border border-slate-250 outline-indigo-500 font-extrabold"
                    />
                  </div>
                  
                  <div className="flex flex-col justify-center text-[10px] text-slate-500 font-medium leading-relaxed bg-slate-100/50 p-2.5 rounded-lg border border-slate-200/50">
                    <div>
                      💡 سعر الليلة والسعر الإجمالي هما حقلان قابلان للتعديل يدوياً بالكامل للتطابق مع الاتفاق المالي الحر مع النزيل.
                    </div>
                  </div>
                </div>
              </div>

              {/* Administrative notes */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-bold">ملاحظات الحجز الإدارية والخدماتية</label>
                <textarea
                  placeholder="مثل: يرجى تنظيف الشقة وتوفير مناشف نظيفة إضافية..."
                  rows={2}
                  value={newBooking.notes}
                  onChange={(e) => setNewBooking({ ...newBooking, notes: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                ></textarea>
              </div>

              {/* Dynamic Instant Simulated Calculations */}
              {newBooking.apartmentId && newBooking.checkInDate && newBooking.checkOutDate && (
                <div className="p-3.5 bg-indigo-50 rounded-xl border border-indigo-100 text-xs text-indigo-950 font-bold mt-2">
                  {(() => {
                    const apt = getApartmentDetails(newBooking.apartmentId);
                    if (!apt) return '';
                    const inDate = new Date(newBooking.checkInDate);
                    const outDate = new Date(newBooking.checkOutDate);
                    if (isNaN(inDate.getTime()) || isNaN(outDate.getTime()) || inDate >= outDate) return 'تنبيه: التواريخ غير صالحة حالياً لحساب السعر.';
                    
                    const nights = Math.max(1, Math.round((outDate.getTime() - inDate.getTime()) / (1000 * 60 * 60 * 24)));
                    const rate = parseFloat(customNightlyPrice) >= 0 ? parseFloat(customNightlyPrice) : apt.nightlyPrice;
                    const total = parseFloat(customTotalPrice) >= 0 ? parseFloat(customTotalPrice) : (rate * nights);
                    const paid = parseFloat(newBooking.paidAmount) || 0;
                    const remaining = total - paid;
                    const overlapping = checkOverlappingBookings(newBooking.apartmentId, newBooking.checkInDate, newBooking.checkOutDate);

                    return (
                      <div className="space-y-1">
                        <div className="flex justify-between">
                          <span>سعر الليلة المعتمد لهذا الحجز:</span>
                          <span>{rate.toLocaleString('en-US')} د.ج</span>
                        </div>
                        <div className="flex justify-between">
                          <span>عدد الليالي:</span>
                          <span>{nights} ليالٍ</span>
                        </div>
                        <div className="flex justify-between border-t border-indigo-200/50 pt-1 text-sm text-indigo-900 font-extrabold">
                          <span>الإجمالي المعتمد للحجز:</span>
                          <span>{total.toLocaleString('en-US')} د.ج</span>
                        </div>
                        <div className="flex justify-between font-medium text-[10.5px] text-slate-600">
                          <span>المبلغ المتبقي للنزيل:</span>
                          <span className={remaining < 0 ? 'text-rose-600 font-bold' : 'text-slate-800'}>{remaining.toLocaleString('en-US')} د.ج</span>
                        </div>
                        {overlapping && (
                          <div className="text-rose-600 font-extrabold text-center pt-2 flex items-center justify-center gap-1 flex-row-reverse">
                            <AlertTriangle className="w-4 h-4 shrink-0" />
                            تنبيه ازدواجية: الشقة محجوزة مسبقاً في نفس الفترة!
                          </div>
                        )}
                      </div>
                    );
                  })()}
                </div>
              )}

              <button
                type="submit"
                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold py-3 rounded-lg transition-all text-xs cursor-pointer"
              >
                حفظ الحجز في قاعدة بيانات SQLite محلياً
              </button>
            </form>
          </div>
        </div>
      )}

      {/* --- FORM MODAL: APARTMENT FORM --- */}
      {showAptForm && (
        <div 
          onClick={() => setShowAptForm(false)}
          className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex justify-center items-start overflow-y-auto p-4 z-50 animate-fade-in"
        >
          <div 
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl shadow-xl border border-slate-100 w-full max-w-md p-6 space-y-4 my-8"
          >
            <div className="flex justify-between items-center border-b border-slate-100 pb-3">
              <h3 className="font-black text-sm text-slate-800">إضافة وتسجيل شقة جديدة</h3>
              <button type="button" onClick={() => setShowAptForm(false)} className="p-1 hover:bg-slate-150 rounded-lg">
                <X className="w-4 h-4 text-slate-400" />
              </button>
            </div>

            <form onSubmit={handleCreateApartment} className="space-y-4 text-xs font-semibold text-slate-700">
              <div>
                <label className="block text-slate-600 mb-1.5">اسم الشقة أو رقمها كرمز فريد *</label>
                <input
                  type="text"
                  required
                  placeholder="مثال: شقة رقم 301 مطلة"
                  value={newApt.name}
                  onChange={(e) => setNewApt({ ...newApt, name: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-slate-600 mb-1.5">عدد الغرف *</label>
                  <input
                    type="number"
                    required
                    value={newApt.roomsCount}
                    onChange={(e) => setNewApt({ ...newApt, roomsCount: e.target.value })}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                  />
                </div>

                <div>
                  <label className="block text-slate-600 mb-1.5">عدد الأسرة *</label>
                  <input
                    type="number"
                    required
                    value={newApt.bedsCount}
                    onChange={(e) => setNewApt({ ...newApt, bedsCount: e.target.value })}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-slate-600 mb-1.5">السعر الليلي المطلوب (د.ج) *</label>
                <input
                  type="number"
                  required
                  placeholder="مثال: 5500"
                  value={newApt.nightlyPrice}
                  onChange={(e) => setNewApt({ ...newApt, nightlyPrice: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                />
              </div>

              <div>
                <label className="block text-slate-600 mb-1.5">ملاحظات وخصائص الشقة</label>
                <textarea
                  placeholder="مثال: تحتوي على مكيفين هواء وشاشة عرض OLED ذكية..."
                  rows={2}
                  value={newApt.notes}
                  onChange={(e) => setNewApt({ ...newApt, notes: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                ></textarea>
              </div>

              <button
                type="submit"
                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold py-3 rounded-lg transition-all text-xs cursor-pointer"
              >
                مسح وحفظ الشقة في قاعدة SQLite
              </button>
            </form>
          </div>
        </div>
      )}

      {/* --- FORM MODAL: EDIT APARTMENT FORM --- */}
      {editingApt && (
        <div 
          onClick={() => setEditingApt(null)}
          className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex justify-center items-start overflow-y-auto p-4 z-50 animate-fade-in"
        >
          <div 
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl shadow-xl border border-slate-100 w-full max-w-md p-6 space-y-4 my-8"
          >
            <div className="flex justify-between items-center border-b border-slate-100 pb-3">
              <h3 className="font-extrabold text-sm text-slate-800 flex items-center gap-2">
                <Home className="w-4 h-4 text-indigo-600 shrink-0" />
                تعديل وتحديث معطيات الشقة
              </h3>
              <button type="button" onClick={() => setEditingApt(null)} className="p-1 hover:bg-slate-150 rounded-lg cursor-pointer">
                <X className="w-4 h-4 text-slate-400" />
              </button>
            </div>

            <form onSubmit={handleUpdateApartment} className="space-y-4 text-xs font-semibold text-slate-700">
              <div>
                <label className="block text-slate-600 mb-1.5 font-bold">تسمية الشقة أو رقم التعريف الفريد *</label>
                <input
                  type="text"
                  required
                  placeholder="مثال: شقة رقم 301 مطلة"
                  value={editingApt.name}
                  onChange={(e) => setEditingApt({ ...editingApt, name: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-slate-600 mb-1.5 font-bold">عدد الغرف *</label>
                  <input
                    type="number"
                    required
                    value={editingApt.roomsCount}
                    onChange={(e) => setEditingApt({ ...editingApt, roomsCount: parseInt(e.target.value) || 0 })}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                  />
                </div>

                <div>
                  <label className="block text-slate-600 mb-1.5 font-bold">عدد الأسرة *</label>
                  <input
                    type="number"
                    required
                    value={editingApt.bedsCount}
                    onChange={(e) => setEditingApt({ ...editingApt, bedsCount: parseInt(e.target.value) || 0 })}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-slate-600 mb-1.5 font-bold">السعر الليلي المطلوب (د.ج) *</label>
                <input
                  type="number"
                  required
                  placeholder="مثال: 5500"
                  value={editingApt.nightlyPrice}
                  onChange={(e) => setEditingApt({ ...editingApt, nightlyPrice: parseFloat(e.target.value) || 0 })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                />
              </div>

              <div>
                <label className="block text-slate-600 mb-1.5 font-bold">ملاحظات، محتويات وخصائص الشقة</label>
                <textarea
                  placeholder="مثال: تحتوي على غسالة ملابس وميكرويف وتكييف وصالون..."
                  rows={3}
                  value={editingApt.notes || ''}
                  onChange={(e) => setEditingApt({ ...editingApt, notes: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                ></textarea>
              </div>

              <button
                type="submit"
                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold py-3 rounded-lg transition-all text-xs cursor-pointer"
              >
                حفظ التعديلات وتحديث قاعدة البيانات (SQLite Update Statement)
              </button>
            </form>
          </div>
        </div>
      )}

      {/* --- FORM MODAL: GUEST FORM --- */}
      {showGuestForm && (
        <div 
          onClick={() => setShowGuestForm(false)}
          className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex justify-center items-start overflow-y-auto p-4 z-50 animate-fade-in"
        >
          <div 
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl shadow-xl border border-slate-100 w-full max-w-md p-6 space-y-4 my-8"
          >
            <div className="flex justify-between items-center border-b border-slate-100 pb-3">
              <h3 className="font-black text-sm text-slate-800">تسجيل وتأمين بطاقة زبون جديدة</h3>
              <button type="button" onClick={() => setShowGuestForm(false)} className="p-1 hover:bg-slate-150 rounded-lg">
                <X className="w-4 h-4 text-slate-400" />
              </button>
            </div>

            <form onSubmit={handleCreateGuest} className="space-y-4 text-xs font-semibold text-slate-700">
              <div>
                <label className="block text-slate-600 mb-1.5">اسم النزيل الكامل *</label>
                <input
                  type="text"
                  required
                  placeholder="مثال: يونس بلال التبسي"
                  value={newGuest.fullName}
                  onChange={(e) => setNewGuest({ ...newGuest, fullName: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-slate-600 mb-1.5">رقم الهاتف *</label>
                  <input
                    type="text"
                    required
                    placeholder="مثال: 0550123456"
                    value={newGuest.phone}
                    onChange={(e) => setNewGuest({ ...newGuest, phone: e.target.value })}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 text-left font-mono"
                  />
                </div>

                <div>
                  <label className="block text-slate-600 mb-1.5">الجنسية *</label>
                  <input
                    type="text"
                    required
                    value={newGuest.nationality}
                    onChange={(e) => setNewGuest({ ...newGuest, nationality: e.target.value })}
                    className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-slate-600 mb-1.5">رقم بطاقة التعريف الوطنية أو جواز السفر *</label>
                <input
                  type="text"
                  required
                  placeholder="سجل رقم الهوية المطبوع"
                  value={newGuest.idCardNumber}
                  onChange={(e) => setNewGuest({ ...newGuest, idCardNumber: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 text-left font-mono"
                />
              </div>

              <div>
                <label className="block text-slate-600 mb-1.5">سجل السوابق أو ملاحظات سلوكية أمنية</label>
                <textarea
                  placeholder="يرجى كتابة أي معلومات سلوكية للزائر لتأمين العمل المكتبي..."
                  rows={2}
                  value={newGuest.notes}
                  onChange={(e) => setNewGuest({ ...newGuest, notes: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500"
                ></textarea>
              </div>

              <button
                type="submit"
                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold py-3 rounded-lg transition-all text-xs cursor-pointer"
              >
                تثبيت السجل الأمني للزبون
              </button>
            </form>
          </div>
        </div>
      )}

      {/* --- FORM MODAL: EXPENSE FORM --- */}
      {showExpenseForm && (
        <div 
          onClick={() => setShowExpenseForm(false)}
          className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex justify-center items-start overflow-y-auto p-4 z-50 animate-fade-in"
        >
          <div 
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl shadow-xl border border-slate-100 w-full max-w-md p-6 space-y-4 my-8"
          >
            <div className="flex justify-between items-center border-b border-slate-50 pb-3">
              <h3 className="font-extrabold text-sm text-slate-800">تسجيل مصروف مالي جديد</h3>
              <button type="button" onClick={() => setShowExpenseForm(false)} className="p-1 hover:bg-slate-100 rounded-lg cursor-pointer">
                <X className="w-5 h-5 text-slate-400 hover:text-slate-600" />
              </button>
            </div>

            <form onSubmit={handleCreateExpense} className="space-y-4 text-xs font-semibold text-slate-700">
              
              {/* Amount */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold">مبلغ المصروف (د.ج) *</label>
                <input
                  type="number"
                  min="1"
                  required
                  placeholder="مثال: 5000"
                  value={newExpense.amount}
                  onChange={(e) => setNewExpense({ ...newExpense, amount: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 font-extrabold focus:bg-white"
                />
              </div>

              {/* Date */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold">تاريخ العملية *</label>
                <input
                  type="date"
                  required
                  value={newExpense.date}
                  onChange={(e) => setNewExpense({ ...newExpense, date: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 font-bold focus:bg-white"
                />
              </div>

              {/* Category */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold">نوع المصروف *</label>
                <select
                  value={newExpense.category}
                  onChange={(e) => setNewExpense({ ...newExpense, category: e.target.value as any })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 focus:bg-white font-bold"
                >
                  <option value="maintenance">⚙️ صيانة</option>
                  <option value="cleaning">🧼 تنظيف</option>
                  <option value="bills">⚡ فواتير الماء والكهرباء والاشتراكات</option>
                  <option value="furniture">🪑 شراء تجهيزات أو أثاث</option>
                  <option value="other">📦 مصاريف أخرى</option>
                </select>
              </div>

              {/* Notes */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold">بند أو وصف وتفاصيل المصروف *</label>
                <textarea
                  required
                  rows={2}
                  placeholder="بيان الفاتورة أو الخدمة المقتناة بالتفصيل..."
                  value={newExpense.notes}
                  onChange={(e) => setNewExpense({ ...newExpense, notes: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 border border-slate-250 rounded-lg focus:bg-white focus:outline-indigo-500 font-medium"
                ></textarea>
              </div>

              {/* Related Apartment (Optional) */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold">تخصيص المصروف لشقة العطلات (اختياري)</label>
                <select
                  value={newExpense.apartmentId}
                  onChange={(e) => setNewExpense({ ...newExpense, apartmentId: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-250 outline-indigo-500 focus:bg-white font-bold"
                >
                  <option value="">-- مصروف عام لمجمل الشقق --</option>
                  {apartments.map((apt) => (
                    <option key={apt.id} value={apt.id}>{apt.name}</option>
                  ))}
                </select>
              </div>

              <div className="pt-2 flex gap-3">
                <button
                  type="submit"
                  className="flex-grow p-3 bg-rose-600 hover:bg-rose-700 text-white rounded-lg font-extrabold transition-all shadow-md cursor-pointer text-center text-xs"
                >
                  تسجيل وإسقاط المصروف بقاعدة البيانات
                </button>
                <button
                  type="button"
                  onClick={() => setShowExpenseForm(false)}
                  className="p-3 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-lg font-bold transition-all cursor-pointer text-center text-xs"
                >
                  إلغاء
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};
