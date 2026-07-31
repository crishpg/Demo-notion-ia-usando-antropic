'use client';

import { useEffect, useState } from 'react';
import { LayoutDashboard, Users, FolderKanban, CheckSquare, AlertTriangle, Clock } from 'lucide-react';

interface Stats {
  total_clientes: number;
  total_projetos: number;
  projetos_ativos: number;
  atividades_pendentes: number;
  projetos_urgentes: number;
  projetos_atrasados: number;
}

interface ProjetoAlerta { id: string; nome_projeto: string; situacao: string; }
interface AtividadeAlerta { id: string; nome: string; prioridade: string | null; }

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [alertas, setAlertas] = useState<ProjetoAlerta[]>([]);
  const [atividades, setAtividades] = useState<AtividadeAlerta[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const [pRes, aRes] = await Promise.all([fetch('/api/projetos'), fetch('/api/atividades')]);
        const [projetos, atvsRaw] = await Promise.all([pRes.json(), aRes.json()]);

        const hoje = new Date();
        const ps: ProjetoAlerta[] = [];
        let ativos = 0;
        let urgentes = 0;
        let atrasados = 0;

        for (const p of Array.isArray(projetos) ? projetos : []) {
          if (p.status === 'Em andamento') ativos++;
          if (p.status !== 'Concluído' && p.data_fim) {
            const fim = new Date(p.data_fim);
            const dias = Math.ceil((fim.getTime() - hoje.getTime()) / 86400000);
            if (fim < hoje) { atrasados++; ps.push({ id: p.id, nome_projeto: p.nome_projeto, situacao: 'Atrasado' }); }
            else if (dias <= 2) { urgentes++; ps.push({ id: p.id, nome_projeto: p.nome_projeto, situacao: 'Urgente' }); }
          }
        }

        const atvs = Array.isArray(atvsRaw) ? atvsRaw : [];
        const pendentes = atvs.filter((a: AtividadeAlerta & { status: string }) => a.status !== 'Concluído');

        setStats({
          total_clientes: 0, // clientes não carregados aqui para evitar request extra
          total_projetos: Array.isArray(projetos) ? projetos.length : 0,
          projetos_ativos: ativos,
          atividades_pendentes: pendentes.length,
          projetos_urgentes: urgentes,
          projetos_atrasados: atrasados,
        });
        setAlertas(ps.slice(0, 5));
        setAtividades(pendentes.slice(0, 5));

        // Busca contagem de clientes separado
        const cRes = await fetch('/api/clientes');
        const cs = await cRes.json();
        setStats(s => s ? { ...s, total_clientes: Array.isArray(cs) ? cs.length : 0 } : s);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  if (loading) return <div className="p-6 text-notion-500">Carregando dashboard...</div>;

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-3">
        <LayoutDashboard className="w-6 h-6 text-notion-600 dark:text-notion-400" />
        <div>
          <h1 className="text-2xl font-bold text-notion-900 dark:text-notion-50">Dashboard</h1>
          <p className="text-sm text-notion-600 dark:text-notion-400">Visão geral do sistema</p>
        </div>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard title="Clientes" value={stats?.total_clientes ?? 0} icon={<Users className="w-5 h-5" />} color="bg-accent-blue/10 text-accent-blue" />
        <StatCard title="Projetos" value={stats?.total_projetos ?? 0} icon={<FolderKanban className="w-5 h-5" />} color="bg-accent-purple/10 text-accent-purple" />
        <StatCard title="Projetos Ativos" value={stats?.projetos_ativos ?? 0} icon={<Clock className="w-5 h-5" />} color="bg-accent-green/10 text-accent-green" />
        <StatCard title="Atividades Pendentes" value={stats?.atividades_pendentes ?? 0} icon={<CheckSquare className="w-5 h-5" />} color="bg-accent-yellow/10 text-accent-yellow" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-4">
            <AlertTriangle className="w-4 h-4 text-accent-red" />
            <h2 className="font-semibold text-notion-900 dark:text-notion-50">Projetos que precisam de atenção</h2>
          </div>
          {alertas.length === 0 ? (
            <p className="text-sm text-notion-500 dark:text-notion-400 text-center py-4">Nenhum projeto urgente 🎉</p>
          ) : (
            <ul className="space-y-2">
              {alertas.map(p => (
                <li key={p.id} className="flex items-center justify-between text-sm">
                  <span className="text-notion-800 dark:text-notion-200 truncate flex-1">{p.nome_projeto}</span>
                  <span className={`ml-2 px-2 py-0.5 rounded text-xs font-semibold flex-shrink-0 ${p.situacao === 'Atrasado' ? 'bg-accent-red/10 text-accent-red' : 'bg-accent-yellow/10 text-accent-yellow'}`}>{p.situacao}</span>
                </li>
              ))}
            </ul>
          )}
        </div>

        <div className="bg-white dark:bg-notion-900 border border-notion-200 dark:border-notion-800 rounded-lg p-4">
          <div className="flex items-center gap-2 mb-4">
            <CheckSquare className="w-4 h-4 text-accent-blue" />
            <h2 className="font-semibold text-notion-900 dark:text-notion-50">Atividades em aberto</h2>
          </div>
          {atividades.length === 0 ? (
            <p className="text-sm text-notion-500 dark:text-notion-400 text-center py-4">Nenhuma atividade pendente 🎉</p>
          ) : (
            <ul className="space-y-2">
              {atividades.map(a => (
                <li key={a.id} className="flex items-center justify-between text-sm">
                  <span className="text-notion-800 dark:text-notion-200 truncate flex-1">{a.nome}</span>
                  {a.prioridade && (
                    <span className={`ml-2 px-2 py-0.5 rounded text-xs font-semibold flex-shrink-0 ${a.prioridade === 'Alta' ? 'bg-accent-red/10 text-accent-red' : a.prioridade === 'Média' ? 'bg-accent-yellow/10 text-accent-yellow' : 'bg-accent-green/10 text-accent-green'}`}>{a.prioridade}</span>
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

function StatCard({ title, value, icon, color }: { title: string; value: number; icon: React.ReactNode; color: string; }) {
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
