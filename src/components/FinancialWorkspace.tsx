import React, { useState } from 'react';
import { Search, Plus, Trash2, X } from 'lucide-react';
import { Apartment, Booking, Guest, Expense } from '../types/rental';

interface FinancialWorkspaceProps {
  bookings: Booking[];
  expenses: Expense[];
  apartments: Apartment[];
  guests: Guest[];
  setExpenses: React.Dispatch<React.SetStateAction<Expense[]>>;
  addingAmounts: Record<string, string>;
  setAddingAmounts: React.Dispatch<React.SetStateAction<Record<string, string>>>;
  handleAddPayment: (bookingId: string) => void;
  handlePayFullInvoice: (bookingId: string) => void;
  triggerAlert: (type: 'success' | 'error' | 'info', text: string) => void;
}

export const FinancialWorkspace: React.FC<FinancialWorkspaceProps> = ({
  bookings,
  expenses,
  apartments,
  guests,
  setExpenses,
  addingAmounts,
  setAddingAmounts,
  handleAddPayment,
  handlePayFullInvoice,
  triggerAlert,
}) => {
  // Financial Sub-system Tabs & Forms
  const [paymentsSubTab, setPaymentsSubTab] = useState<'invoices' | 'expenses' | 'reports'>('invoices');
  const [showExpenseForm, setShowExpenseForm] = useState<boolean>(false);
  const [searchQuery, setSearchQuery] = useState<string>('');
  
  const [newExpense, setNewExpense] = useState({
    amount: '',
    date: '2026-06-01', // Default simulation clock (Matches other bookings)
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

  // Helper inside workspace to handle expense submission
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

  // Helper to verify if a transaction falls within the selected date filters
  const isDateInFilterRange = (dateStr: string) => {
    if (!dateStr) return false;
    const date = dateStr.substring(0, 10); // YYYY-MM-DD
    
    if (reportFilterType === 'day') {
      return date === reportFilterDay;
    } else if (reportFilterType === 'month') {
      return date.startsWith(reportFilterMonth);
    } else if (reportFilterType === 'year') {
      return date.startsWith(reportFilterYear);
    } else if (reportFilterType === 'custom') {
      return date >= reportFilterStartDate && date <= reportFilterEndDate;
    }
    return true;
  };

  // 1. Core Totals
  const filteredBookings = bookings.filter(b => b.status !== 'cancelled' && isDateInFilterRange(b.checkInDate));
  const filteredExpenses = expenses.filter(e => isDateInFilterRange(e.date));

  const totalIncome = filteredBookings.reduce((sum, b) => sum + b.paidAmount, 0);
  const totalExpenses = filteredExpenses.reduce((sum, e) => sum + e.amount, 0);
  const netProfit = totalIncome - totalExpenses;

  // 2. Performance of each apartment
  const apartmentPerformances = apartments.map(apt => {
    const aptBookings = bookings.filter(b => b.apartmentId === apt.id && b.status !== 'cancelled' && isDateInFilterRange(b.checkInDate));
    const aptExpenses = expenses.filter(e => e.apartmentId === apt.id && isDateInFilterRange(e.date));
    
    const inc = aptBookings.reduce((sum, b) => sum + b.paidAmount, 0);
    const exp = aptExpenses.reduce((sum, e) => sum + e.amount, 0);
    const profit = inc - exp;
    
    return {
      apartment: apt,
      income: inc,
      expenses: exp,
      profit: profit
    };
  });

  // Most Profitable & Most Expensive Apartments
  const sortedByProfit = [...apartmentPerformances].sort((a, b) => b.profit - a.profit);
  const mostProfitable = sortedByProfit.length > 0 && sortedByProfit[0].profit > 0 ? sortedByProfit[0] : null;

  const sortedByExpense = [...apartmentPerformances].sort((a, b) => b.expenses - a.expenses);
  const mostExpensive = sortedByExpense.length > 0 && sortedByExpense[0].expenses > 0 ? sortedByExpense[0] : null;

  // 3. Profits by Month (for selected / filtered year, default 2026)
  const activeYearForMonthly = reportFilterType === 'year' ? reportFilterYear : reportFilterMonth.substring(0, 4) || '2026';
  const monthNamesArabic = [
    'جانفي', 'فيفري', 'مارس', 'أبريل', 'ماي', 'جوان',
    'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  const monthlyData = Array.from({ length: 12 }, (_, i) => {
    const monthStr = `${activeYearForMonthly}-${String(i + 1).padStart(2, '0')}`;
    const monthlyBookings = bookings.filter(b => b.status !== 'cancelled' && b.checkInDate.startsWith(monthStr));
    const monthlyExpenses = expenses.filter(e => e.date.startsWith(monthStr));
    
    const inc = monthlyBookings.reduce((sum, b) => sum + b.paidAmount, 0);
    const exp = monthlyExpenses.reduce((sum, e) => sum + e.amount, 0);
    return {
      monthKey: monthStr,
      monthName: monthNamesArabic[i],
      income: inc,
      expenses: exp,
      profit: inc - exp
    };
  });

  // Max value in monthly data for scaling the CSS bars
  const maxMonthlyVal = Math.max(...monthlyData.map(d => Math.max(d.income, d.expenses))) || 1;

  // 4. Profits by Year (Target: 2025, 2026, 2027)
  const targetYears = ['2025', '2026', '2027'];
  const yearlyData = targetYears.map(yr => {
    const yrBookings = bookings.filter(b => b.status !== 'cancelled' && b.checkInDate.startsWith(yr));
    const yrExpenses = expenses.filter(e => e.date.startsWith(yr));
    const inc = yrBookings.reduce((sum, b) => sum + b.paidAmount, 0);
    const exp = yrExpenses.reduce((sum, e) => sum + e.amount, 0);
    return {
      year: yr,
      income: inc,
      expenses: exp,
      profit: inc - exp
    };
  });

  return (
    <div className="bg-white rounded-2xl border border-slate-150 shadow-sm p-6 space-y-6 animate-fade-in text-slate-800 text-xs text-right [direction:rtl]">
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-4 border-b border-slate-50 pb-4">
        <div>
          <h3 className="font-extrabold text-sm text-slate-850">قائمة المدفوعات والتحصيل والتقارير المالية</h3>
          <p className="text-xs text-slate-500 mt-1">تتبع التدفقات النقدية الواردة، تدوين مصاريف التشغيل بالتواريخ، وتحليل غلة الوحدات العقارية</p>
        </div>
        
        {/* Core Overall Stats Tracker (Reflective) */}
        <div className="flex flex-wrap gap-4 select-none">
          <div className="bg-emerald-50/55 p-2 py-3 px-4 rounded-xl border border-emerald-100 text-center min-w-[100px]">
            <div className="text-[9px] text-emerald-600 font-bold">المداخيل المقبوضة</div>
            <div className="text-xs font-black text-emerald-800 mt-0.5">
              {bookings.reduce((sum, b) => b.status !== 'cancelled' ? sum + b.paidAmount : sum, 0).toLocaleString()} د.ج
            </div>
          </div>
          <div className="bg-rose-50/55 p-2 py-3 px-4 rounded-xl border border-rose-100 text-center min-w-[100px]">
            <div className="text-[9px] text-rose-500 font-bold font-sans">المصاريف التشغيلية</div>
            <div className="text-xs font-black text-rose-800 mt-0.5">
              {expenses.reduce((sum, e) => sum + e.amount, 0).toLocaleString()} د.ج
            </div>
          </div>
          <div className="bg-indigo-50/55 p-2 py-3 px-4 rounded-xl border border-indigo-100 text-center min-w-[100px]">
            <div className="text-[9px] text-indigo-600 font-bold">صافي الأرباح المتاحة</div>
            <div className="text-xs font-black text-indigo-800 mt-0.5">
              {(bookings.reduce((sum, b) => b.status !== 'cancelled' ? sum + b.paidAmount : sum, 0) - expenses.reduce((sum, e) => sum + e.amount, 0)).toLocaleString()} د.ج
            </div>
          </div>
        </div>
      </div>

      {/* Sub-Tabs Selector inside payments workspace */}
      <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200 w-full max-w-xl select-none">
        <button
          type="button"
          onClick={() => { setPaymentsSubTab('invoices'); setSearchQuery(''); }}
          className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all cursor-pointer ${
            paymentsSubTab === 'invoices'
              ? 'bg-white text-indigo-950 shadow-xs border border-slate-200/50'
              : 'text-slate-500 hover:text-slate-850'
          }`}
        >
          💵 تحصيل الإيرادات
        </button>
        <button
          type="button"
          onClick={() => { setPaymentsSubTab('expenses'); setSearchQuery(''); }}
          className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all cursor-pointer flex items-center justify-center gap-1.5 ${
            paymentsSubTab === 'expenses'
              ? 'bg-white text-indigo-950 shadow-xs border border-slate-200/50'
              : 'text-slate-500 hover:text-slate-850'
          }`}
        >
          💸 المصاريف التشغيلية ({expenses.length})
        </button>
        <button
          type="button"
          onClick={() => { setPaymentsSubTab('reports'); setSearchQuery(''); }}
          className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all cursor-pointer ${
            paymentsSubTab === 'reports'
              ? 'bg-white text-indigo-950 shadow-xs border border-slate-200/50'
              : 'text-slate-500 hover:text-slate-850'
          }`}
        >
          📊 تقارير ودراسة النشاط
        </button>
      </div>

      {/* --- SUB TAB 1: INVOICES AND REVENUE RECEPTION --- */}
      {paymentsSubTab === 'invoices' && (
        <div className="space-y-4 animate-fade-in">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
            <h4 className="font-extrabold text-xs text-slate-700 bg-slate-50 border border-slate-100 inline-block px-3 py-1 rounded-full">
              سجلات الفواتير ومبالغ تحصيل النزلاء
            </h4>
          </div>
          {/* Search bar specifically for invoices */}
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

          {/* List / Table of Outstanding Invoices */}
          <div className="overflow-x-auto rounded-xl border border-slate-100">
            <table className="w-full text-right border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/70 text-slate-700 border-b border-slate-150">
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
              <tbody className="divide-y divide-slate-100 text-slate-600 font-semibold text-[11px]">
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
                        <td className="p-4">
                          <div className="font-bold text-slate-850">{guest?.fullName}</div>
                          <div className="text-[10px] text-slate-400 mt-0.5">{guest?.phone}</div>
                        </td>
                        <td className="p-4 font-extrabold text-indigo-950">{apt?.name}</td>
                        <td className="p-4 font-extrabold text-slate-800">{b.totalPrice.toLocaleString()} د.ج</td>
                        <td className="p-4">
                          <div className="font-bold text-emerald-600">{b.paidAmount.toLocaleString()} د.ج</div>
                          <div className="w-20 bg-slate-100 rounded-full h-1 mt-1 overflow-hidden" title={`${percentPaid}% مدفوع`}>
                            <div className="bg-emerald-500 h-1 rounded-full transition-all" style={{ width: `${percentPaid}%` }}></div>
                          </div>
                        </td>
                        <td className="p-4">
                          <span className={`font-black text-xs ${b.remainingAmount > 0 && b.status !== 'cancelled' ? 'text-rose-600' : 'text-slate-500'}`}>
                            {b.status === 'cancelled' ? 'ملغى' : b.remainingAmount === 0 ? 'لا يوجد (خالص)' : `${b.remainingAmount.toLocaleString()} د.ج`}
                          </span>
                        </td>
                        <td className="p-4">
                          {b.status !== 'cancelled' && b.remainingAmount > 0 ? (
                            <div className="flex gap-1.5 items-center max-w-[150px]">
                              <input
                                type="number"
                                placeholder="المبلغ"
                                value={addingAmounts[b.id] || ''}
                                onChange={(e) => setAddingAmounts({ ...addingAmounts, [b.id]: e.target.value })}
                                className="w-20 p-1.5 bg-slate-50 border border-slate-200 rounded-lg text-right text-xs outline-indigo-500 font-bold"
                              />
                              <button
                                type="button"
                                onClick={() => handleAddPayment(b.id)}
                                className="px-2 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-bold text-[10px] cursor-pointer"
                              >
                                تحصيل
                              </button>
                            </div>
                          ) : (
                            <span className="text-slate-500 text-[10px] italic">
                              {b.status === 'cancelled' ? 'دورة ملغاة' : 'تم تسوية الفاتورة'}
                            </span>
                          )}
                        </td>
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

      {/* --- SUB TAB 2: OPERATING EXPENSES --- */}
      {paymentsSubTab === 'expenses' && (
        <div className="space-y-5 animate-fade-in">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
              <h4 className="font-extrabold text-xs text-slate-700 bg-slate-50 border border-slate-100 inline-block px-3 py-1 rounded-full">
                جداول ومتابعة المصاريف التشغيلية للمنشأة
              </h4>
              <p className="text-[11px] text-slate-400 mt-1 font-semibold">تسجيل دوري لمصاريف الصيانة والتنظيف والتجهيزات وتحميلها على شقق مخصصة</p>
            </div>

            <button
              type="button"
              onClick={() => setShowExpenseForm(true)}
              className="bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold px-4 py-2.5 rounded-xl transition-all cursor-pointer flex items-center gap-1.5 self-end sm:self-auto shadow-sm"
            >
              <Plus className="w-4 h-4" />
              تسجيل مصروف مالي جديد
            </button>
          </div>

          {/* Expense search bar */}
          <div className="relative flex items-center">
            <Search className="absolute right-4 w-4 h-4 text-slate-400" />
            <input
              type="text"
              placeholder="البحث في المصاريف باسم الشقة، الوصف، أو نوع المصروف..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full text-right p-3 pr-11 bg-slate-50 rounded-xl border border-slate-100 text-xs focus:bg-white focus:outline-indigo-500 font-semibold"
            />
          </div>

          {/* List / Table of Operating Expenses */}
          <div className="overflow-x-auto rounded-xl border border-slate-100">
            <table className="w-full text-right border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/70 text-slate-700 border-b border-slate-100">
                  <th className="p-4 font-bold">التاريخ</th>
                  <th className="p-4 font-bold">نوع المصروف</th>
                  <th className="p-4 font-bold">البيان / الوصف</th>
                  <th className="p-4 font-bold">الشقة المرتبطة</th>
                  <th className="p-4 font-bold text-left">القيمة المالية</th>
                  <th className="p-4 font-bold text-center">حملة الشطب</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-600 font-semibold text-[11px]">
                {expenses.filter(e => {
                  const query = searchQuery.toLowerCase();
                  const categoryLabel = {
                    maintenance: 'صيانة',
                    cleaning: 'تنظيف',
                    bills: 'ماء وكهرباء واشتراكات',
                    furniture: 'تجهيزات وأثاث',
                    other: 'مصاريف أخرى'
                  }[e.category] || '';
                  const apt = apartments.find(a => a.id === e.apartmentId);
                  return (
                    e.notes.toLowerCase().includes(query) ||
                    categoryLabel.toLowerCase().includes(query) ||
                    (apt && apt.name.toLowerCase().includes(query))
                  );
                }).length > 0 ? (
                  expenses.filter(e => {
                    const query = searchQuery.toLowerCase();
                    const categoryLabel = {
                      maintenance: 'صيانة',
                      cleaning: 'تنظيف',
                      bills: 'ماء وكهرباء واشتراكات',
                      furniture: 'تجهيزات وأثاث',
                      other: 'مصاريف أخرى'
                    }[e.category] || '';
                    const apt = apartments.find(a => a.id === e.apartmentId);
                    return (
                      e.notes.toLowerCase().includes(query) ||
                      categoryLabel.toLowerCase().includes(query) ||
                      (apt && apt.name.toLowerCase().includes(query))
                    );
                  }).map((e) => {
                    const apt = apartments.find(a => a.id === e.apartmentId);
                    return (
                      <tr key={e.id} className="hover:bg-slate-50/40">
                        <td className="p-4 font-mono font-bold text-slate-700">{e.date}</td>
                        <td className="p-4">
                          <span className={`px-2 py-1 rounded-full text-[10px] font-bold ${
                            e.category === 'maintenance' ? 'bg-amber-50 text-amber-800 border border-amber-200' :
                            e.category === 'cleaning' ? 'bg-emerald-50 text-emerald-800 border border-emerald-200' :
                            e.category === 'bills' ? 'bg-blue-50 text-blue-800 border border-blue-200' :
                            e.category === 'furniture' ? 'bg-purple-50 text-purple-800 border border-purple-200' :
                            'bg-slate-50 text-slate-800 border border-slate-200'
                          }`}>
                            {{
                              maintenance: '⚙️ صيانة',
                              cleaning: '🧼 تنظيف',
                              bills: '⚡ فواتير',
                              furniture: '🪑 أثاث',
                              other: '📦 أخرى'
                            }[e.category]}
                          </span>
                        </td>
                        <td className="p-4 text-slate-800 font-bold max-w-sm truncate" title={e.notes}>{e.notes}</td>
                        <td className="p-4 font-bold text-indigo-950">{apt ? apt.name : '— (عام للمنشأة)'}</td>
                        <td className="p-4 text-left font-black text-rose-600">-{e.amount.toLocaleString()} د.ج</td>
                        <td className="p-4 text-center">
                          <button
                            type="button"
                            onClick={() => handleDeleteExpense(e.id)}
                            className="p-1 hover:bg-rose-50 text-rose-500 hover:text-rose-700 rounded transition-all cursor-pointer"
                          >
                            <Trash2 className="w-4 h-4 inline" />
                          </button>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan={6} className="p-8 text-center text-slate-400 font-semibold bg-slate-50/20">
                      لا توجد مصاريف تشغيلية مسجلة تطابق محددات البحث.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* --- SUB TAB 3: FINANCIAL STUDIES & REPORTING --- */}
      {paymentsSubTab === 'reports' && (
        <div className="space-y-6 animate-fade-in">
          
          {/* Filter controls row */}
          <div className="bg-slate-50 rounded-2xl p-5 border border-slate-100 space-y-4">
            <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-4">
              <div>
                <h4 className="font-extrabold text-xs text-slate-800 flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-indigo-600"></span>
                  محددات تصفية التقارير المالية والربحية
                </h4>
                <p className="text-[10px] text-slate-400 mt-1 font-semibold">اختر النطاق الزمني لعرض غلة الشقق والمقارنات مع النفقات المقابلة بدقة</p>
              </div>

              {/* Period Type options */}
              <div className="flex bg-slate-200/80 p-0.5 rounded-lg text-xs font-bold w-full lg:w-auto">
                {[
                  { id: 'day', label: 'يوم' },
                  { id: 'month', label: 'شهر' },
                  { id: 'year', label: 'سنة' },
                  { id: 'custom', label: 'فترة مخصصة' }
                ].map(opt => (
                  <button
                    key={opt.id}
                    type="button"
                    onClick={() => setReportFilterType(opt.id as any)}
                    className={`flex-1 lg:flex-none px-4 py-1.5 rounded-md cursor-pointer transition-all ${
                      reportFilterType === opt.id
                        ? 'bg-white text-indigo-950 shadow-xs'
                        : 'text-slate-500 hover:text-slate-850'
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Specific Input fields based on reportFilterType */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-2 text-xs font-bold text-slate-600">
              
              {reportFilterType === 'day' && (
                <div className="col-span-3 max-w-sm">
                  <label className="block mb-1.5 text-slate-500">اختر تاريخ اليوم للمطابقة:</label>
                  <input
                    type="date"
                    value={reportFilterDay}
                    onChange={(e) => setReportFilterDay(e.target.value)}
                    className="w-full p-2.5 bg-white rounded-lg border border-slate-200 focus:outline-indigo-500 font-extrabold text-right"
                  />
                </div>
              )}

              {reportFilterType === 'month' && (
                <div className="col-span-3 max-w-sm">
                  <label className="block mb-1.5 text-slate-500">اختر الشهر المستهدف:</label>
                  <input
                    type="month"
                    value={reportFilterMonth}
                    onChange={(e) => setReportFilterMonth(e.target.value)}
                    className="w-full p-2.5 bg-white rounded-lg border border-slate-200 focus:outline-indigo-500 font-extrabold text-right"
                  />
                </div>
              )}

              {reportFilterType === 'year' && (
                <div className="col-span-3 max-w-sm">
                  <label className="block mb-1.5 text-slate-500">السنة المالية المستهدفة:</label>
                  <select
                    value={reportFilterYear}
                    onChange={(e) => setReportFilterYear(e.target.value)}
                    className="w-full p-2.5 bg-white rounded-lg border border-slate-200 focus:outline-indigo-500 font-bold"
                  >
                    <option value="2025">سنة 2025</option>
                    <option value="2026">سنة 2026</option>
                    <option value="2027">سنة 2027</option>
                  </select>
                </div>
              )}

              {reportFilterType === 'custom' && (
                <>
                  <div>
                    <label className="block mb-1.5 text-slate-500">تاريخ البداية (من):</label>
                    <input
                      type="date"
                      value={reportFilterStartDate}
                      onChange={(e) => setReportFilterStartDate(e.target.value)}
                      className="w-full p-2.5 bg-white rounded-lg border border-slate-200 focus:outline-indigo-500 font-bold text-right"
                    />
                  </div>
                  <div>
                    <label className="block mb-1.5 text-slate-500">تاريخ النهاية (إلى):</label>
                    <input
                      type="date"
                      value={reportFilterEndDate}
                      onChange={(e) => setReportFilterEndDate(e.target.value)}
                      className="w-full p-2.5 bg-white rounded-lg border border-slate-200 focus:outline-indigo-500 font-bold text-right"
                    />
                  </div>
                </>
              )}

            </div>
          </div>

          {/* Financial Report Numbers Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 select-none">
            <div className="bg-emerald-50/45 p-5 rounded-2xl border border-emerald-100 flex flex-col justify-between space-y-2">
              <div className="text-[10px] text-emerald-600 font-extrabold uppercase">إجمالي المداخيل</div>
              <div className="text-2xl font-black text-emerald-800">
                {totalIncome.toLocaleString()} د.ج
              </div>
              <p className="text-[10px] text-emerald-600 mt-1.5 leading-relaxed font-bold">
                * مجموع دفعات العربون والتحصيلات المستلمة والمنقولة للنشاط خلال محدد الوقت المفرز.
              </p>
            </div>

            <div className="bg-rose-50/45 p-5 rounded-2xl border border-rose-100 flex flex-col justify-between space-y-2">
              <div className="text-[10px] text-rose-500 font-extrabold uppercase">إجمالي المصاريف</div>
              <div className="text-2xl font-black text-rose-800">
                {totalExpenses.toLocaleString()} د.ج
              </div>
              <p className="text-[10px] text-rose-500 mt-1.5 leading-relaxed font-bold">
                * إجمالي فواتير الصيانة، مواد الغسيل والمنظفات والماء وغيرها المعقودة في نفس النطاق.
              </p>
            </div>

            <div className={`p-5 rounded-2xl border flex flex-col justify-between space-y-2 ${
              netProfit >= 0 ? 'bg-indigo-50/45 border-indigo-100' : 'bg-red-50/45 border-red-100'
            }`}>
              <div className="text-[10px] font-extrabold uppercase text-slate-600">صافي الربح</div>
              <div className={`text-2xl font-black ${netProfit >= 0 ? 'text-indigo-800' : 'text-red-800'}`}>
                {netProfit.toLocaleString()} د.ج
              </div>
              <div className="flex justify-between items-center text-[10px] font-bold mt-1.5">
                <span className={netProfit >= 0 ? 'text-indigo-600' : 'text-red-650'}>
                  المحصلة العامة: {netProfit >= 0 ? '📈 حصيلة رابحة' : '⚠️ عجز بالموازنة خلال النطاق'}
                </span>
              </div>
            </div>
          </div>

          {/* Leading Indicators */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            
            <div className="bg-slate-50 rounded-2xl p-5 border border-slate-100 space-y-1 flex items-center justify-between">
              <div className="space-y-1">
                <div className="text-[10px] text-slate-500 font-extrabold">
                  👑 أكثر الشقق ربحية
                </div>
                {mostProfitable ? (
                  <>
                    <h4 className="text-sm font-black text-indigo-950 mt-1">{mostProfitable.apartment.name}</h4>
                    <p className="text-[10px] text-slate-500">
                      مجموع المقبوضات: <span className="text-emerald-700 font-extrabold">{mostProfitable.income.toLocaleString()} د.ج</span>
                    </p>
                  </>
                ) : (
                  <h4 className="text-xs font-bold text-slate-400 mt-1">لا توجد مداخيل مسجلة بالفترة</h4>
                )}
              </div>
              
              <div className="w-11 h-11 bg-orange-50 rounded-xl flex items-center justify-center text-orange-600 shrink-0 font-extrabold text-sm border border-orange-100">
                🏆
              </div>
            </div>

            <div className="bg-slate-50 rounded-2xl p-5 border border-slate-100 space-y-1 flex items-center justify-between">
              <div className="space-y-1">
                <div className="text-[10px] text-slate-500 font-extrabold">
                  ⚙️ أكثر الشقق تكلفة من حيث المصاريف
                </div>
                {mostExpensive ? (
                  <>
                    <h4 className="text-sm font-black text-rose-900 mt-1">{mostExpensive.apartment.name}</h4>
                    <p className="text-[10px] text-slate-500">
                      مجموع النفقات والتكاليف: <span className="text-rose-700 font-extrabold">{mostExpensive.expenses.toLocaleString()} د.ج</span>
                    </p>
                  </>
                ) : (
                  <h4 className="text-xs font-bold text-slate-400 mt-1">لا توجد مصاريف مخصصة لشقق بالفترة</h4>
                )}
              </div>

              <div className="w-11 h-11 bg-rose-50 rounded-xl flex items-center justify-center text-rose-700 shrink-0 font-extrabold text-sm border border-rose-100">
                💸
              </div>
            </div>

          </div>

          {/* Profits by Month Visualization and Yearly Performance comparative grids */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            
            {/* Monthly Charts simulation by pure beautiful Tailwind indicators */}
            <div className="bg-white rounded-2xl border border-slate-150 p-5 space-y-4 lg:col-span-2">
              <div className="flex justify-between items-center border-b border-slate-100 pb-3">
                <h4 className="text-xs font-extrabold text-slate-800">الأرباح حسب الشهر لسنة {activeYearForMonthly}</h4>
                <span className="text-[9px] bg-slate-100 text-slate-500 px-2 py-0.5 rounded font-black font-mono">Statistical Ledger</span>
              </div>

              {/* Stacked Chart mockups */}
              <div className="space-y-4 pt-1 select-none">
                {monthlyData.map((d) => {
                  const incPct = d.income > 0 ? (d.income / maxMonthlyVal) * 100 : 0;
                  const expPct = d.expenses > 0 ? (d.expenses / maxMonthlyVal) * 100 : 0;
                  
                  return (
                    <div key={d.monthKey} className="group flex flex-col md:flex-row items-stretch md:items-center gap-2 md:gap-4 text-[10px] font-bold">
                      
                      {/* Label */}
                      <div className="w-16 shrink-0 text-slate-600 text-right">{d.monthName}</div>
                      
                      {/* Bars representation */}
                      <div className="flex-1 space-y-1.5 bg-slate-50/50 p-1.5 rounded-lg border border-slate-100/50">
                        
                        {/* Income Bar */}
                        {d.income > 0 && (
                          <div className="flex items-center gap-2">
                            <div 
                              className="bg-emerald-500 h-2 rounded-sm transition-all" 
                              style={{ width: `${Math.max(3, incPct)}%` }}
                            ></div>
                            <span className="text-emerald-700 text-[8px] font-bold">+{d.income.toLocaleString()} د.ج (إيراد)</span>
                          </div>
                        )}

                        {/* Expense Bar */}
                        {d.expenses > 0 && (
                          <div className="flex items-center gap-2">
                            <div 
                              className="bg-rose-500 h-1.5 rounded-sm transition-all" 
                              style={{ width: `${Math.max(3, expPct)}%` }}
                            ></div>
                            <span className="text-rose-600 text-[8px] font-bold">-{d.expenses.toLocaleString()} د.ج (مصروف)</span>
                          </div>
                        )}

                        {d.income === 0 && d.expenses === 0 && (
                          <div className="text-[9px] text-slate-400 italic text-right pr-2">سجل خالٍ من الحركات المباشرة</div>
                        )}

                      </div>

                      {/* Net monthly profit tag */}
                      {(d.income > 0 || d.expenses > 0) && (
                        <div className={`w-28 text-left shrink-0 text-[10px] font-black ${d.profit >= 0 ? 'text-indigo-700' : 'text-red-700'}`}>
                          الصافي: {d.profit.toLocaleString()} د.ج {d.profit >= 0 ? '✓' : '⚠️'}
                        </div>
                      )}
                      
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Yearly Profits summary */}
            <div className="bg-white rounded-2xl border border-slate-150 p-5 space-y-4">
              <div className="border-b border-slate-100 pb-3">
                <h4 className="text-xs font-extrabold text-slate-805">الأرباح حسب السنة</h4>
                <p className="text-[10px] text-slate-400 mt-1 font-semibold font-sans">مقارنة تراكمية لعوائد السنوات الثلاثة بقاعدة البيانات</p>
              </div>

              <div className="space-y-3 pt-1">
                {yearlyData.map((y) => (
                  <div key={y.year} className="bg-slate-50 rounded-xl p-3 border border-slate-100 flex flex-col gap-1.5">
                    <div className="flex justify-between items-center text-xs font-black text-slate-800">
                      <span>سنة {y.year}</span>
                      <span className={y.profit >= 0 ? 'text-indigo-600' : 'text-rose-600 font-bold'}>
                        {y.profit >= 0 ? 'ربح ✓' : 'عجز ⚠️'}
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-2 text-[10px] font-bold text-slate-500">
                      <div>
                        <span>الإيراد المقبوض:</span>
                        <div className="text-emerald-700 font-extrabold">{y.income.toLocaleString()} د.ج</div>
                      </div>
                      <div>
                        <span>إجمالي النفقات:</span>
                        <div className="text-rose-700 font-extrabold">{y.expenses.toLocaleString()} د.ج</div>
                      </div>
                    </div>

                    <div className="border-t border-slate-200/50 pt-1.5 flex justify-between items-center text-[10px] font-black text-slate-800 leading-normal">
                      <span>الربح الحقيقي:</span>
                      <span className={y.profit >= 0 ? 'text-indigo-700' : 'text-rose-600'}>{y.profit.toLocaleString()} د.ج</span>
                    </div>
                  </div>
                ))}
              </div>

            </div>

          </div>

          {/* Apartment-by-apartment performance ledger */}
          <div className="bg-white rounded-2xl border border-slate-150 p-5 space-y-4">
            <div className="border-b border-slate-100 pb-3">
              <h4 className="text-xs font-extrabold text-slate-800">أداء وجدوى كل شقة عقارية بالفترة المحددة</h4>
              <p className="text-[10px] text-slate-400 mt-1 font-semibold">حصيلة الشقق بالتفصيل ومستوى مساهمتها بمداخيل الكراء مطروحاً منها مصاريفها المخصصة</p>
            </div>

            <div className="overflow-x-auto rounded-xl border border-slate-100 animate-fade-in">
              <table className="w-full text-right border-collapse text-xs">
                <thead>
                  <tr className="bg-slate-50/70 text-slate-700 border-b border-slate-150">
                    <th className="p-3 font-bold">اسم شقة العطلات</th>
                    <th className="p-3 font-bold">الخصائص المربحة والتسعير</th>
                    <th className="p-3 font-bold text-left bg-emerald-50/20 mr-1">عوائد الكراء المحصّلة</th>
                    <th className="p-3 font-bold text-left bg-rose-50/20 mr-1">نفقات ومصاريف الشقة</th>
                    <th className="p-3 font-bold text-left bg-indigo-50/20 mr-1">صافي الغلة المالية</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-slate-600 font-semibold font-mono text-[11px]">
                  {apartmentPerformances.map((perf) => (
                    <tr key={perf.apartment.id} className="hover:bg-slate-50/45">
                      <td className="p-3 font-sans font-black text-indigo-950">{perf.apartment.name}</td>
                      <td className="p-3 font-sans text-slate-400 text-[10px]">
                        {perf.apartment.roomsCount} غرف • {perf.apartment.bedsCount} أسِرّة • {perf.apartment.nightlyPrice.toLocaleString()} د.ج/ليلة
                      </td>
                      <td className="p-3 text-left font-black text-emerald-700 bg-emerald-50/10">
                        {perf.income.toLocaleString()} د.ج
                      </td>
                      <td className="p-3 text-left font-black text-rose-600 bg-rose-50/10">
                        -{perf.expenses.toLocaleString()} د.ج
                      </td>
                      <td className={`p-3 text-left font-black bg-indigo-50/10 ${perf.profit >= 0 ? 'text-indigo-700' : 'text-red-700'}`}>
                        {perf.profit.toLocaleString()} د.ج
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      )}

      {/* --- FORM MODAL: EXPENSE FORM --- */}
      {showExpenseForm && (
        <div 
          onClick={() => setShowExpenseForm(false)}
          className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex justify-center items-start overflow-y-auto p-4 z-50 animate-fade-in text-slate-800 text-xs font-semibold [direction:rtl]"
        >
          <div 
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl shadow-xl border border-slate-100 w-full max-w-md p-6 space-y-4 my-8 shadow-2xl"
          >
            <div className="flex justify-between items-center border-b border-slate-50 pb-3">
              <h3 className="font-extrabold text-sm text-slate-800">تسجيل مصروف مالي جديد</h3>
              <button type="button" onClick={() => setShowExpenseForm(false)} className="p-1 hover:bg-slate-100 rounded-lg cursor-pointer">
                <X className="w-5 h-5 text-slate-400 hover:text-slate-600" />
              </button>
            </div>

            <form onSubmit={handleCreateExpense} className="space-y-4">
              
              {/* Amount */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold text-right">مبلغ المصروف (د.ج) *</label>
                <input
                  type="number"
                  min="1"
                  required
                  placeholder="مثال: 5000"
                  value={newExpense.amount}
                  onChange={(e) => setNewExpense({ ...newExpense, amount: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-200 outline-indigo-500 font-extrabold focus:bg-white"
                />
              </div>

              {/* Date */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold text-right">تاريخ العملية *</label>
                <input
                  type="date"
                  required
                  value={newExpense.date}
                  onChange={(e) => setNewExpense({ ...newExpense, date: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-200 outline-indigo-500 font-bold focus:bg-white text-right font-mono"
                />
              </div>

              {/* Category */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold text-right">نوع المصروف *</label>
                <select
                  value={newExpense.category}
                  onChange={(e) => setNewExpense({ ...newExpense, category: e.target.value as any })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-200 outline-indigo-500 focus:bg-white font-bold"
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
                <label className="block text-slate-600 mb-1.5 font-extrabold text-right">بند أو وصف وتفاصيل المصروف *</label>
                <textarea
                  required
                  rows={2}
                  placeholder="بيان الفاتورة أو الخدمة المقتناة بالتفصيل..."
                  value={newExpense.notes}
                  onChange={(e) => setNewExpense({ ...newExpense, notes: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 border border-slate-200 rounded-lg focus:bg-white focus:outline-indigo-500 font-medium"
                ></textarea>
              </div>

              {/* Related Apartment (Optional) */}
              <div>
                <label className="block text-slate-600 mb-1.5 font-extrabold text-right">تخصيص المصروف لشقة العطلات (اختياري)</label>
                <select
                  value={newExpense.apartmentId}
                  onChange={(e) => setNewExpense({ ...newExpense, apartmentId: e.target.value })}
                  className="w-full text-right p-3 bg-slate-50 rounded-lg border border-slate-200 outline-indigo-500 focus:bg-white font-bold"
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
                  className="p-3 bg-slate-100 hover:bg-slate-200 text-slate-800 rounded-lg font-bold transition-all cursor-pointer text-center text-xs"
                >
                  إلغاء الأمر
                </button>
              </div>

            </form>
          </div>
        </div>
      )}

    </div>
  );
};
