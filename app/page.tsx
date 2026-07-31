import { getDashboardStats, getProjetosComClientes, getAtividadesCompletas } from '@/lib/mockData';
import { LayoutDashboard, Users, FolderKanban, CheckSquare, AlertTriangle, Clock } from 'lucide-react';

export default function DashboardPage() {
  const stats = getDashboardStats();
  const projetos = getProjetosComClientes();
  const atividades = getAtividadesCompletas();

  const projetosUrgentes = projetos.filter(p => p.situacao_prazo === 'Urgente' || p.situacao_prazo === 'Atrasado');
  const atividadesPendentes = atividades.filter(a => a.status !== 'Concluído').slice(0, 5);

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <LayoutDashboard className="w-6 h-6 text-notion-600 dark:text-notion-400" />
        <div>
          <h1 className="text-2xl font-bold text-notion-900 dark:text-notion-50">Dashboard</h1>
          <p className="text-sm text-notion-600 dark:text-notion-400">Visão geral do sistema</p>
        </div>
      </div>

      {/* Cards de estatísticas */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Clientes"
          value={stats.total_clientes}
          icon={<Users className="w-5 h-5" />}
          color="bg-accent-blue/10 text-accent-blue"
        />
        <StatCard
          title="Projetos"
          value={stats.total_projetos}
          icon={<FolderKanban className="w-5 h-5" />}
          color="bg-accent-purple/10 text-accent-purple"
        />
        <StatCard
          title="Projetos Ativos"
          value={stats.projetos_ativos}
          icon={<Clock className="w-5 h-5" />}
          color="bg-accent-green/10 text-accent-green"
        />
        <StatCard
          title="Atividades Pendentes"
          value={stats.atividades_pendentes}
          icon={<CheckSquare className="w-5 h-5" />}
          color="bg-accent-yellow/10 text-accent-yellow"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Projetos urgentes */}
        <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-4">
            <AlertTriangle className="w-4 h-4 text-accent-red" />
            <h2 className="font-semibold text-notion-900 dark:text-notion-50">Projetos que precisam de atenção</h2>
          </div>
          {projetosUrgentes.length === 0 ? (
            <p className="text-sm text-notion-500 dark:text-notion-400 text-center py-4">Nenhum projeto urgente 🎉</p>
          ) : (
            <ul className="space-y-2">
              {projetosUrgentes.slice(0, 5).map(p => (
                <li key={p.id} className="flex items-center justify-between text-sm">
                  <span className="text-notion-800 dark:text-notion-200 truncate flex-1">{p.nome_projeto}</span>
                  <span className={`ml-2 px-2 py-0.5 rounded text-xs font-semibold flex-shrink-0 ${
                    p.situacao_prazo === 'Atrasado'
                      ? 'bg-accent-red/10 text-accent-red'
                      : 'bg-accent-yellow/10 text-accent-yellow'
                  }`}>
                    {p.situacao_prazo}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Atividades recentes */}
        <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-4">
            <CheckSquare className="w-4 h-4 text-accent-blue" />
            <h2 className="font-semibold text-notion-900 dark:text-notion-50">Atividades em aberto</h2>
          </div>
          {atividadesPendentes.length === 0 ? (
            <p className="text-sm text-notion-500 dark:text-notion-400 text-center py-4">Nenhuma atividade pendente 🎉</p>
          ) : (
            <ul className="space-y-2">
              {atividadesPendentes.map(a => (
                <li key={a.id} className="flex items-center justify-between text-sm">
                  <span className="text-notion-800 dark:text-notion-200 truncate flex-1">{a.nome}</span>
                  {a.prioridade && (
                    <span className={`ml-2 px-2 py-0.5 rounded text-xs font-semibold flex-shrink-0 ${
                      a.prioridade === 'Alta'
                        ? 'bg-accent-red/10 text-accent-red'
                        : a.prioridade === 'Média'
                        ? 'bg-accent-yellow/10 text-accent-yellow'
                        : 'bg-accent-green/10 text-accent-green'
                    }`}>
                      {a.prioridade}
                    </span>
                  )}
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}

function StatCard({
  title,
  value,
  icon,
  color,
}: {
  title: string;
  value: number;
  icon: React.ReactNode;
  color: string;
}) {
  return (
    <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg p-4">
      <div className="flex items-center justify-between mb-2">
        <span className="text-xs font-medium text-notion-600 dark:text-notion-400 uppercase tracking-wide">{title}</span>
        <div className={`p-1.5 rounded-md ${color}`}>{icon}</div>
      </div>
      <p className="text-3xl font-bold text-notion-900 dark:text-notion-50">{value}</p>
    </div>
  );
}
