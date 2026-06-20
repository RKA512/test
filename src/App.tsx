import { useState } from 'react';
import { 
  Building, Database, Code, Network, Play, CheckSquare, 
  Cpu, Layers, Smartphone, Laptop, CheckCircle2, ChevronRight, MessageSquare
} from 'lucide-react';
import { SQLiteSchemaComponent } from './components/SQLiteSchemaComponent';
import { ArchitectureTree } from './components/ArchitectureTree';
import { UMLDiagramComponent } from './components/UMLDiagramComponent';
import { DatabaseSimulator } from './components/DatabaseSimulator';

export default function App() {
  const [activeMainTab, setActiveMainTab] = useState<'blueprint' | 'simulator'>('blueprint');
  const [activeBlueprintSubTab, setActiveBlueprintSubTab] = useState<'analysis' | 'sqlite' | 'folder' | 'uml'>('analysis');
  const [simulatorMode, setSimulatorMode] = useState<'desktop' | 'mobile'>('desktop');
  
  // Approval Hub state
  const [feedbackText, setFeedbackText] = useState<string>('');
  const [checkedSteps, setCheckedSteps] = useState({
    analysis: true,
    dbSchema: true,
    folders: true,
    uml: true,
    dataFlow: true
  });
  const [isApproved, setIsApproved] = useState<boolean>(false);

  const handleApprove = () => {
    setIsApproved(true);
  };

  return (
    <div dir="rtl" className="min-h-screen bg-slate-50/50 text-slate-800 font-sans leading-relaxed flex flex-col justify-between text-right">
      
      {/* --- Top Sticky Hero Header --- */}
      <header className="bg-slate-900 text-white border-b border-slate-800 sticky top-0 z-40 shadow-md">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex flex-col sm:flex-row justify-between items-center gap-4">
          
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-indigo-600 rounded-xl flex items-center justify-center shadow-lg border border-indigo-400/20">
              <Building className="w-5 h-5 text-indigo-50" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-base font-extrabold tracking-tight">مستشار الحلول ومعمار الفلتر (Senior Flutter Architect)</h1>
                <span className="bg-indigo-500/20 text-indigo-300 pointer-events-none text-[9px] font-bold px-2 py-0.5 rounded-full border border-indigo-400/20 uppercase">
                  v1.0 Blueprint
                </span>
              </div>
            </div>
          </div>

          {/* Core Master Navigation */}
          <div className="flex bg-slate-800/80 p-1 rounded-xl border border-slate-700/50">
            <button
              type="button"
              onClick={() => setActiveMainTab('blueprint')}
              className={`px-4 py-2 text-xs font-bold rounded-lg transition-all cursor-pointer flex items-center gap-2 ${
                activeMainTab === 'blueprint'
                  ? 'bg-indigo-600 text-white shadow-md'
                  : 'text-slate-300 hover:text-white'
              }`}
            >
              <Cpu className="w-3.5 h-3.5" />
              المخطط المعماري الفني
            </button>
            <button
              type="button"
              onClick={() => setActiveMainTab('simulator')}
              className={`px-4 py-2 text-xs font-bold rounded-lg transition-all cursor-pointer flex items-center gap-2 ${
                activeMainTab === 'simulator'
                  ? 'bg-indigo-600 text-white shadow-md'
                  : 'text-slate-300 hover:text-white'
              }`}
            >
              <Play className="w-3.5 h-3.5" />
              محاكي الواجهات المكتبي / المحمول
            </button>
          </div>

        </div>
      </header>

      {/* --- Main Content Body --- */}
      <main className="flex-grow max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8">
        
        {/* Banner requesting approval according to custom instructions */}
        {!isApproved && (
          <div className="bg-gradient-to-l from-indigo-900 to-slate-900 text-white p-6 rounded-2xl shadow-md border border-indigo-850/30 mb-8 flex flex-col md:flex-row items-center justify-between gap-6 relative overflow-hidden">
            <div className="absolute top-0 right-0 w-64 h-64 bg-indigo-500/10 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none"></div>
            <div className="relative space-y-2">
              <span className="bg-amber-500/25 text-amber-300 border border-amber-500/30 text-[10px] font-extrabold px-2.5 py-1 rounded-full uppercase">
                بانتظار موافقتك الرسمية (Awaiting Architect Approval)
              </span>
              <h3 className="text-base font-extrabold">مرحلة التحليل وهندسة قاعدة البيانات SQLite</h3>
              <p className="text-xs text-slate-300 max-w-2xl leading-relaxed">
                عملاً بتوجيهاتك الكريمة <span className="font-semibold text-white">"بعد الانتهاء من هذه المرحلة انتظر موافقتي قبل كتابة الكود"</span>، قمنا بإنشاء المخطط المتكامل وجاهزون لتوليد شيفرات المستودع بالكامل فوراً. يرجى مراجعة التفاصيل أدناه وإقرارها.
              </p>
            </div>
            <a 
              href="#approval-station"
              className="px-5 py-3 bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-black rounded-xl transition-all shadow-md hover:shadow-lg flex items-center gap-1.5 shrink-0"
            >
              توجه لمحطة الموافقة والاعتماد 
              <ChevronRight className="w-4 h-4 turn-180" />
            </a>
          </div>
        )}

        {activeMainTab === 'blueprint' ? (
          <div className="space-y-6">
            
            {/* Blueprint Sub Navigation */}
            <div className="flex bg-white p-1 rounded-2xl border border-slate-100 shadow-sm overflow-x-auto">
              {[
                { id: 'analysis', label: '1. تحليل متطلبات المشروع', icon: Layers },
                { id: 'sqlite', label: '2. مخطط SQLite والقيود', icon: Database },
                { id: 'folder', label: '3. هيكلة مجلدات Clean Architecture', icon: Code },
                { id: 'uml', label: '4. تسلسل تدفق البيانات & UML', icon: Network },
              ].map((tab) => {
                const Icon = tab.icon;
                return (
                  <button
                    key={tab.id}
                    type="button"
                    onClick={() => setActiveBlueprintSubTab(tab.id as any)}
                    className={`flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold transition-all cursor-pointer whitespace-nowrap shrink-0 ${
                      activeBlueprintSubTab === tab.id
                        ? 'bg-slate-900 text-white'
                        : 'text-slate-600 hover:bg-slate-50'
                    }`}
                  >
                    <Icon className="w-4 h-4 shrink-0" />
                    <span>{tab.label}</span>
                  </button>
                );
              })}
            </div>

            {/* --- Blueprint Sub-Tab Content --- */}
            <div className="transition-all duration-200">
              
              {/* Tab 1: Analysis */}
              {activeBlueprintSubTab === 'analysis' && (
                <div className="space-y-6">
                  {/* Executive Summary Grid */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
                      <h3 className="font-extrabold text-slate-800 text-base border-b border-slate-50 pb-3 flex items-center gap-2">
                        <span className="w-1.5 h-6 bg-indigo-600 rounded-sm"></span>
                        موجز خصائص ومتطلبات المنظومة
                      </h3>
                      
                      <div className="space-y-3.5 text-xs text-slate-600 font-medium leading-relaxed">
                        <div className="flex items-start gap-2.5">
                          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                          <p>
                            <span className="font-bold text-slate-900">طبيعة التطبيق:</span> مخصص حصرياً لموظف الاستقبال وصاحب الفندق/الشقق لإدارة الحركات اليومية للحجوزات، الدومين محكم ومحيد أمنياً بالكامل دون الربط مع خوادم خارجية وبغير واجهة عملاء.
                          </p>
                        </div>
                        <div className="flex items-start gap-2.5">
                          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                          <p>
                            <span className="font-bold text-slate-900">الأجهزة المستهدفة:</span> دعم كامل لأجهزة Android (صيغة تفاعلية لمسية للهواتف والتابلت) وأنظمة Windows 11 (واجهات سطح مكتب مرنة ومستقلة).
                          </p>
                        </div>
                        <div className="flex items-start gap-2.5">
                          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                          <p>
                            <span className="font-bold text-slate-900">الاستقلالية التامة (Offline):</span> يتم حفظ الجداول والحسابات المالية في الحوزة التخزينية للهاتف أو الكمبيوتر داخل محرك SQLite المستقل بالكامل ويدعم الاستيراد والنسخ دون انترنت.
                          </p>
                        </div>
                        <div className="flex items-start gap-2.5">
                          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                          <p>
                            <span className="font-bold text-slate-900">عدد الشقق:</span> يدعم تشغيل غير محدود للشقق مستقبلاً (النظام مهيأ للتدرج والتوسع اللامحدود بديناميكية تامة).
                          </p>
                        </div>
                      </div>
                    </div>

                    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
                      <h3 className="font-extrabold text-slate-800 text-base border-b border-slate-50 pb-3 flex items-center gap-2">
                        <span className="w-1.5 h-6 bg-indigo-600 rounded-sm"></span>
                        تكنولوجيا المشروع المقترحة
                      </h3>
                      
                      <div className="grid grid-cols-2 gap-4">
                        <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-100/85">
                          <div className="text-xs font-black text-slate-800">إطار العمل الرئيسي</div>
                          <div className="text-sm font-extrabold text-indigo-700 mt-1">Flutter 3.x / Dart</div>
                          <p className="text-[10px] text-slate-500 mt-1">لضمان تجميع واجهات تفاعلية سريعة أصلية (Native) لكل من نظام Android وويندوز 11 بسلاسة.</p>
                        </div>

                        <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-100/85">
                          <div className="text-xs font-black text-slate-800">قاعدة البيانات المحلية</div>
                          <div className="text-sm font-extrabold text-indigo-700 mt-1">SQLite & sqflite</div>
                          <p className="text-[10px] text-slate-500 mt-1">المحرك الأمثل لتخزين البيانات محلياً مع سرعة فائقة ودعم كامل لحركات المقاصة المالية المعقدة.</p>
                        </div>

                        <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-100/85">
                          <div className="text-xs font-black text-slate-800">إدارة وضعية التطبيق</div>
                          <div className="text-sm font-extrabold text-indigo-700 mt-1">Riverpod</div>
                          <p className="text-[10px] text-slate-500 mt-1">لتوفير كود نظيف وتجنيب إعادة البناء غير الضروري للواجهات مع سهولة معالجة الحالات.</p>
                        </div>

                        <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-100/85">
                          <div className="text-xs font-black text-slate-800">جودة وهندسة الملفات</div>
                          <div className="text-sm font-extrabold text-indigo-700 mt-1">Clean Architecture</div>
                          <p className="text-[10px] text-slate-500 mt-1">تقسيم محكم وصارم في عزل تفاصيل الواجهة، الحسابات الرياضية، وطبقات توفير البيانات.</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Windows 11 & Android Aesthetic Features */}
                  <div className="bg-slate-900 text-white rounded-2xl p-6 border border-slate-800 relative overflow-hidden">
                    <div className="absolute bottom-0 right-0 w-96 h-96 bg-indigo-600/10 rounded-full blur-3xl -mr-20 -mb-20 pointer-events-none"></div>
                    <div className="relative space-y-4">
                      <h3 className="text-lg font-extrabold text-left md:text-right">انسجام الواجهات مع بيئة التشغيل المتنوعة</h3>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-xs text-slate-300 leading-relaxed font-semibold">
                        <div className="space-y-2 bg-slate-800/40 p-4 rounded-xl border border-slate-700/30">
                          <div className="flex items-center gap-2 text-white font-extrabold">
                            <Laptop className="w-5 h-5 text-indigo-400" />
                            ميزات وإضافات على Windows 11
                          </div>
                          <ul className="list-disc pr-4 space-y-1.5 text-slate-350">
                            <li>مظهر متجاوب بوضع ملء الشاشة أو النوافذ المتعددة.</li>
                            <li>دعم الطباعة المباشرة للوصولات والتقارير عبر الطابعات المكتبية المتصلة محلياً بسلك USB.</li>
                            <li>تمكين اختصارات لوحة المفاتيح وسرعة الانتقال بين المدخلات.</li>
                          </ul>
                        </div>

                        <div className="space-y-2 bg-slate-800/40 p-4 rounded-xl border border-slate-700/30">
                          <div className="flex items-center gap-2 text-white font-extrabold">
                            <Smartphone className="w-5 h-5 text-indigo-400" />
                            ميزات وإصدارات Android
                          </div>
                          <ul className="list-disc pr-4 space-y-1.5 text-slate-350">
                            <li>مرونة وسرعة تامة عند اللمس والتمرير الأفقي والرأسي لجداول المواعيد.</li>
                            <li>إمكانية تصدير التقارير واستدعاء الحجوزات ومشاركتها عبر التطبيقات المحلية كـ WhatsApp مباشرة.</li>
                            <li>استقرار تام في استهلاك بطارية الهاتف الخلوي والتشغيل عند الخلفية.</li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Tab 2: SQLite Schema */}
              {activeBlueprintSubTab === 'sqlite' && (
                <SQLiteSchemaComponent />
              )}

              {/* Tab 3: Folder Structure */}
              {activeBlueprintSubTab === 'folder' && (
                <ArchitectureTree />
              )}

              {/* Tab 4: UML and Dataflow */}
              {activeBlueprintSubTab === 'uml' && (
                <UMLDiagramComponent />
              )}

            </div>

          </div>
        ) : (
          <div className="space-y-6">
            
            {/* Simulator Mode Config Switcher */}
            <div className="bg-white rounded-2xl border border-slate-100 p-5 flex flex-col sm:flex-row justify-between items-center gap-4 shadow-sm">
              <div>
                <h3 className="font-extrabold text-sm text-slate-800">مرحلة التجربة الحية وعرض تدفق البيانات</h3>
                <p className="text-xs text-slate-500 mt-1">قم بتجربة محاطات تجميع وإسقاط الحجوزات والتأكد من فحص كفاءة كود منع التعارض والازدواجية للأيام والأسرة محلياً</p>
              </div>

              <div className="flex items-center gap-3">
                <span className="text-xs text-slate-600 font-bold">بنية الهيكل المرئي:</span>
                <div className="flex bg-slate-100 p-1 rounded-lg">
                  <button
                    type="button"
                    onClick={() => setSimulatorMode('desktop')}
                    className={`flex items-center gap-1.5 p-1.5 px-3 text-xs font-bold rounded-md cursor-pointer transition-all ${
                      simulatorMode === 'desktop' ? 'bg-white text-indigo-950 shadow-2xs' : 'text-slate-500'
                    }`}
                  >
                    <Laptop className="w-4 h-4 text-indigo-600" />
                    بيئة سطح مكتب Windows 11
                  </button>
                  <button
                    type="button"
                    onClick={() => setSimulatorMode('mobile')}
                    className={`flex items-center gap-1.5 p-1.5 px-3 text-xs font-bold rounded-md cursor-pointer transition-all ${
                      simulatorMode === 'mobile' ? 'bg-white text-indigo-950 shadow-2xs' : 'text-slate-500'
                    }`}
                  >
                    <Smartphone className="w-4 h-4 text-indigo-600" />
                    تنسيق الجوال Android
                  </button>
                </div>
              </div>
            </div>

            {/* Layout representation of device frame */}
            {simulatorMode === 'desktop' ? (
              // Laptop/Desktop layout container representation: Windows 11 Slate window mockup
              <div className="bg-slate-300 border-8 border-slate-400 rounded-3xl overflow-hidden shadow-2xl relative">
                {/* Titlebar mockup */}
                <div className="bg-slate-200 p-3 flex justify-between items-center text-xs font-bold text-slate-700 select-none border-b border-slate-300">
                  <div className="flex items-center gap-2">
                    <div className="w-3.5 h-3.5 bg-indigo-600 rounded-sm"></div>
                    <span className="font-sans">منظومة الحجوزات اليومية - Windows Client (Offline Run)</span>
                  </div>
                  {/* Min, Max, Close Window actions mock */}
                  <div className="flex gap-2.5 items-center">
                    <span className="w-3 h-0.5 bg-slate-450 rounded-sm"></span>
                    <span className="w-3.5 h-3.5 border-2 border-slate-450 rounded-xs"></span>
                    <span className="text-sm font-medium text-slate-500 opacity-80">✕</span>
                  </div>
                </div>

                <div className="p-6 bg-slate-50">
                  <DatabaseSimulator />
                </div>
              </div>
            ) : (
              // Mobile frame mockup
              <div className="max-w-md mx-auto bg-slate-900 border-[12px] border-slate-800 rounded-[44px] overflow-hidden shadow-2xl relative">
                {/* Mobile Camera notch and status line */}
                <div className="bg-slate-800 h-6 flex justify-between items-center px-6 text-[10px] text-slate-300 font-sans pointer-events-none sticky top-0 z-10 w-full">
                  <span>10:30</span>
                  <div className="w-20 h-4 bg-slate-900 rounded-b-xl absolute top-0 left-1/2 -translate-x-1/2"></div>
                  <span>100% 🔋</span>
                </div>

                <div className="p-4 bg-slate-100 max-h-[750px] overflow-y-auto">
                  <DatabaseSimulator />
                </div>
              </div>
            )}

          </div>
        )}

        {/* --- Unified Section: Approval Station according to request --- */}
        <section id="approval-station" className="mt-12 bg-white rounded-3xl border border-slate-200/80 shadow-md p-6 sm:p-8 space-y-6">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-slate-100 pb-5">
            <div>
              <h2 className="text-xl font-black text-slate-800 flex items-center gap-2">
                <CheckSquare className="w-6 h-6 text-indigo-600" />
                محطة المراجعة والاعتماد المعماري للمشروع
              </h2>
              <p className="text-xs text-slate-500 mt-1">قم بتدقيق البنود والموافقة للتقدم لكتابة الأكواد المصدرية لمشروع الفلتر</p>
            </div>
            
            <div className="flex bg-slate-100 text-slate-700 text-xs font-bold px-3 py-1.5 rounded-full border border-slate-200 gap-2 items-center">
              <span>الحالة الحالية:</span>
              <span className={`font-black ${isApproved ? 'text-emerald-600' : 'text-amber-600 animate-pulse'}`}>
                {isApproved ? '✓ تم إعطاء الموافقة رسميًا' : '⏳ قيد المراجعة والتحميص'}
              </span>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-xs text-slate-650">
            {/* Checklist of steps */}
            <div className="space-y-3 bg-slate-50/50 p-5 rounded-2xl border border-slate-100">
              <h4 className="font-extrabold text-slate-800 text-sm mb-2">قائمة التدقيق والمطابقة المعمارية:</h4>
              
              {[
                { key: 'analysis', label: 'التحليل البرمجي وخطة العمل المكتملة' },
                { key: 'dbSchema', label: 'مخطط SQLite DDL مع العلاقات والقيود التلقائية' },
                { key: 'folders', label: 'هيكل وترتيب المجلدات طبقاً لـ Clean Architecture' },
                { key: 'uml', label: 'مخطط UML للطبقات ووظائف البلوكات/Riverpod' },
                { key: 'dataFlow', label: 'تدفق البيانات الحسابية وآلية منع التضارب المزدوج للشقق' },
              ].map((item) => (
                <label key={item.key} className="flex items-center gap-3 font-semibold text-slate-700 cursor-pointer select-none">
                  <input
                    type="checkbox"
                    checked={(checkedSteps as any)[item.key]}
                    onChange={(e) => setCheckedSteps({ ...checkedSteps, [item.key]: e.target.checked })}
                    className="w-4 h-4 rounded-sm border-slate-350 text-indigo-600 focus:ring-indigo-500"
                  />
                  <span>{item.label}</span>
                </label>
              ))}
            </div>

            {/* Feedback box */}
            <div className="space-y-3 flex flex-col justify-between">
              <div className="space-y-2">
                <h4 className="font-extrabold text-slate-800 text-sm flex items-center gap-1.5">
                  <MessageSquare className="w-4 h-4 text-slate-400" />
                  أضف تعليقاتك أو تعديلاتك المطلوبة (إن وجدت):
                </h4>
                <textarea
                  placeholder="مثال: يرجى إقرار الاعتماد بالكامل، أو إضافة حقول إضافية كحقل الغسيل لاحقاً لربطه..."
                  rows={4}
                  value={feedbackText}
                  onChange={(e) => setFeedbackText(e.target.value)}
                  className="w-full text-right p-3 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-indigo-500 text-xs font-semibold"
                ></textarea>
              </div>

              {!isApproved ? (
                <button
                  type="button"
                  onClick={handleApprove}
                  className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold p-3.5 rounded-xl text-xs shadow-md hover:shadow-lg transition-all cursor-pointer text-center"
                >
                  إعطاء الموافقة المعمارية للبدء في كتابة كود Flutter بالكامل
                </button>
              ) : (
                <div className="p-4 bg-emerald-50 rounded-xl border border-emerald-100 text-center space-y-2">
                  <div className="text-emerald-800 font-extrabold flex items-center justify-center gap-1.5">
                    <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
                    رائع! تم تدوين الموافقة المعمارية للتقدم للأمام
                  </div>
                  <p className="text-[11px] text-emerald-700 leading-relaxed font-bold">
                    تم تخزين خياراتك وحررت المنظومة البرمجية. كمهندس برمجيات محترف وخبير Flutter، سأقوم بإنشاء فصول الكود البرمجي للمشروع فور إرسال رسالتك القادمة كتأكيد نهائي للاعتبار!
                  </p>
                </div>
              )}
            </div>
          </div>
        </section>

      </main>

      {/* --- Footer Accent --- */}
      <footer className="bg-slate-900 text-slate-400 text-xs text-center p-6 border-t border-slate-800 mt-12">
        <p className="font-medium">منظومة الحجوزات اليومية المتكاملة - تم صياغتها بجودة ومعايير هندسة البرمجيات المحترفة.</p>
        <p className="text-[10px] text-slate-500 mt-1.5">جميع الحقوق محفوظة © 2026</p>
      </footer>

    </div>
  );
}
