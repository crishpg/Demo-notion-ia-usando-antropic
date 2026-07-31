'use client';

import { useEffect, useState, useCallback } from 'react';
import { Users, Plus, Pencil, Trash2, Mail, Phone, Instagram, HardDrive, FolderKanban } from 'lucide-react';
import Modal from '@/components/Modal';
import ConfirmDialog from '@/components/ConfirmDialog';

interface Cliente {
  id: string;
  nome: string;
  email: string | null;
  telefone: string | null;
  instagram: string | null;
  drive: string | null;
}

const empty = (): Omit<Cliente, 'id'> => ({ nome: '', email: '', telefone: '', instagram: '', drive: '' });

export default function ClientesPage() {
  const [clientes, setClientes] = useState<Cliente[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<Cliente | null>(null);
  const [form, setForm] = useState(empty());

  const [deleteTarget, setDeleteTarget] = useState<Cliente | null>(null);
  const [deleting, setDeleting] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/clientes');
      const data = await res.json();
      setClientes(Array.isArray(data) ? data : []);
    } catch {
      setError('Erro ao carregar clientes.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  function openCreate() {
    setEditing(null);
    setForm(empty());
    setError('');
    setShowForm(true);
  }

  function openEdit(c: Cliente) {
    setEditing(c);
    setForm({ nome: c.nome, email: c.email ?? '', telefone: c.telefone ?? '', instagram: c.instagram ?? '', drive: c.drive ?? '' });
    setError('');
    setShowForm(true);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.nome.trim()) { setError('Nome é obrigatório.'); return; }
    setSaving(true);
    setError('');
    try {
      const method = editing ? 'PUT' : 'POST';
      const body = editing ? { ...form, id: editing.id } : form;
      const res = await fetch('/api/clientes', { method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      const data = await res.json();
      if (!res.ok) { setError(data.error ?? 'Erro ao salvar.'); return; }
      setShowForm(false);
      load();
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
      const res = await fetch('/api/clientes', { method: 'DELETE', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: deleteTarget.id }) });
      if (!res.ok) { const d = await res.json(); alert(d.error ?? 'Erro ao excluir.'); return; }
      setDeleteTarget(null);
      load();
    } catch {
      alert('Erro de conexão.');
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Users className="w-6 h-6 text-notion-600 dark:text-notion-400" />
          <div>
            <h1 className="text-2xl font-bold text-notion-900 dark:text-notion-50">Clientes</h1>
            <p className="text-sm text-notion-600 dark:text-notion-400">{clientes.length} cadastrado{clientes.length !== 1 ? 's' : ''}</p>
          </div>
        </div>
        <button
          onClick={openCreate}
          className="flex items-center gap-2 px-4 py-2 bg-primary text-white text-sm font-medium rounded-md hover:bg-primary-hover transition-colors"
        >
          <Plus className="w-4 h-4" /> Novo Cliente
        </button>
      </div>

      {/* Lista */}
      {loading ? (
        <div className="text-center py-16 text-notion-500">Carregando...</div>
      ) : clientes.length === 0 ? (
        <div className="text-center py-16 text-notion-500">Nenhum cliente cadastrado.</div>
      ) : (
        <div className="grid grid-cols-1 gap-4">
          {clientes.map(c => (
            <div key={c.id} className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg p-5">
              <div className="flex items-start justify-between gap-3 flex-wrap">
                <div className="space-y-1 min-w-0 flex-1">
                  <h2 className="text-base font-semibold text-notion-900 dark:text-notion-50">{c.nome}</h2>
                  <div className="flex flex-wrap gap-x-4 gap-y-1">
                    {c.email && <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400"><Mail className="w-3.5 h-3.5" />{c.email}</span>}
                    {c.telefone && <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400"><Phone className="w-3.5 h-3.5" />{c.telefone}</span>}
                    {c.instagram && <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400"><Instagram className="w-3.5 h-3.5" />{c.instagram}</span>}
                    {c.drive && <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400"><HardDrive className="w-3.5 h-3.5" />Drive</span>}
                  </div>
                </div>
                <div className="flex items-center gap-2 flex-shrink-0">
                  <button onClick={() => openEdit(c)} className="p-2 rounded-md hover:bg-notion-100 dark:hover:bg-notion-800 text-notion-500 transition-colors" title="Editar">
                    <Pencil className="w-4 h-4" />
                  </button>
                  <button onClick={() => setDeleteTarget(c)} className="p-2 rounded-md hover:bg-accent-red/10 text-notion-500 hover:text-accent-red transition-colors" title="Excluir">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal form */}
      {showForm && (
        <Modal title={editing ? 'Editar Cliente' : 'Novo Cliente'} onClose={() => setShowForm(false)}>
          <form onSubmit={handleSubmit} className="space-y-4">
            {error && <p className="text-sm text-accent-red bg-accent-red/10 rounded px-3 py-2">{error}</p>}
            <Field label="Nome *" value={form.nome} onChange={v => setForm(f => ({ ...f, nome: v }))} placeholder="Nome do cliente" />
            <Field label="E-mail" type="email" value={form.email ?? ''} onChange={v => setForm(f => ({ ...f, email: v }))} placeholder="email@exemplo.com" />
            <Field label="Telefone" value={form.telefone ?? ''} onChange={v => setForm(f => ({ ...f, telefone: v }))} placeholder="5511999999999" />
            <Field label="Instagram" value={form.instagram ?? ''} onChange={v => setForm(f => ({ ...f, instagram: v }))} placeholder="https://instagram.com/..." />
            <Field label="Drive" value={form.drive ?? ''} onChange={v => setForm(f => ({ ...f, drive: v }))} placeholder="https://drive.google.com/..." />
            <div className="flex gap-3 justify-end pt-2 border-t border-notion-100 dark:border-notion-800">
              <button type="button" onClick={() => setShowForm(false)} className="px-4 py-2 text-sm font-medium text-notion-700 dark:text-notion-300 border border-notion-200 dark:border-notion-700 rounded-md hover:bg-notion-50 dark:hover:bg-notion-800 transition-colors">
                Cancelar
              </button>
              <button type="submit" disabled={saving} className="px-4 py-2 text-sm font-medium text-white bg-primary rounded-md hover:bg-primary-hover transition-colors disabled:opacity-50">
                {saving ? 'Salvando...' : editing ? 'Salvar' : 'Criar'}
              </button>
            </div>
          </form>
        </Modal>
      )}

      {/* Confirm delete */}
      {deleteTarget && (
        <ConfirmDialog
          message={`Excluir o cliente "${deleteTarget.nome}"?`}
          onConfirm={handleDelete}
          onCancel={() => setDeleteTarget(null)}
          loading={deleting}
        />
      )}
    </div>
  );
}

function Field({ label, value, onChange, placeholder, type = 'text' }: {
  label: string; value: string; onChange: (v: string) => void; placeholder?: string; type?: string;
}) {
  return (
    <div>
      <label className="block text-xs font-semibold text-notion-600 dark:text-notion-400 mb-1">{label}</label>
      <input
        type={type}
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full px-3 py-2 text-sm border border-notion-200 dark:border-notion-700 rounded-md bg-white dark:bg-notion-950 text-notion-900 dark:text-notion-50 placeholder:text-notion-400 focus:outline-none focus:ring-2 focus:ring-primary/50"
      />
    </div>
  );
}
