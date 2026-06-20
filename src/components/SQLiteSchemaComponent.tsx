import React, { useState } from 'react';
import { Database, Table, Key, Server, Hash, FileCode, CheckCircle, Copy } from 'lucide-react';
import { sqliteTables, sqliteIndexes, doubleBookingValidationQuery } from '../data/dbSchema';

export const SQLiteSchemaComponent: React.FC = () => {
  const [activeTableIdx, setActiveTableIdx] = useState<number>(0);
  const [copied, setCopied] = useState<boolean>(false);

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-6">
      {/* Overview Card */}
      <div className="bg-slate-900 text-white rounded-2xl p-6 shadow-md border border-slate-800 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-80 h-80 bg-indigo-500/10 rounded-full blur-3xl -mr-20 -mt-20 pointer-events-none"></div>
        <div className="relative flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <span className="bg-indigo-500/20 text-indigo-300 text-xs font-bold px-3 py-1.5 rounded-full border border-indigo-500/30">
              SQLite محلي بالكامل
            </span>
            <h2 className="text-2xl font-bold mt-3 text-slate-100 flex items-center gap-2">
              <Database className="w-6 h-6 text-indigo-400" />
              مخطط قاعدة البيانات والتحقق المحكم لبيانات SQLite
            </h2>
            <p className="text-sm text-slate-300 mt-1 max-w-xl">
              تم تصميم الشفرة البرمجية بالاعتماد على قاعدة ببيانات علاقة محلية خفيفة الوزن SQLite مع تشغيل قيود المفاتيح الأجنبية لمنع فقدان التزامن المالي والزمني.
            </p>
          </div>
          <div className="flex gap-4">
            <div className="bg-slate-800/80 p-3.5 rounded-xl border border-slate-700/50 text-center min-w-[100px]">
              <div className="text-lg font-bold text-indigo-400">{sqliteTables.length}</div>
              <div className="text-[10px] text-slate-400">جداول أساسية</div>
            </div>
            <div className="bg-slate-800/80 p-3.5 rounded-xl border border-slate-700/50 text-center min-w-[100px]">
              <div className="text-lg font-bold text-emerald-400">{sqliteIndexes.length}</div>
              <div className="text-[10px] text-slate-400">فهارس للأداء</div>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left column: Tables List */}
        <div className="lg:col-span-4 space-y-3">
          <div className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">قائمة الجداول</div>
          {sqliteTables.map((table, idx) => (
            <button
              key={table.name}
              type="button"
              onClick={() => setActiveTableIdx(idx)}
              className={`w-full text-right p-4 rounded-xl border transition-all duration-200 cursor-pointer flex items-start gap-3 ${
                activeTableIdx === idx
                  ? 'bg-indigo-50/70 border-indigo-200 text-indigo-950 shadow-xs'
                  : 'bg-white border-slate-100 hover:bg-slate-50 text-slate-700'
              }`}
            >
              <Table className={`w-5 h-5 mt-0.5 shrink-0 ${activeTableIdx === idx ? 'text-indigo-600' : 'text-slate-400'}`} />
              <div>
                <div className="font-extrabold font-mono text-sm">{table.name}</div>
                <div className={`text-xs mt-1 leading-relaxed ${activeTableIdx === idx ? 'text-indigo-800/80' : 'text-slate-500'}`}>
                  {table.description}
                </div>
              </div>
            </button>
          ))}
        </div>

        {/* Right column: DDL Viewer */}
        <div className="lg:col-span-8 flex flex-col">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-sm flex-1 flex flex-col">
            <div className="bg-slate-900/90 border-b border-slate-800 p-4 flex justify-between items-center">
              <div className="flex items-center gap-2">
                <FileCode className="w-4 h-4 text-slate-400" />
                <span className="text-xs font-extrabold font-mono text-slate-300">
                  SQL DDL (CREATE TABLE {sqliteTables[activeTableIdx].name})
                </span>
              </div>
              <button
                type="button"
                onClick={() => copyToClipboard(sqliteTables[activeTableIdx].ddl)}
                className="p-1 px-3 text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white rounded-lg transition-all flex items-center gap-1 cursor-pointer font-semibold"
              >
                {copied ? <CheckCircle className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                {copied ? 'تم النسخ!' : 'نسخ الاستعلام'}
              </button>
            </div>

            {/* Code Highlight Simulator */}
            <div className="p-5 font-mono text-xs text-indigo-300 overflow-x-auto bg-slate-950 leading-relaxed text-right dir-ltr select-all">
              <pre>{sqliteTables[activeTableIdx].ddl}</pre>
            </div>

            {/* Architecture Explainer within Database Context */}
            <div className="bg-slate-900 p-4 border-t border-slate-800">
              <h4 className="text-xs font-bold text-slate-400 mb-2">مميزات هذا الجدول في بنية SQLite:</h4>
              <ul className="text-xs text-slate-300 space-y-1.5 list-disc right-4 relative">
                {activeTableIdx === 0 && (
                  <>
                    <li>تم تفعيل نظام حقل الاختيارات <code className="text-indigo-400 font-mono">CHECK(role IN (...))</code> للتأكد من نزاهة الصلاحيات محلياً.</li>
                    <li>حقل <code className="text-indigo-400 font-mono">username UNIQUE</code> يمنع تكرار أسماء المستخدمين على ذات الجهاز بالكامل.</li>
                  </>
                )}
                {activeTableIdx === 1 && (
                  <>
                    <li>تخزين مسارات الصور المتعددة للشقة بصيغة <code className="text-indigo-400 font-mono">TEXT JSON String</code> لتفادي تعقيدات الجداول الفرعية للصور وتسهيل مشاركتها.</li>
                    <li>تم استبعاد تشفير البيانات المفرط للشقق لسرعة استجابة الاستعلامات في جداول التوقيت.</li>
                  </>
                )}
                {activeTableIdx === 2 && (
                  <>
                    <li>حقل الهوية الوطنية رقم <code className="text-indigo-400 font-mono">UNIQUE</code> لمنع ازدواجية تسجيل الزبائن.</li>
                    <li>دعم الفهرس المركب لتسريع الاستعلام الفوري أثناء إدخال الحجوزات.</li>
                  </>
                )}
                {activeTableIdx === 3 && (
                  <>
                    <li>استخدام حقل حسابي مستنتج <code className="text-indigo-400 font-mono">GENERATED ALWAYS AS</code> لحساب وحفظ المبالغ المتبقية للحد من الخطأ البشري.</li>
                    <li>تأمين القيود عبر <code className="text-indigo-400 font-mono">ON DELETE RESTRICT</code> لرفض حذف الشقق أو الزبائن النشطين في الحجوزات لتأمين نزاهة التقارير المالية.</li>
                  </>
                )}
                {activeTableIdx === 4 && (
                  <>
                    <li>توفير سجل مخصص لتعقب أطراف النسخ وتوقيتاتها لتأمين الرقابة الداخلية للمدير.</li>
                  </>
                )}
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Constraints & Indexes Card */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5 space-y-3">
          <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2">
            <Hash className="w-4 h-4 text-indigo-500" />
            فهارس تحسين الاستهلاك (Performance Indexes)
          </h3>
          <p className="text-xs text-slate-500 leading-relaxed">
            تمت إضافة فهارس مخصصة لضمان سرعة فائقة جداً في الاستجابة الفورية عند الاستعلام عن الحجوزات والزبائن مع تزايد حجم البيانات بمرور السنوات (يدعم الفلترة بكسور الأجزاء من الثانية):
          </p>
          <div className="bg-slate-50 p-3 rounded-lg font-mono text-[11px] text-slate-700 dir-ltr select-all max-h-[140px] overflow-y-auto">
            {sqliteIndexes.map((idx, i) => (
              <div key={i} className="mb-2 last:mb-0">
                {idx}
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5 space-y-3">
          <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2 flex-row-reverse justify-end">
            <Key className="w-4 h-4 text-amber-500" />
            منع الحجز المزدوج (Double Booking Constraint)
          </h3>
          <p className="text-xs text-slate-500 leading-relaxed">
            استعلام تداخل الفترات الزمنية للتحقق من عدم تضارب الشقق في نفس المحور الأفقي والزمني قبل كتابة الحجز الفعلي في قاعدة البيانات:
          </p>
          <div className="bg-slate-50 p-3 rounded-lg font-mono text-[11px] text-slate-700 dir-ltr select-all max-h-[140px] overflow-y-auto">
            <pre>{doubleBookingValidationQuery}</pre>
          </div>
        </div>
      </div>
    </div>
  );
};
