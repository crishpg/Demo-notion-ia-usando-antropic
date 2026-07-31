import { Cliente, Projeto, Atividade, ProjetoComCliente, AtividadeCompleta, EstatisticasCliente } from '@/types';

// ==================== CLIENTES ====================
export const clientes: Cliente[] = [
  {
    id: '1',
    nome: 'Cliente X',
    email: 'gabi.br1092@gmail.com',
    telefone: null,
    instagram: null,
    drive: null,
    created_at: new Date('2024-01-15'),
    updated_at: new Date('2024-01-15'),
  },
  {
    id: '2',
    nome: 'Cliente B',
    email: 'cristiano.crishpg@gmail.com',
    telefone: '55981458558',
    instagram: 'www.insta..',
    drive: 'xxx',
    created_at: new Date('2024-01-20'),
    updated_at: new Date('2024-01-20'),
  },
  {
    id: '3',
    nome: 'Tech Startup Inc',
    email: 'contato@techstartup.com',
    telefone: '5511999887766',
    instagram: 'https://instagram.com/techstartup',
    drive: 'https://drive.google.com/drive/folders/xyz',
    created_at: new Date('2024-02-01'),
    updated_at: new Date('2024-02-01'),
  },
  {
    id: '4',
    nome: 'Design Studio',
    email: 'hello@designstudio.com',
    telefone: '5521988776655',
    instagram: 'https://instagram.com/designstudio',
    drive: null,
    created_at: new Date('2024-02-10'),
    updated_at: new Date('2024-02-10'),
  },
  {
    id: '5',
    nome: 'E-commerce Solutions',
    email: 'contato@ecommerce.com',
    telefone: null,
    instagram: null,
    drive: 'https://drive.google.com/drive/folders/abc',
    created_at: new Date('2024-02-15'),
    updated_at: new Date('2024-02-15'),
  },
];

// ==================== PROJETOS ====================
export const projetos: Projeto[] = [
  {
    id: '1',
    nome_projeto: 'Novo Projeto',
    cliente_id: '1',
    data_inicio: new Date('2024-03-04'),
    data_fim: new Date('2024-03-31'),
    status: 'Não iniciado',
    lancado: true,
    created_at: new Date('2024-03-01'),
    updated_at: new Date('2024-03-01'),
  },
  {
    id: '2',
    nome_projeto: 'projeto teste',
    cliente_id: '1',
    data_inicio: new Date('2024-03-07'),
    data_fim: new Date('2026-09-15'),
    status: 'Em andamento',
    lancado: true,
    created_at: new Date('2024-03-07'),
    updated_at: new Date('2024-03-07'),
  },
  {
    id: '3',
    nome_projeto: 'Website Institucional',
    cliente_id: '3',
    data_inicio: new Date('2024-04-01'),
    data_fim: new Date('2026-08-30'),
    status: 'Em andamento',
    lancado: false,
    created_at: new Date('2024-04-01'),
    updated_at: new Date('2024-04-01'),
  },
  {
    id: '4',
    nome_projeto: 'Redesign de Marca',
    cliente_id: '4',
    data_inicio: new Date('2024-03-15'),
    data_fim: new Date('2024-05-15'),
    status: 'Concluído',
    lancado: true,
    created_at: new Date('2024-03-10'),
    updated_at: new Date('2024-05-16'),
  },
  {
    id: '5',
    nome_projeto: 'Plataforma E-commerce',
    cliente_id: '5',
    data_inicio: new Date('2026-08-01'),
    data_fim: new Date('2026-10-31'),
    status: 'Em andamento',
    lancado: false,
    created_at: new Date('2026-07-25'),
    updated_at: new Date('2026-07-25'),
  },
  {
    id: '6',
    nome_projeto: 'App Mobile',
    cliente_id: '3',
    data_inicio: new Date('2026-09-01'),
    data_fim: new Date('2026-11-30'),
    status: 'Não iniciado',
    lancado: false,
    created_at: new Date('2026-08-20'),
    updated_at: new Date('2026-08-20'),
  },
  {
    id: '7',
    nome_projeto: 'Sistema de Gestão',
    cliente_id: '2',
    data_inicio: new Date('2024-02-01'),
    data_fim: new Date('2024-06-30'),
    status: 'Concluído',
    lancado: true,
    created_at: new Date('2024-01-25'),
    updated_at: new Date('2024-07-01'),
  },
];

