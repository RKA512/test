import React, { useState } from 'react';
import { Folder, FolderOpen, File, ChevronRight, ChevronDown, CheckCircle, Copy, Terminal, Library } from 'lucide-react';
import { flutterFolderStructure, FileNode } from '../data/flutterStructure';

interface TreeNodeProps {
  node: FileNode;
  activeFile: FileNode | null;
  onSelectFile: (file: FileNode) => void;
  depth: number;
}

const TreeNode: React.FC<TreeNodeProps> = ({ node, activeFile, onSelectFile, depth }) => {
  const [isOpen, setIsOpen] = useState<boolean>(true);

  const toggleOpen = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsOpen(!isOpen);
  };

  const isSelected = activeFile?.name === node.name && activeFile?.code === node.code;

  if (node.type === 'folder') {
    return (
      <div className="select-none">
        <button
          type="button"
          onClick={toggleOpen}
          style={{ paddingRight: `${depth * 14}px` }}
          className="w-full text-right py-1.5 px-2 hover:bg-slate-50/50 rounded-lg flex items-center gap-1.5 text-xs font-bold text-slate-700 cursor-pointer transition-colors"
        >
          {isOpen ? <ChevronDown className="w-3.5 h-3.5 text-slate-400" /> : <ChevronRight className="w-3.5 h-3.5 text-slate-400" />}
          {isOpen ? <FolderOpen className="w-4 h-4 text-indigo-500 shrink-0" /> : <Folder className="w-4 h-4 text-indigo-400 shrink-0" />}
          <span className="truncate">{node.name}</span>
        </button>
        {isOpen && node.children && (
          <div className="border-r border-slate-100 mr-2.5 pr-1">
            {node.children.map((child) => (
              <TreeNode
                key={child.name}
                node={child}
                activeFile={activeFile}
                onSelectFile={onSelectFile}
                depth={depth + 1}
              />
            ))}
          </div>
        )}
      </div>
    );
  }

  return (
    <button
      type="button"
      onClick={() => onSelectFile(node)}
      style={{ paddingRight: `${depth * 14}px` }}
      className={`w-full text-right py-1.5 px-2 rounded-lg flex items-center gap-2 text-xs font-medium cursor-pointer transition-colors ${
        isSelected
          ? 'bg-indigo-500/15 border-r-2 border-indigo-600 text-indigo-950 font-bold'
          : 'text-slate-600 hover:bg-slate-50'
      }`}
    >
      <File className={`w-3.5 h-3.5 shrink-0 ${isSelected ? 'text-indigo-600' : 'text-slate-400'}`} />
      <span className="truncate">{node.name}</span>
    </button>
  );
};

export const ArchitectureTree: React.FC = () => {
  // Find the first default file to show
  const findFirstFile = (node: FileNode): FileNode | null => {
    if (node.type === 'file') return node;
    if (node.children) {
      for (const child of node.children) {
        const found = findFirstFile(child);
        if (found) return found;
      }
    }
    return null;
  };

  const [activeFile, setActiveFile] = useState<FileNode | null>(() => findFirstFile(flutterFolderStructure));
  const [copied, setCopied] = useState<boolean>(false);

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-6">
      {/* Explanation Banner */}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <h2 className="text-lg font-extrabold text-slate-800 flex items-center gap-2">
              <Library className="w-5 h-5 text-indigo-600" />
              هيكل مجلدات وتكوين مشروع Flutter (Clean Architecture)
            </h2>
            <p className="text-xs text-slate-500 mt-1 max-w-2xl leading-relaxed">
              تصفح الهيكل الفعلي للمشروع الذي صممناه خصيصاً لتطبيق الكراء اليومي. اضغط على أي ملف لعرض الكود المصدري بلغة Dart ومراجعة توزيع الطبقات الثلاث (Presentation, Domain, Data) المنفصلة كلياً عن تفاصيل واجهات المستخدم وإطار العمل لضمان السهول في الصيانة والتعديل اللانهائي مستقبلاً.
            </p>
          </div>
          <div className="bg-indigo-50 px-3 py-2 rounded-xl border border-indigo-100 text-xs font-semibold text-indigo-800 flex items-center gap-1.5 shrink-0">
            <Terminal className="w-4 h-4 text-indigo-600" />
            توزيع متوافق 100% مع معايير Flutter 3.x
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* File Browser Panel */}
        <div className="lg:col-span-4 bg-white border border-slate-100 rounded-2xl p-4 shadow-xs max-h-[500px] overflow-y-auto">
          <div className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 pr-2">تصفح المشروع</div>
          <TreeNode
            node={flutterFolderStructure}
            activeFile={activeFile}
            onSelectFile={(file) => setActiveFile(file)}
            depth={0}
          />
        </div>

        {/* IDE Simulator Panel */}
        <div className="lg:col-span-8 flex flex-col">
          {activeFile ? (
            <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-sm flex flex-col h-[500px]">
              {/* Header Tab of File */}
              <div className="bg-slate-950/90 border-b border-slate-800 p-4 flex justify-between items-center shrink-0">
                <div className="flex items-center gap-2">
                  <span className="w-3 h-3 rounded-full bg-indigo-500/20 text-indigo-400 text-[10px] font-mono flex items-center justify-center font-bold px-3">
                    {activeFile.name.split('.').pop()?.toUpperCase()}
                  </span>
                  <span className="text-xs font-bold font-mono text-slate-300">
                    {activeFile.name}
                  </span>
                </div>
                {activeFile.code && (
                  <button
                    type="button"
                    onClick={() => copyToClipboard(activeFile.code || '')}
                    className="p-1 px-3 text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white rounded-lg transition-all flex items-center gap-1 cursor-pointer font-semibold"
                  >
                    {copied ? <CheckCircle className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                    {copied ? 'تم النسخ!' : 'نسخ الكود'}
                  </button>
                )}
              </div>

              {/* Description inside Code Editor */}
              <div className="bg-slate-800/20 p-3 px-5 border-b border-slate-800 shrink-0 text-xs text-slate-300 flex items-center gap-2">
                <span className="font-semibold text-indigo-400">الدور البرمجي للوجبة:</span>
                <span className="leading-relaxed font-medium">{activeFile.description}</span>
              </div>

              {/* Code Container */}
              <div className="flex-1 p-5 font-mono text-xs text-slate-350 overflow-auto bg-slate-950 leading-relaxed text-right dir-ltr select-all">
                {activeFile.code ? (
                  <pre>{activeFile.code}</pre>
                ) : (
                  <div className="h-full flex items-center justify-center text-slate-500">
                    ملف بدون كود مصدري مسبق
                  </div>
                )}
              </div>
            </div>
          ) : (
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-8 flex flex-col justify-center items-center text-slate-500 h-[500px]">
              <File className="w-12 h-12 mb-3 text-slate-600" />
              <span>اختر ملفاً من شجرة المجلدات لمعاينة الكود للتأسيسي له</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
