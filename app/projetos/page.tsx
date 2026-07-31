import { getProjetosComClientes, clientes } from '@/lib/mockData';
import { FolderKanban, Calendar, User } from 'lucide-react';

const statusColor: Record<string, string> = {
  'Concluído':    'bg-accent-green/10 text-accent-green',
  'Em andamento': 'bg-accent-blue/10 text-accent-blue',
  'Não iniciado': 'bg-notion-100 dark:bg-notion-800 text-notion-500',
};

const prazoColor: Record<string, string> = {
  'Atrasado':         'bg-accent-red/10 text-accent-red',
  'Urgente':          'bg-accent-yellow/10 text-accent-yellow',
  'Próximo ao prazo': 'bg-accent-yellow/10 text-accent-yellow',
  'No prazo':         'bg-accent-green/10 text-accent-green',
};

export default function ProjetosPage() {
  const projetos = getProjetosComClientes();

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <FolderKanban className="w-6 h-6 text-notion-600 dark:text-notion-400" />
        <div>
          <h1 className="text-2xl font-bold text-notion-900 dark:text-notion-50">Projetos</h1>
          <p className="text-sm text-notion-600 dark:text-notion-400">{projetos.length} projetos cadastrados</p>
        </div>
      </div>

      {/* Tabela */}
      <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-notion-200 dark:border-notion-800 bg-notion-50 dark:bg-notion-950">
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Projeto</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Cliente</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Prazo</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Situação</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-notion-100 dark:divide-notion-800">
              {projetos.map(p => (
                <tr key={p.id} className="hover:bg-notion-50 dark:hover:bg-notion-800/50 transition-colors">
                  <td className="px-4 py-3">
                    <div className="font-medium text-notion-900 dark:text-notion-50">{p.nome_projeto}</div>
                    {p.lancado && (
                      <span className="text-xs text-accent-green">Lançado</span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1 text-notion-600 dark:text-notion-400">
                      <User className="w-3.5 h-3.5 flex-shrink-0" />
                      {p.cliente_nome ?? <span className="italic text-notion-400">—</span>}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded text-xs font-semibold ${statusColor[p.status]}`}>
                      {p.status}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {p.data_fim ? (
                      <div className="flex items-center gap-1 text-notion-600 dark:text-notion-400">
                        <Calendar className="w-3.5 h-3.5 flex-shrink-0" />
                        {new Date(p.data_fim).toLocaleDateString('pt-BR')}
                      </div>
                    ) : (
                      <span className="text-notion-400 italic">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    {p.status !== 'Concluído' && p.data_fim ? (
                      <span className={`px-2 py-0.5 rounded text-xs font-semibold ${prazoColor[p.situacao_prazo]}`}>
                        {p.situacao_prazo}
                        {p.dias_restantes !== null && p.dias_restantes > 0 && ` (${p.dias_restantes}d)`}
                      </span>
                    ) : (
                      <span className="text-notion-400 italic text-xs">—</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