// ==================== ATIVIDADES ====================
export const atividades: Atividade[] = [
  {
    id: '1',
    nome: 'Desenvolver Página',
    projeto_id: '1',
    status: 'Não iniciada',
    prioridade: null,
    data_inicio: null,
    data_fim: null,
    created_at: new Date('2024-03-01'),
    updated_at: new Date('2024-03-01'),
  },
  {
    id: '2',
    nome: 'Exemplo 1',
    projeto_id: '2',
    status: 'Em andamento',
    prioridade: 'Alta',
    data_inicio: new Date('2024-06-01'),
    data_fim: new Date('2024-06-03'),
    created_at: new Date('2024-03-07'),
    updated_at: new Date('2024-03-07'),
  },
  {
    id: '3',
    nome: 'Design da Homepage',
    projeto_id: '3',
    status: 'Em andamento',
    prioridade: 'Alta',
    data_inicio: new Date('2024-04-05'),
    data_fim: new Date('2026-08-15'),
    created_at: new Date('2024-04-01'),
    updated_at: new Date('2024-04-05'),
  },
  {
    id: '4',
    nome: 'Desenvolvimento Frontend',
    projeto_id: '3',
    status: 'Não iniciada',
    prioridade: 'Média',
    data_inicio: null,
    data_fim: new Date('2026-08-25'),
    created_at: new Date('2024-04-01'),
    updated_at: new Date('2024-04-01'),
  },
  {
    id: '5',
    nome: 'Integração Backend',
    projeto_id: '3',
    status: 'Não iniciada',
    prioridade: 'Baixa',
    data_inicio: null,
    data_fim: new Date('2026-08-28'),
    created_at: new Date('2024-04-01'),
    updated_at: new Date('2024-04-01'),
  },
  {
    id: '6',
    nome: 'Pesquisa de Mercado',
    projeto_id: '4',
    status: 'Concluído',
    prioridade: 'Alta',
    data_inicio: new Date('2024-03-15'),
    data_fim: new Date('2024-03-30'),
    created_at: new Date('2024-03-10'),
    updated_at: new Date('2024-03-30'),
  },
  {
    id: '7',
    nome: 'Criação de Logo',
    projeto_id: '4',
    status: 'Concluído',
    prioridade: 'Alta',
    data_inicio: new Date('2024-04-01'),
    data_fim: new Date('2024-04-20'),
    created_at: new Date('2024-03-10'),
    updated_at: new Date('2024-04-20'),
  },
  {
    id: '8',
    nome: 'Manual de Identidade Visual',
    projeto_id: '4',
    status: 'Concluído',
    prioridade: 'Média',
    data_inicio: new Date('2024-04-21'),
    data_fim: new Date('2024-05-15'),
    created_at: new Date('2024-03-10'),
    updated_at: new Date('2024-05-15'),
  },
  {
    id: '9',
    nome: 'Setup de Infraestrutura',
    projeto_id: '5',
    status: 'Em andamento',
    prioridade: 'Alta',
    data_inicio: new Date('2026-08-01'),
    data_fim: new Date('2026-08-15'),
    created_at: new Date('2026-07-25'),
    updated_at: new Date('2026-08-01'),
  },
  {
    id: '10',
    nome: 'Desenvolvimento do Catálogo',
    projeto_id: '5',
    status: 'Em andamento',
    prioridade: 'Alta',
    data_inicio: new Date('2026-08-10'),
    data_fim: new Date('2026-09-10'),
    created_at: new Date('2026-07-25'),
    updated_at: new Date('2026-08-10'),
  },
  {
    id: '11',
    nome: 'Sistema de Pagamentos',
    projeto_id: '5',
    status: 'Não iniciada',
    prioridade: 'Alta',
    data_inicio: null,
    data_fim: new Date('2026-10-01'),
    created_at: new Date('2026-07-25'),
    updated_at: new Date('2026-07-25'),
  },
  {
    id: '12',
    nome: 'Testes e Deploy',
    projeto_id: '5',
    status: 'Não iniciada',
    prioridade: 'Média',
    data_inicio: null,
    data_fim: new Date('2026-10-25'),
    created_at: new Date('2026-07-25'),
    updated_at: new Date('2026-07-25'),
  },
];

