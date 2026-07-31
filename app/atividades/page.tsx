'use client';

import { useEffect, useState, useCallback } from 'react';
import { CheckSquare, Plus, Pencil, Trash2, Calendar, FolderKanban } from 'lucide-react';
import Modal from '@/components/Modal';
import ConfirmDialog from '@/components/ConfirmDialog';

interface Atividade {
  id: string;
  nome: string;
  projeto_id: string | null;
  nome_projeto: string | null;
  status: 'Não iniciada' | 'Em andamento' | 'Concluído';
  prioridade: 'Baixa' | 'Média' | 'Alta' | null;
  data_inicio: string | null;
  data_fim: string | null;
}

interface Projeto { id: string; nome_projeto: string; }

const STATUS_OPTIONS  = ['Não iniciada', 'Em andamento', 'Concluído'] as const;
const PRIOR_OPTIONS   = ['Baixa', 'Média', 'Alta'] as const;

const statusColor: Record<string, string> = {
  'Concluído':    'bg-accent-green/10 text-accent-green',
  'Em andamento': 'bg-accent-blue/10 text-accent-blue',
  'Não iniciada': 'bg-notion-100 dark:bg-notion-800 text-notion-500',
};
const priorColor: Record<string, string> = {
  'Alta':  'bg-accent-red/10 text-accent-red',
  'Média': 'bg-accent-yellow/10 text-accent-yellow',
  'Baixa': 'bg-accent-green/10 text-accent-green',
};

type FormState = { nome: string; projeto_id: string; status: 'Não iniciada' | 'Em andamento' | 'Concluído'; prioridade: '' | 'Baixa' | 'Média' | 'Alta'; data_inicio: string; data_fim: string; };
const emptyForm = (): FormState => ({ nome: '', projeto_id: '', status: 'Não iniciada', prioridade: '', data_inicio: '', data_fim: '' });

