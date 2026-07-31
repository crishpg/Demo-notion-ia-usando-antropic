'use client';

import { Trash2, AlertTriangle } from 'lucide-react';

interface ConfirmDialogProps {
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
  loading?: boolean;
}

export default function ConfirmDialog({ message, onConfirm, onCancel, loading }: ConfirmDialogProps) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="bg-white dark:bg-notion-900 rounded-lg shadow-xl w-full max-w-sm p-6">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-accent-red/10 rounded-full">
            <AlertTriangle className="w-5 h-5 text-accent-red" />
          </div>
          <p className="text-notion-900 dark:text-notion-50 font-medium">{message}</p>
        </div>
        <p className="text-sm text-notion-600 dark:text-notion-400 mb-5">Esta ação não pode ser desfeita.</p>
        <div className="flex gap-3 justify-end">
          <button
            onClick={onCancel}
            disabled={loading}
            className="px-4 py-2 text-sm font-medium text-notion-700 dark:text-notion-300 border border-notion-200 dark:border-notion-700 rounded-md hover:bg-notion-50 dark:hover:bg-notion-800 transition-colors disabled:opacity-50"
          >
            Cancelar
          </button>
          <button
            onClick={onConfirm}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-accent-red rounded-md hover:bg-red-600 transition-colors disabled:opacity-50"
          >
            <Trash2 className="w-3.5 h-3.5" />
            {loading ? 'Excluindo...' : 'Excluir'}
          </button>
        </div>
      </div>
    </div>
  );
}