// ==================== FUNÇÕES AUXILIARES ====================

export function getClienteById(id: string): Cliente | undefined {
  return clientes.find(c => c.id === id);
}

export function getProjetoById(id: string): Projeto | undefined {
  return projetos.find(p => p.id === id);
}

export function getAtividadeById(id: string): Atividade | undefined {
  return atividades.find(a => a.id === id);
}

export function getProjetosByClienteId(clienteId: string): Projeto[] {
  return projetos.filter(p => p.cliente_id === clienteId);
}

export function getAtividadesByProjetoId(projetoId: string): Atividade[] {
  return atividades.filter(a => a.projeto_id === projetoId);
}

// ==================== VIEWS SIMULADAS ====================

export function getProjetosComClientes(): ProjetoComCliente[] {
  return projetos.map(projeto => {
    const cliente = projeto.cliente_id ? getClienteById(projeto.cliente_id) : null;
    const hoje = new Date();
    let situacao_prazo: ProjetoComCliente['situacao_prazo'] = 'No prazo';
    let dias_restantes: number | null = null;

    if (projeto.data_fim && projeto.status !== 'Concluído') {
      const diffTime = projeto.data_fim.getTime() - hoje.getTime();
      dias_restantes = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      if (projeto.data_fim < hoje) {
        situacao_prazo = 'Atrasado';
      } else if (dias_restantes <= 2) {
        situacao_prazo = 'Urgente';
      } else if (dias_restantes <= 5) {
        situacao_prazo = 'Próximo ao prazo';
      }
    }

    return {
      ...projeto,
      cliente_nome: cliente?.nome || null,
      cliente_email: cliente?.email || null,
      cliente_telefone: cliente?.telefone || null,
      situacao_prazo,
      dias_restantes,
    };
  });
}

export function getAtividadesCompletas(): AtividadeCompleta[] {
  return atividades.map(atividade => {
    const projeto = atividade.projeto_id ? getProjetoById(atividade.projeto_id) : null;
    const cliente = projeto?.cliente_id ? getClienteById(projeto.cliente_id) : null;
    const hoje = new Date();
    let situacao: AtividadeCompleta['situacao'] = 'No prazo';

    if (atividade.data_fim && atividade.status !== 'Concluído') {
      if (atividade.data_fim < hoje) {
        situacao = 'Atrasada';
      } else if (atividade.data_fim.toDateString() === hoje.toDateString()) {
        situacao = 'Vence hoje';
      }
    }

    return {
      ...atividade,
      nome_projeto: projeto?.nome_projeto || null,
      projeto_status: projeto?.status || null,
      cliente_nome: cliente?.nome || null,
      situacao,
    };
  });
}

export function getEstatisticasClientes(): EstatisticasCliente[] {
  return clientes.map(cliente => {
    const projetosCliente = getProjetosByClienteId(cliente.id);
    
    return {
      id: cliente.id,
      nome: cliente.nome,
      email: cliente.email,
      total_projetos: projetosCliente.length,
      projetos_nao_iniciados: projetosCliente.filter(p => p.status === 'Não iniciado').length,
      projetos_em_andamento: projetosCliente.filter(p => p.status === 'Em andamento').length,
      projetos_concluidos: projetosCliente.filter(p => p.status === 'Concluído').length,
    };
  });
}

// ==================== ESTATÍSTICAS DASHBOARD ====================

export function getDashboardStats() {
  const hoje = new Date();
  const projetosComClientes = getProjetosComClientes();
  const atividadesCompletas = getAtividadesCompletas();

  return {
    total_clientes: clientes.length,
    total_projetos: projetos.length,
    projetos_ativos: projetos.filter(p => p.status === 'Em andamento').length,
    projetos_concluidos: projetos.filter(p => p.status === 'Concluído').length,
    total_atividades: atividades.length,
    atividades_pendentes: atividades.filter(a => a.status !== 'Concluído').length,
    atividades_alta_prioridade: atividades.filter(a => a.prioridade === 'Alta' && a.status !== 'Concluído').length,
    projetos_urgentes: projetosComClientes.filter(p => p.situacao_prazo === 'Urgente').length,
    projetos_atrasados: projetosComClientes.filter(p => p.situacao_prazo === 'Atrasado').length,
  };
}
