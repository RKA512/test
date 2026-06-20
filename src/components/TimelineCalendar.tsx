import React, { useState } from 'react';
import { Calendar, User, Home, ArrowLeft, ArrowRight, Info, Plus } from 'lucide-react';
import { Apartment, Booking, Guest, BookingStatus } from '../types/rental';

interface TimelineCalendarProps {
  apartments: Apartment[];
  bookings: Booking[];
  guests: Guest[];
  onSelectBooking: (booking: Booking) => void;
  onNewBookingAt: (apartmentId: string, dateStr: string) => void;
  customColors: Record<string, string>;
  onUpdateColor: (key: string, value: string) => void;
}

export const TimelineCalendar: React.FC<TimelineCalendarProps> = ({
  apartments,
  bookings,
  guests,
  onSelectBooking,
  onNewBookingAt,
  customColors,
  onUpdateColor,
}) => {
  // Segmented Range Selection State for Timeline (14, 30, or 90 days)
  const [daysCount, setDaysCount] = useState<number>(14);

  // Generate days from a reference date
  const [startDateStr, setStartDateStr] = useState<string>(() => {
    const today = new Date();
    return today.toISOString().split('T')[0];
  });

  const getDaysArray = (startStr: string, count = 14) => {
    const days = [];
    const date = new Date(startStr);
    for (let i = 0; i < count; i++) {
      const current = new Date(date);
      current.setDate(date.getDate() + i);
      const str = current.toISOString().split('T')[0];
      days.push({
        dateStr: str,
        dayName: current.toLocaleDateString('ar-EG', { weekday: 'short' }),
        dayNum: current.getDate(),
        monthName: current.toLocaleDateString('ar-EG', { month: 'short' }),
        rawDate: current,
      });
    }
    return days;
  };

  const days = getDaysArray(startDateStr, daysCount);

  const shiftDates = (daysCount: number) => {
    const active = new Date(startDateStr);
    active.setDate(active.getDate() + daysCount);
    setStartDateStr(active.toISOString().split('T')[0]);
  };

  const [colorMode, setColorMode] = useState<'status' | 'payment'>('status');

  const getGuestName = (guestId: string) => {
    const guest = guests.find(g => g.id === guestId);
    return guest ? guest.fullName : 'زبون مجهول';
  };

  const getBookingStyle = (booking: Booking): React.CSSProperties => {
    let color = '#3b82f6'; // default confirmed
    if (colorMode === 'status') {
      color = customColors?.[booking.status] || '#3b82f6';
    } else {
      // Payment status based color coding
      if (booking.status === 'cancelled') {
        color = '#a1a1aa'; // neutral zinc color for cancelled
      } else if (booking.remainingAmount === 0) {
        color = customColors?.paid_full || '#059669'; // Fully paid
      } else if (booking.paidAmount > 0) {
        color = customColors?.paid_partial || '#f59e0b'; // Partially paid
      } else {
        color = customColors?.paid_none || '#ef4444'; // Unpaid
      }
    }
    
    return {
      backgroundColor: color,
      borderColor: color,
      color: '#ffffff',
    };
  };

  const getStatusNameAr = (status: BookingStatus) => {
    const names: Record<BookingStatus, string> = {
      confirmed: 'مؤكد',
      pending_arrival: 'قيد الوصول',
      checked_in: 'مقيم حالياً',
      completed: 'مكتمل',
      cancelled: 'ملغى',
    };
    return names[status];
  };

  return (
    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 sm:p-6 overflow-hidden space-y-6">
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-4 border-b border-slate-50 pb-4">
        <div>
          <h2 className="text-base sm:text-lg md:text-xl font-bold text-slate-800 flex items-center gap-2">
            <Calendar className="w-5 h-5 text-indigo-600 shrink-0" />
            تقويم الحجوزات التفاعلي ({daysCount} يوماً)
          </h2>
          <p className="text-[10px] sm:text-xs text-slate-500 mt-1">
            تتبع إشغال شقق العطلات وتداخل التواريخ. الخروج 10:00 صباحاً يمكّن من استقبال حجز جديد في نفس اليوم مباشرة!
          </p>
        </div>
        
        <div className="flex flex-wrap items-center gap-3 w-full lg:w-auto justify-between lg:justify-end">
          {/* Day Range Scope Selection */}
          <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-xl border border-slate-200 text-xs text-slate-700">
            <span className="text-slate-500 font-bold px-2 hidden sm:inline">نطاق السجل:</span>
            {[14, 30, 90].map((count) => (
              <button
                key={count}
                type="button"
                onClick={() => setDaysCount(count)}
                className={`p-1.5 px-3 rounded-lg font-bold transition-all cursor-pointer ${
                  daysCount === count ? 'bg-indigo-600 text-white shadow-xs' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {count} يوماً
              </button>
            ))}
          </div>

          {/* Color Mode Switcher Toggle */}
          <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-xl border border-slate-200 text-xs text-slate-700">
            <span className="text-slate-500 font-bold px-2 hidden sm:inline">ترميز الألوان:</span>
            <button
              type="button"
              onClick={() => setColorMode('status')}
              className={`p-1.5 px-3 rounded-lg font-bold transition-all cursor-pointer ${
                colorMode === 'status' ? 'bg-indigo-600 text-white shadow-xs' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              حالة الحجز
            </button>
            <button
              type="button"
              onClick={() => setColorMode('payment')}
              className={`p-1.5 px-3 rounded-lg font-bold transition-all cursor-pointer ${
                colorMode === 'payment' ? 'bg-indigo-600 text-white shadow-xs' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              حالة الدفع
            </button>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 p-1.5 rounded-xl border border-slate-100">
            <button 
              type="button"
              onClick={() => shiftDates(-7)}
              className="p-1 px-3 hover:bg-white rounded-lg text-xs font-semibold text-slate-600 hover:text-slate-900 border border-transparent hover:border-slate-200 transition-all cursor-pointer"
            >
              الأسبوع السابق
            </button>
            <button 
              type="button"
              onClick={() => shiftDates(-1)}
              className="p-1.5 hover:bg-white rounded-lg text-slate-600 transition-all cursor-pointer"
              title="اليوم السابق"
            >
              <ArrowRight className="w-4 h-4" />
            </button>
            <span className="text-xs font-bold text-slate-700 px-3 min-w-[120px] text-center font-mono">
              {days[0].rawDate.toLocaleDateString('ar-EG', { month: 'long', year: 'numeric' })}
            </span>
            <button 
              type="button"
              onClick={() => shiftDates(1)}
              className="p-1.5 hover:bg-white rounded-lg text-slate-600 transition-all cursor-pointer"
              title="اليوم التالي"
            >
              <ArrowLeft className="w-4 h-4" />
            </button>
            <button 
              type="button"
              onClick={() => shiftDates(7)}
              className="p-1 px-3 hover:bg-white rounded-lg text-xs font-semibold text-slate-600 hover:text-slate-900 border border-transparent hover:border-slate-200 transition-all cursor-pointer"
            >
              الأسبوع القادم
            </button>
          </div>
        </div>
      </div>

      {/* Grid Container */}
      <div className="overflow-x-auto border border-slate-100 rounded-xl">
        <div 
          className="grid" 
          style={{ 
            gridTemplateColumns: `180px repeat(${daysCount}, minmax(65px, 1fr))`,
            minWidth: `${180 + daysCount * 65}px`
          }}
        >
          
          {/* Header Row */}
          <div className="bg-slate-50/70 p-4 font-bold text-slate-800 border-b border-l border-slate-100 text-sm flex items-center">
            الشقق / الأيام
          </div>
          {days.map((day) => {
            const isToday = new Date().toISOString().split('T')[0] === day.dateStr;
            return (
              <div 
                key={day.dateStr} 
                className={`p-2 border-b border-l last:border-l-0 border-slate-100 flex flex-col items-center justify-center text-center transition-colors ${isToday ? 'bg-indigo-50/50' : 'bg-slate-50/30'}`}
              >
                <span className={`text-[10px] uppercase tracking-wider font-bold ${isToday ? 'text-indigo-600' : 'text-slate-400'}`}>
                  {day.dayName}
                </span>
                <span className={`text-sm font-extrabold mt-0.5 ${isToday ? 'text-indigo-700' : 'text-slate-700'}`}>
                  {day.dayNum}
                </span>
                <span className="text-[9px] text-slate-400 font-medium">
                  {day.monthName}
                </span>
                {isToday && (
                  <span className="text-[8px] px-1.5 font-bold rounded-full bg-indigo-100 text-indigo-700 mt-1">
                    اليوم
                  </span>
                )}
              </div>
            );
          })}

          {/* Apartments Rows & Bookings Content */}
          {apartments.map((apt) => {
            return (
              <React.Fragment key={apt.id}>
                {/* Apartment Info Header Cell */}
                <div className="p-3 border-b border-l border-slate-100 bg-slate-50/20 flex flex-col justify-center">
                  <div className="font-bold text-slate-800 text-sm truncate flex items-center gap-1.5">
                    <Home className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                    {apt.name}
                  </div>
                  <div className="flex gap-2 items-center text-[10.5px] text-slate-500 mt-1">
                    <span>{apt.roomsCount} غرف</span>
                    <span className="text-slate-300">•</span>
                    <span>{apt.bedsCount} أسرة</span>
                  </div>
                  <div className="text-xs font-bold text-emerald-600 mt-0.5">
                    {apt.nightlyPrice.toLocaleString('en-US')} د.ج / ليلة
                  </div>
                </div>

                {/* Days Grid Cells for this Apartment */}
                {days.map((day) => {
                  // Find if there is a booking that covers this apartment and date
                  const bookingForDay = bookings.find(b => {
                    if (b.apartmentId !== apt.id) return false;
                    return day.dateStr >= b.checkInDate && day.dateStr < b.checkOutDate;
                  });

                  if (bookingForDay) {
                    const isCheckInDay = bookingForDay.checkInDate === day.dateStr;
                    return (
                      <div 
                        key={`${apt.id}-${day.dateStr}`}
                        onClick={() => onSelectBooking(bookingForDay)}
                        className={`p-1.5 border-b border-l last:border-l-0 border-slate-100 select-none cursor-pointer transition-colors relative flex items-center justify-center min-h-[70px] ${
                          bookingForDay.status === 'cancelled' ? 'bg-rose-50/30' : 'bg-slate-50/10'
                        }`}
                      >
                        <div 
                          style={getBookingStyle(bookingForDay)}
                          className="w-full h-full py-2 px-1.5 rounded-lg text-center flex flex-col justify-center border text-[10px] font-bold transition-all transform hover:scale-105 shadow-xs"
                        >
                          <div className="truncate font-sans font-semibold tracking-wide text-[9px] opacity-90">
                            #{bookingForDay.bookingNumber}
                          </div>
                          {isCheckInDay ? (
                            <div className="truncate text-[10.5px] mt-0.5" title={getGuestName(bookingForDay.guestId)}>
                              {getGuestName(bookingForDay.guestId)}
                            </div>
                          ) : (
                            <div className="text-[8px] opacity-75 truncate text-slate-100 font-medium">متابع..</div>
                          )}
                          <div className="text-[8px] opacity-80 mt-0.5 font-bold">
                            {getStatusNameAr(bookingForDay.status)}
                          </div>
                        </div>
                      </div>
                    );
                  }

                  // Empty slot
                  return (
                    <div 
                      key={`${apt.id}-${day.dateStr}`}
                      onClick={() => onNewBookingAt(apt.id, day.dateStr)}
                      className="p-2 border-b border-l last:border-l-0 border-slate-100 transition-colors hover:bg-indigo-50/40 relative group cursor-pointer flex items-center justify-center min-h-[70px]"
                      title="سجل حجزاً جديداً في هذا اليوم"
                    >
                      <Plus className="w-3.5 h-3.5 text-slate-300 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </div>
                  );
                })}
              </React.Fragment>
            );
          })}
        </div>
      </div>

      {/* Bottom Color Legends with Interactive Custom Background Indicators */}
      <div className="flex flex-wrap justify-center md:justify-start gap-4 items-center bg-slate-50/50 p-4 rounded-xl border border-slate-100 text-xs text-slate-650">
        {colorMode === 'status' ? (
          <>
            <span className="font-black text-slate-800">دليل الألوان النشط للحالة:</span>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.confirmed || '#3b82f6' }}></span>
              <span>مؤكد</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.pending_arrival || '#f59e0b' }}></span>
              <span>قيد الوصول</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.checked_in || '#059669' }}></span>
              <span>مقيم حالياً (Check-In)</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.completed || '#6b7280' }}></span>
              <span>مكتمل</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.cancelled || '#ef4444' }}></span>
              <span>ملغى</span>
            </div>
          </>
        ) : (
          <>
            <span className="font-black text-slate-800">دليل الألوان لحالة الدفع:</span>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.paid_full || '#059669' }}></span>
              <span>مدفوع بالكامل</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.paid_partial || '#f59e0b' }}></span>
              <span>مدفوع جزئياً (عربون)</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full border border-slate-300" style={{ backgroundColor: customColors?.paid_none || '#ef4444' }}></span>
              <span>غير مدفوع (متبقي)</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-3 h-3 rounded-full bg-slate-400 border border-slate-300"></span>
              <span>حجز ملغى</span>
            </div>
          </>
        )}
      </div>

      {/* --- Visual Dynamic Free Color Customizer Widget --- */}
      <div className="bg-slate-50/50 rounded-2xl border border-slate-100 p-5 space-y-4">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3 border-b border-slate-200/50 pb-3">
          <div>
            <h4 className="font-extrabold text-[12.5px] text-slate-800 flex items-center gap-2">
              <span>🎨 لوحة تخصيص ألوان الواجهة والتقويم بشكل حر</span>
            </h4>
            <p className="text-[10px] text-slate-500 mt-0.5">انتقِ الألوان المفضلة لتتناسب بحرية تامّة مع هويتك البصرية وذوقك الخاص!</p>
          </div>
          <button
            type="button"
            onClick={() => {
              const defaults = {
                confirmed: '#3b82f6',
                pending_arrival: '#f59e0b',
                checked_in: '#059669',
                completed: '#6b7280',
                cancelled: '#ef4444',
                paid_full: '#059669',
                paid_partial: '#f59e0b',
                paid_none: '#ef4444'
              };
              Object.entries(defaults).forEach(([k, v]) => onUpdateColor(k, v));
            }}
            className="text-[10px] bg-slate-200 hover:bg-slate-300 hover:text-slate-900 text-slate-700 font-bold px-3 py-1.5 rounded-lg border border-slate-300/40 cursor-pointer transition-all"
          >
            إعادة تعيين الألوان الكلاسيكية
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-[11px] font-bold text-slate-600">
          {/* Section 1: Bookings Status Colors */}
          <div className="space-y-3">
            <span className="text-xs font-black text-indigo-950 block border-r-2 border-indigo-500 pr-2">ألوان حالات الحجوزات:</span>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs">
                <span>مؤجه / مؤكد:</span>
                <input 
                  type="color" 
                  value={customColors.confirmed || '#3b82f6'} 
                  onChange={(e) => onUpdateColor('confirmed', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs">
                <span>قيد الوصول:</span>
                <input 
                  type="color" 
                  value={customColors.pending_arrival || '#f59e0b'} 
                  onChange={(e) => onUpdateColor('pending_arrival', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs">
                <span>مقيم حالياً (وصول):</span>
                <input 
                  type="color" 
                  value={customColors.checked_in || '#059669'} 
                  onChange={(e) => onUpdateColor('checked_in', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs">
                <span>حجز مكتمل الخروج:</span>
                <input 
                  type="color" 
                  value={customColors.completed || '#6b7280'} 
                  onChange={(e) => onUpdateColor('completed', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs sm:col-span-2">
                <span>حجز ملغى:</span>
                <input 
                  type="color" 
                  value={customColors.cancelled || '#ef4444'} 
                  onChange={(e) => onUpdateColor('cancelled', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
            </div>
          </div>

          {/* Section 2: Payments Stage Colors */}
          <div className="space-y-3">
            <span className="text-xs font-black text-indigo-950 block border-r-2 border-indigo-500 pr-2">ألوان حالات المدفوعات:</span>
            <div className="grid grid-cols-1 gap-2">
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs">
                <span>مدفوع بالكامل:</span>
                <input 
                  type="color" 
                  value={customColors.paid_full || '#059669'} 
                  onChange={(e) => onUpdateColor('paid_full', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs">
                <span>مدفوع جزئياً (عربون مسبق):</span>
                <input 
                  type="color" 
                  value={customColors.paid_partial || '#f59e0b'} 
                  onChange={(e) => onUpdateColor('paid_partial', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
              <div className="flex items-center justify-between p-2.5 bg-white border border-slate-200/60 rounded-xl shadow-3xs">
                <span>غير مدفوع (الاستخلاص معلق):</span>
                <input 
                  type="color" 
                  value={customColors.paid_none || '#ef4444'} 
                  onChange={(e) => onUpdateColor('paid_none', e.target.value)}
                  className="w-7 h-7 rounded-md border border-slate-200 cursor-pointer p-0.5 shrink-0 bg-white"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
