// Tipos baseados no schema SQL do sistema_freelancers_ddl.sql

export interface Cliente {
  id: string;
  nome: string;
  email: string | null;
  telefone: string | null;
  instagram: string | null;
  drive: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface Projeto {
  id: string;
  nome_projeto: string;
  cliente_id: string | null;
  data_inicio: Date | null;
  data_fim: Date | null;
  status: 'Não iniciado' | 'Em andamento' | 'Concluído';
  lancado: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Atividade {
  id: string;
  nome: string;
  projeto_id: string | null;
  status: 'Não iniciada' | 'Em andamento' | 'Concluído';
  prioridade: 'Baixa' | 'Média' | 'Alta' | null;
  data_inicio: Date | null;
  data_fim: Date | null;
  created_at: Date;
  updated_at: Date;
}

// Views do banco
export interface ProjetoComCliente extends Projeto {
  cliente_nome: string | null;
  cliente_email: string | null;
  cliente_telefone: string | null;
  situacao_prazo: 'Atrasado' | 'Urgente' | 'Próximo ao prazo' | 'No prazo';
  dias_restantes: number | null;
}

export interface AtividadeCompleta extends Atividade {
  nome_projeto: string | null;
  projeto_status: string | null;
  cliente_nome: string | null;
  situacao: 'Atrasada' | 'Vence hoje' | 'No prazo';
}

export interface EstatisticasCliente {
  id: string;
  nome: string;
  email: string | null;
  total_projetos: number;
  projetos_nao_iniciados: number;
  projetos_em_andamento: number;
  projetos_concluidos: number;
}

// Tipos auxiliares
export type StatusProjeto = Projeto['status'];
export type StatusAtividade = Atividade['status'];
export type PrioridadeAtividade = NonNullable<Atividade['prioridade']>;
