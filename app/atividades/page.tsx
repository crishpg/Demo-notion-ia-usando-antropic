import { getAtividadesCompletas } from '@/lib/mockData';
import { CheckSquare, Calendar, FolderKanban } from 'lucide-react';

const statusColor: Record<string, string> = {
  'Concluído':    'bg-accent-green/10 text-accent-green',
  'Em andamento': 'bg-accent-blue/10 text-accent-blue',
  'Não iniciada': 'bg-notion-100 dark:bg-notion-800 text-notion-500',
};

const prioridadeColor: Record<string, string> = {
  'Alta':  'bg-accent-red/10 text-accent-red',
  'Média': 'bg-accent-yellow/10 text-accent-yellow',
  'Baixa': 'bg-accent-green/10 text-accent-green',
};

const situacaoColor: Record<string, string> = {
  'Atrasada':    'bg-accent-red/10 text-accent-red',
  'Vence hoje':  'bg-accent-yellow/10 text-accent-yellow',
  'No prazo':    'bg-accent-green/10 text-accent-green',
};

export default function AtividadesPage() {
  const atividades = getAtividadesCompletas();

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <CheckSquare className="w-6 h-6 text-notion-600 dark:text-notion-400" />
        <div>
          <h1 className="text-2xl font-bold text-notion-900 dark:text-notion-50">Atividades</h1>
          <p className="text-sm text-notion-600 dark:text-notion-400">{atividades.length} atividades cadastradas</p>
        </div>
      </div>

      {/* Tabela */}
      <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-notion-200 dark:border-notion-800 bg-notion-50 dark:bg-notion-950">
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Atividade</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Projeto</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Prioridade</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Prazo</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-notion-600 dark:text-notion-400 uppercase tracking-wide">Situação</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-notion-100 dark:divide-notion-800">
              {atividades.map(a => (
                <tr key={a.id} className="hover:bg-notion-50 dark:hover:bg-notion-800/50 transition-colors">
                  <td className="px-4 py-3">
                    <span className="font-medium text-notion-900 dark:text-notion-50">{a.nome}</span>
                  </td>
                  <td className="px-4 py-3">
                    {a.nome_projeto ? (
                      <div className="flex items-center gap-1 text-notion-600 dark:text-notion-400">
                        <FolderKanban className="w-3.5 h-3.5 flex-shrink-0" />
                        {a.nome_projeto}
                      </div>
                    ) : (
                      <span className="text-notion-400 italic">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded text-xs font-semibold ${statusColor[a.status]}`}>
                      {a.status}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {a.prioridade ? (
                      <span className={`px-2 py-0.5 rounded text-xs font-semibold ${prioridadeColor[a.prioridade]}`}>
                        {a.prioridade}
                      </span>
                    ) : (
                      <span className="text-notion-400 italic text-xs">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    {a.data_fim ? (
                      <div className="flex items-center gap-1 text-notion-600 dark:text-notion-400">
                        <Calendar className="w-3.5 h-3.5 flex-shrink-0" />
                        {new Date(a.data_fim).toLocaleDateString('pt-BR')}
                      </div>
                    ) : (
                      <span className="text-notion-400 italic">—</span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    {a.status !== 'Concluído' && a.data_fim ? (
                      <span className={`px-2 py-0.5 rounded text-xs font-semibold ${situacaoColor[a.situacao]}`}>
                        {a.situacao}
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
