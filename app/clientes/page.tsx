import { clientes, getProjetosByClienteId } from '@/lib/mockData';
import { Users, Mail, Phone, Instagram, HardDrive, FolderKanban } from 'lucide-react';

export default function ClientesPage() {
  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <Users className="w-6 h-6 text-notion-600 dark:text-notion-400" />
        <div>
          <h1 className="text-2xl font-bold text-notion-900 dark:text-notion-50">Clientes</h1>
          <p className="text-sm text-notion-600 dark:text-notion-400">{clientes.length} clientes cadastrados</p>
        </div>
      </div>

      {/* Lista de clientes */}
      <div className="grid grid-cols-1 gap-4">
        {clientes.map(cliente => {
          const projetos = getProjetosByClienteId(cliente.id);
          const ativos = projetos.filter(p => p.status === 'Em andamento').length;

          return (
            <div
              key={cliente.id}
              className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg p-5"
            >
              <div className="flex items-start justify-between flex-wrap gap-3">
                {/* Info principal */}
                <div className="space-y-1 min-w-0 flex-1">
                  <h2 className="text-lg font-semibold text-notion-900 dark:text-notion-50">{cliente.nome}</h2>
                  <div className="flex flex-wrap gap-x-4 gap-y-1">
                    {cliente.email && (
                      <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400">
                        <Mail className="w-3.5 h-3.5 flex-shrink-0" />
                        {cliente.email}
                      </span>
                    )}
                    {cliente.telefone && (
                      <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400">
                        <Phone className="w-3.5 h-3.5 flex-shrink-0" />
                        {cliente.telefone}
                      </span>
                    )}
                    {cliente.instagram && (
                      <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400">
                        <Instagram className="w-3.5 h-3.5 flex-shrink-0" />
                        {cliente.instagram}
                      </span>
                    )}
                    {cliente.drive && (
                      <span className="flex items-center gap-1 text-sm text-notion-600 dark:text-notion-400">
                        <HardDrive className="w-3.5 h-3.5 flex-shrink-0" />
                        Drive
                      </span>
                    )}
                  </div>
                </div>

                {/* Badge projetos */}
                <div className="flex items-center gap-3 flex-shrink-0">
                  <div className="text-center">
                    <div className="flex items-center gap-1 text-notion-600 dark:text-notion-400">
                      <FolderKanban className="w-4 h-4" />
                      <span className="text-sm font-medium">{projetos.length}</span>
                    </div>
                    <p className="text-xs text-notion-500">projetos</p>
                  </div>
                  {ativos > 0 && (
                    <span className="px-2 py-1 bg-accent-green/10 text-accent-green text-xs font-semibold rounded">
                      {ativos} ativo{ativos > 1 ? 's' : ''}
                    </span>
                  )}
                </div>
              </div>

              {/* Projetos do cliente */}
              {projetos.length > 0 && (
                <div className="mt-4 pt-4 border-t border-notion-100 dark:border-notion-800">
                  <p className="text-xs font-semibold text-notion-500 dark:text-notion-400 uppercase tracking-wide mb-2">Projetos</p>
                  <div className="flex flex-wrap gap-2">
                    {projetos.map(p => (
                      <span
                        key={p.id}
                        className={`px-2 py-0.5 rounded text-xs font-medium ${
                          p.status === 'Concluído'
                            ? 'bg-notion-100 dark:bg-notion-800 text-notion-600 dark:text-notion-400'
                            : p.status === 'Em andamento'
                            ? 'bg-accent-blue/10 text-accent-blue'
                            : 'bg-notion-100 dark:bg-notion-800 text-notion-500'
                        }`}
                      >
                        {p.nome_projeto}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
