import React, { useState } from 'react';
import { Network, ArrowLeft, Database, Layers, Monitor, HardDrive, RefreshCw } from 'lucide-react';

export const UMLDiagramComponent: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'uml' | 'dataflow'>('dataflow');

  return (
    <div className="space-y-6">
      {/* Title */}
      <div className="flex justify-between items-center bg-white rounded-2xl border border-slate-100 shadow-xs p-5">
        <div>
          <h2 className="text-lg font-extrabold text-slate-800 flex items-center gap-2">
            <Network className="w-5 h-5 text-indigo-600" />
            تخطيط معمارية UML ومسار تدفق البيانات التفاعلي
          </h2>
          <p className="text-xs text-slate-500 mt-1">توضيح مرئي دقيق لكيفية انتقال البيانات بين الطبقات وضمان الفصل الكامل للمهام</p>
        </div>

        <div className="flex bg-slate-100 p-1 rounded-xl">
          <button
            type="button"
            onClick={() => setActiveTab('dataflow')}
            className={`px-4 py-2 text-xs font-bold rounded-lg cursor-pointer transition-all ${
              activeTab === 'dataflow'
                ? 'bg-white text-indigo-950 shadow-xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            تدفق البيانات (Sequence Flow)
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('uml')}
            className={`px-4 py-2 text-xs font-bold rounded-lg cursor-pointer transition-all ${
              activeTab === 'uml'
                ? 'bg-white text-indigo-950 shadow-xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            مخطط الطبقات (UML Layers)
          </button>
        </div>
      </div>

      {activeTab === 'dataflow' ? (
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-6">
          <div className="text-center max-w-xl mx-auto">
            <span className="bg-emerald-50 text-emerald-800 border border-emerald-100 text-[10px] font-extrabold px-3 py-1 rounded-full uppercase tracking-wider">
              استقصاء منع التعارض البيني
            </span>
            <h3 className="text-base font-bold text-slate-800 mt-2">تسلسل حماية الحجز من التداخل المزدوج</h3>
            <p className="text-xs text-slate-500 mt-1">دورة تبادل البيانات والحاسبة بين الواجهة وسجل SQLite المحلي بالكامل</p>
          </div>

          {/* Flow Steps Vertical/Horizontal Grid */}
          <div className="relative border-r-2 border-dashed border-indigo-100 mr-4 pr-6 space-y-8 py-2 md:space-y-0 md:border-r-0 md:mr-0 md:pr-0 md:grid md:grid-cols-4 md:gap-4 md:text-center text-right">
            
            {/* Step 1 */}
            <div className="relative">
              <div className="hidden md:block absolute top-6 right-0 left-0 h-0.5 border-t-2 border-dashed border-indigo-100 -z-10 w-[80%] mx-auto"></div>
              <div className="absolute right-[-31px] md:relative md:right-auto top-1 md:top-auto flex items-center justify-center w-7 h-7 bg-indigo-600 text-white font-black text-xs rounded-full border-4 border-indigo-100 mx-auto">
                1
              </div>
              <div className="bg-slate-50 border border-slate-100 p-4 rounded-xl mt-3 md:mt-4 shadow-2xs hover:border-indigo-200 transition-colors">
                <div className="font-extrabold text-xs text-slate-800 flex items-center gap-1.5 md:justify-center">
                  <Monitor className="w-3.5 h-3.5 text-indigo-600" />
                  واجهة المستخدم (UI View)
                </div>
                <p className="text-[11px] text-slate-500 mt-2 leading-relaxed">
                  يقوم الموظف بإدخال تواريخ الحجز المنسق والضغط على زِر تأكيد الحجز.
                </p>
                <div className="text-[10px] font-semibold text-slate-400 mt-1">
                  (BookingFormWidget)
                </div>
              </div>
            </div>

            {/* Step 2 */}
            <div className="relative">
              <div className="hidden md:block absolute top-6 right-0 left-0 h-0.5 border-t-2 border-dashed border-indigo-100 -z-10 w-[80%] mx-auto"></div>
              <div className="absolute right-[-31px] md:relative md:right-auto top-1 md:top-auto flex items-center justify-center w-7 h-7 bg-indigo-600 text-white font-black text-xs rounded-full border-4 border-indigo-100 mx-auto">
                2
              </div>
              <div className="bg-slate-50 border border-slate-100 p-4 rounded-xl mt-3 md:mt-4 shadow-2xs hover:border-indigo-200 transition-colors">
                <div className="font-extrabold text-xs text-slate-800 flex items-center gap-1.5 md:justify-center">
                  <Layers className="w-3.5 h-3.5 text-indigo-600" />
                  إدارة الحالة (Riverpod / BLoC)
                </div>
                <p className="text-[11px] text-slate-500 mt-2 leading-relaxed">
                  تلتقط وحدة التحكم الطلب وتسلم التواريخ لحالة الاستخدام بشكل مباشر.
                </p>
                <div className="text-[10px] font-semibold text-indigo-600 mt-1">
                  Notifier / Bloc Dispatcher
                </div>
              </div>
            </div>

            {/* Step 3 */}
            <div className="relative">
              <div className="hidden md:block absolute top-6 right-0 left-0 h-0.5 border-t-2 border-dashed border-indigo-100 -z-10 w-[80%] mx-auto"></div>
              <div className="absolute right-[-31px] md:relative md:right-auto top-1 md:top-auto flex items-center justify-center w-7 h-7 bg-indigo-600 text-white font-black text-xs rounded-full border-4 border-indigo-100 mx-auto">
                3
              </div>
              <div className="bg-slate-50 border border-slate-100 p-4 rounded-xl mt-3 md:mt-4 shadow-2xs hover:border-indigo-200 transition-colors">
                <div className="font-extrabold text-xs text-slate-800 flex items-center gap-1.5 md:justify-center">
                  <RefreshCw className="w-3.5 h-3.5 text-amber-500" />
                  حالة الاستخدام والتأمين (Use Case)
                </div>
                <p className="text-[11px] text-slate-500 mt-2 leading-relaxed">
                  تتحقق من شرط التضارب المزدوج عبر المستودع قبل التصريح بالحفظ الفعلي للمعلومات.
                </p>
                <div className="text-[10px] font-semibold text-amber-600 mt-1">
                  CreateBookingUseCase
                </div>
              </div>
            </div>

            {/* Step 4 */}
            <div className="relative">
              <div className="absolute right-[-31px] md:relative md:right-auto top-1 md:top-auto flex items-center justify-center w-7 h-7 bg-indigo-600 text-white font-black text-xs rounded-full border-4 border-indigo-100 mx-auto">
                4
              </div>
              <div className="bg-slate-50 border border-slate-100 p-4 rounded-xl mt-3 md:mt-4 shadow-2xs hover:border-indigo-200 transition-colors">
                <div className="font-extrabold text-xs text-slate-800 flex items-center gap-1.5 md:justify-center">
                  <Database className="w-3.5 h-3.5 text-emerald-600" />
                  قاعدة البيانات SQLite
                </div>
                <p className="text-[11px] text-slate-500 mt-2 leading-relaxed">
                  تنفذ الاستعلام وتطابق تداخل المواعيد. تعيد خطأ أو تسمح بإكمال المعاملة بنجاح.
                </p>
                <div className="text-[10px] font-semibold text-emerald-600 mt-1">
                  DatabaseHelper + SQL Query
                </div>
              </div>
            </div>

          </div>

          <div className="bg-amber-50/50 border border-amber-100 rounded-xl p-4 text-xs text-amber-900 leading-relaxed max-w-2xl mx-auto text-center font-medium">
            تضمن آلية تدفق البيانات هذه حماية مطلقة بنسبة 100% للشقق من الحجوزات المزدوجة المتزامنة دون الاعتماد على خوادم بعيدة، حيث يتم الحساب والتقييد داخل وحدة تخزين الهاتف أو جهاز الكمبيوتر المستهدف محلياً فورياً.
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-6">
          <div className="text-center max-w-xl mx-auto">
            <span className="bg-indigo-50 text-indigo-800 border border-indigo-100 text-[10px] font-extrabold px-3 py-1 rounded-full uppercase tracking-wider">
              مخطط الطبقات الثلاثية (3-Layers Diagram)
            </span>
            <h3 className="text-base font-bold text-slate-800 mt-2">ترتيب ومجالات هندسة معمارية Clean Architecture</h3>
            <p className="text-xs text-slate-500 mt-1">فهرسة المسؤوليات والترابط أحادي الاتجاه حفاظاً على الاستقلالية التامة</p>
          </div>

          <div className="space-y-4 max-w-2xl mx-auto">
            {/* Visual Layers Stack */}
            <div className="bg-indigo-50/50 border border-indigo-100 rounded-xl p-4 flex flex-col md:flex-row items-center gap-4 justify-between">
              <div className="md:w-1/3 text-right">
                <span className="text-[10px] uppercase font-bold text-indigo-700 bg-indigo-100 px-2.5 py-1 rounded-md">
                  الطبقة الأولى: Presentation Layer
                </span>
                <h4 className="font-extrabold text-xs text-slate-800 mt-2">طبقة العرض والواجهات</h4>
                <p className="text-[11px] text-slate-500 mt-1 leading-relaxed">
                  تحتوي على شاشات العرض للتطبيق والمحاور المسؤولة عن تجميع وعرض حالة البيانات الحالية ومتابعة ضغطات الموظف.
                </p>
              </div>
              <div className="p-3 bg-white border border-indigo-200 rounded-lg text-xs font-mono font-medium text-indigo-950 w-full md:w-1/2 text-left shrink-0">
                Screens (Dashboard, Calendar, Bookings, Login) + State Managers Providers (Riverpod / BLoC)
              </div>
            </div>

            <div className="bg-amber-50/40 border border-amber-150 rounded-xl p-4 flex flex-col md:flex-row items-center gap-4 justify-between">
              <div className="md:w-1/3 text-right">
                <span className="text-[10px] uppercase font-bold text-amber-700 bg-amber-100 px-2.5 py-1 rounded-md">
                  الطبقة الثانية: Domain Layer (النواة)
                </span>
                <h4 className="font-extrabold text-xs text-slate-800 mt-2">النواة وعقود العمل الخالصة</h4>
                <p className="text-[11px] text-slate-500 mt-1 leading-relaxed">
                  لا تعتمد على أي مكتبات خارجية! تحتوي على الكيانات النقية، وحالات الاستخدام، وتعريفات المستودعات النظرية (Interfaces).
                </p>
              </div>
              <div className="p-3 bg-white border border-amber-200 rounded-lg text-xs font-mono font-medium text-amber-950 w-full md:w-1/2 text-left shrink-0">
                Entities (Booking, Apartment, Guest) + UseCases (CreateBooking, GetReports) + Contract Repositories
              </div>
            </div>

            <div className="bg-emerald-50/40 border border-emerald-150 rounded-xl p-4 flex flex-col md:flex-row items-center gap-4 justify-between">
              <div className="md:w-1/3 text-right">
                <span className="text-[10px] uppercase font-bold text-emerald-700 bg-emerald-100 px-2.5 py-1 rounded-md">
                  الطبقة الثالثة: Data Layer
                </span>
                <h4 className="font-extrabold text-xs text-slate-800 mt-2">البيانات ومحركات الوصول</h4>
                <p className="text-[11px] text-slate-500 mt-1 leading-relaxed">
                  الطبقة المسؤولة عن جلب البيانات وتحميلها من SQLite أو التخزين الخارجي. تطبق العقود المعرفة بالنواة.
                </p>
              </div>
              <div className="p-3 bg-white border border-emerald-200 rounded-lg text-xs font-mono font-medium text-emerald-950 w-full md:w-1/2 text-left shrink-0">
                Repositories Implementations + Models (fromMap, toMap) + DataSources (SQLite Database Helper)
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