export default function AtividadesPage() {
  const [atividades, setAtividades] = useState<Atividade[]>([]);
  const [projetos, setProjetos] = useState<Projeto[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<Atividade | null>(null);
  const [form, setForm] = useState(emptyForm());
  const [deleteTarget, setDeleteTarget] = useState<Atividade | null>(null);
  const [deleting, setDeleting] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [aRes, pRes] = await Promise.all([fetch('/api/atividades'), fetch('/api/projetos')]);
      const [aData, pData] = await Promise.all([aRes.json(), pRes.json()]);
      setAtividades(Array.isArray(aData) ? aData : []);
      setProjetos(Array.isArray(pData) ? pData : []);
    } catch {
      setError('Erro ao carregar dados.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  function openCreate() {
    setEditing(null); setForm(emptyForm()); setError(''); setShowForm(true);
  }

  function openEdit(a: Atividade) {
    setEditing(a);
    setForm({
      nome: a.nome,
      projeto_id: a.projeto_id ?? '',
      status: a.status,
      prioridade: a.prioridade ?? '',
      data_inicio: a.data_inicio ? a.data_inicio.split('T')[0] : '',
      data_fim: a.data_fim ? a.data_fim.split('T')[0] : '',
    });
    setError(''); setShowForm(true);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.nome.trim()) { setError('Nome é obrigatório.'); return; }
    setSaving(true); setError('');
    try {
      const method = editing ? 'PUT' : 'POST';
      const body = editing ? { ...form, id: editing.id } : form;
      const res = await fetch('/api/atividades', { method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      const data = await res.json();
      if (!res.ok) { setError(data.error ?? 'Erro ao salvar.'); return; }
      setShowForm(false); load();
    } catch {
      setError('Erro de conexão.');
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    setDeleting(true);
    try {
      const res = await fetch('/api/atividades', { method: 'DELETE', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: deleteTarget.id }) });
      if (!res.ok) { const d = await res.json(); alert(d.error ?? 'Erro ao excluir.'); return; }
      setDeleteTarget(null); load();
    } catch {
      alert('Erro de conexão.');
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <CheckSquare className="w-6 h-6 text-notion-600 dark:text-notion-400" />
          <div>
            <h1 className="text-2xl font-bold text-notion-900 dark:text-notion-50">Atividades</h1>
            <p className="text-sm text-notion-600 dark:text-notion-400">{atividades.length} cadastrada{atividades.length !== 1 ? 's' : ''}</p>
          </div>
        </div>
        <button onClick={openCreate} className="flex items-center gap-2 px-4 py-2 bg-primary text-white text-sm font-medium rounded-md hover:bg-primary-hover transition-colors">
          <Plus className="w-4 h-4" /> Nova Atividade
        </button>
      </div>

      {loading ? (
        <div className="text-center py-16 text-notion-500">Carregando...</div>
      ) : atividades.length === 0 ? (
        <div className="text-center py-16 text-notion-500">Nenhuma atividade cadastrada.</div>
      ) : (
        <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-notion-200 dark:border-notion-800 bg-notion-50 dark:bg-notion-950">
                  {['Atividade', 'Projeto', 'Status', 'Prioridade', 'Prazo', ''].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-notion-100 dark:divide-notion-800">
                {atividades.map(a => (
                  <tr key={a.id} className="hover:bg-notion-50 dark:hover:bg-notion-800/50 transition-colors">
                    <td className="px-4 py-3 font-medium text-notion-900 dark:text-notion-50 max-w-[180px] truncate">{a.nome}</td>
                    <td className="px-4 py-3">
                      {a.nome_projeto ? (
                        <span className="flex items-center gap-1 text-notion-600 dark:text-notion-400"><FolderKanban className="w-3.5 h-3.5" />{a.nome_projeto}</span>
                      ) : <span className="text-notion-400 italic">—</span>}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded text-xs font-semibold ${statusColor[a.status]}`}>{a.status}</span>
                    </td>
                    <td className="px-4 py-3">
                      {a.prioridade ? (
                        <span className={`px-2 py-0.5 rounded text-xs font-semibold ${priorColor[a.prioridade]}`}>{a.prioridade}</span>
                      ) : <span className="text-notion-400 italic">—</span>}
                    </td>
                    <td className="px-4 py-3 text-notion-600 dark:text-notion-400">
                      {a.data_fim ? <span className="flex items-center gap-1"><Calendar className="w-3.5 h-3.5" />{new Date(a.data_fim).toLocaleDateString('pt-BR')}</span> : '—'}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        <button onClick={() => openEdit(a)} className="p-1.5 rounded hover:bg-notion-100 dark:hover:bg-notion-800 text-notion-500 transition-colors" title="Editar"><Pencil className="w-3.5 h-3.5" /></button>
                        <button onClick={() => setDeleteTarget(a)} className="p-1.5 rounded hover:bg-accent-red/10 text-notion-500 hover:text-accent-red transition-colors" title="Excluir"><Trash2 className="w-3.5 h-3.5" /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {showForm && (
        <Modal title={editing ? 'Editar Atividade' : 'Nova Atividade'} onClose={() => setShowForm(false)}>
          <form onSubmit={handleSubmit} className="space-y-4">
            {error && <p className="text-sm text-accent-red bg-accent-red/10 rounded px-3 py-2">{error}</p>}
            <div>
              <label className="block text-xs font-semibold text-notion-600 dark:text-notion-400 mb-1">Nome *</label>
              <input type="text" value={form.nome} onChange={e => setForm(f => ({ ...f, nome: e.target.value }))} placeholder="Nome da atividade" className="w-full px-3 py-2 text-sm border border-notion-200 dark:border-notion-700 rounded-md bg-white dark:bg-notion-950 text-notion-900 dark:text-notion-50 focus:outline-none focus:ring-2 focus:ring-primary/50" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-notion-600 dark:text-notion-400 mb-1">Projeto</label>
              <select value={form.projeto_id} onChange={e => setForm(f => ({ ...f, projeto_id: e.target.value }))} className="w-full px-3 py-2 text-sm border border-notion-200 dark:border-notion-700 rounded-md bg-white dark:bg-notion-950 text-notion-900 dark:text-notion-50 focus:outline-none focus:ring-2 focus:ring-primary/50">
                <option value="">— Nenhum —</option>
                {projetos.map(p => <option key={p.id} value={p.id}>{p.nome_projeto}</option>)}
              </select>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-notion-600 dark:text-notion-400 mb-1">Status</label>
                <select value={form.status} onChange={e => setForm(f => ({ ...f, status: e.target.value as typeof form.status }))} className="w-full px-3 py-2 text-sm border border-notion-200 dark:border-notion-700 rounded-md bg-white dark:bg-notion-950 text-notion-900 dark:text-notion-50 focus:outline-none focus:ring-2 focus:ring-primary/50">
                  {STATUS_OPTIONS.map(s => <option key={s} value={s}>{s}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs font-semibold text-notion-600 dark:text-notion-400 mb-1">Prioridade</label>
                <select value={form.prioridade} onChange={e => setForm(f => ({ ...f, prioridade: e.target.value as typeof form.prioridade }))} className="w-full px-3 py-2 text-sm border border-notion-200 dark:border-notion-700 rounded-md bg-white dark:bg-notion-950 text-notion-900 dark:text-notion-50 focus:outline-none focus:ring-2 focus:ring-primary/50">
                  <option value="">— Nenhuma —</option>
                  {PRIOR_OPTIONS.map(p => <option key={p} value={p}>{p}</option>)}
                </select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-notion-600 dark:text-notion-400 mb-1">Data Início</label>
                <input type="date" value={form.data_inicio} onChange={e => setForm(f => ({ ...f, data_inicio: e.target.value }))} className="w-full px-3 py-2 text-sm border border-notion-200 dark:border-notion-700 rounded-md bg-white dark:bg-notion-950 text-notion-900 dark:text-notion-50 focus:outline-none focus:ring-2 focus:ring-primary/50" />
              </div>
              <div>
                <label className="block text-xs font-semibold text-notion-600 dark:text-notion-400 mb-1">Data Fim</label>
                <input type="date" value={form.data_fim} onChange={e => setForm(f => ({ ...f, data_fim: e.target.value }))} className="w-full px-3 py-2 text-sm border border-notion-200 dark:border-notion-700 rounded-md bg-white dark:bg-notion-950 text-notion-900 dark:text-notion-50 focus:outline-none focus:ring-2 focus:ring-primary/50" />
              </div>
            </div>
            <div className="flex gap-3 justify-end pt-2 border-t border-notion-100 dark:border-notion-800">
              <button type="button" onClick={() => setShowForm(false)} className="px-4 py-2 text-sm font-medium text-notion-700 dark:text-notion-300 border border-notion-200 dark:border-notion-700 rounded-md hover:bg-notion-50 dark:hover:bg-notion-800 transition-colors">Cancelar</button>
              <button type="submit" disabled={saving} className="px-4 py-2 text-sm font-medium text-white bg-primary rounded-md hover:bg-primary-hover transition-colors disabled:opacity-50">{saving ? 'Salvando...' : editing ? 'Salvar' : 'Criar'}</button>
            </div>
          </form>
        </Modal>
      )}

      {deleteTarget && (
        <ConfirmDialog
          message={`Excluir a atividade "${deleteTarget.nome}"?`}
          onConfirm={handleDelete}
          onCancel={() => setDeleteTarget(null)}
          loading={deleting}
        />
      )}
    </div>
  );
}
