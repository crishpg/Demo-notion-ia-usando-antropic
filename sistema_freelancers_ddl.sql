-- =====================================================
-- Sistema Para Freelancers - PostgreSQL DDL Script
-- Gerado baseado na estrutura do Notion
-- =====================================================
-- Fonte: https://app.notion.com/p/Sistema-Para-Freelancers-a4d2a76472be826bbbe28129ea70fdb5
-- Data de Geração: 2026-07-31
-- =====================================================

-- Extensão para geração de UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABELA: clientes
-- Notion Database: "Clientes"
-- Database ID: d942a764-72be-831a-81eb-0132a732e71a
-- =====================================================

CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Propriedade: "Nome" (title) do Notion
    nome VARCHAR(255) NOT NULL,
    
    -- Propriedade: "E-mail" (rich_text) do Notion
    email VARCHAR(255),
    
    -- Propriedade: "Telefone" (phone_number) do Notion
    telefone VARCHAR(20),
    
    -- Propriedade: "Instagram" (url) do Notion
    instagram VARCHAR(500),
    
    -- Propriedade: "Drive" (url) do Notion
    drive VARCHAR(500),
    
    -- Colunas de auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comentários nas colunas
COMMENT ON TABLE clientes IS 'Tabela de clientes mapeada do database "Clientes" do Notion';
COMMENT ON COLUMN clientes.id IS 'Chave primária UUID';
COMMENT ON COLUMN clientes.nome IS 'Nome do cliente - Propriedade "Nome" (title) do Notion';
COMMENT ON COLUMN clientes.email IS 'E-mail do cliente - Propriedade "E-mail" (rich_text) do Notion';
COMMENT ON COLUMN clientes.telefone IS 'Telefone do cliente - Propriedade "Telefone" (phone_number) do Notion';
COMMENT ON COLUMN clientes.instagram IS 'URL do Instagram - Propriedade "Instagram" (url) do Notion';
COMMENT ON COLUMN clientes.drive IS 'URL do Google Drive - Propriedade "Drive" (url) do Notion';
COMMENT ON COLUMN clientes.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN clientes.updated_at IS 'Data da última atualização';

-- =====================================================
-- TABELA: projetos
-- Notion Database: "Projetos"
-- Database ID: aaf2a764-72be-826b-89c1-0118af897eba
-- =====================================================

CREATE TABLE projetos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Propriedade: "Nome do Projeto" (title) do Notion
    nome_projeto VARCHAR(255) NOT NULL,
    
    -- FK para clientes - Propriedade: "Cliente" (relation) do Notion
    cliente_id UUID,
    
    -- Propriedade: "Timeline" (date) do Notion
    data_inicio DATE,
    data_fim DATE,
    
    -- Propriedade: "Status" (status) do Notion
    -- Opções: "Não iniciado", "Em andamento", "Concluído"
    status VARCHAR(50) DEFAULT 'Não iniciado',
    
    -- Propriedade: "Lançado" (checkbox) do Notion
    lancado BOOLEAN DEFAULT FALSE,
    
    -- Colunas de auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_projeto_cliente 
        FOREIGN KEY (cliente_id) 
        REFERENCES clientes(id) 
        ON DELETE SET NULL,
    
    -- Constraint para Status
    CONSTRAINT chk_projeto_status 
        CHECK (status IN ('Não iniciado', 'Em andamento', 'Concluído'))
);

-- Comentários nas colunas
COMMENT ON TABLE projetos IS 'Tabela de projetos mapeada do database "Projetos" do Notion';
COMMENT ON COLUMN projetos.id IS 'Chave primária UUID';
COMMENT ON COLUMN projetos.nome_projeto IS 'Nome do projeto - Propriedade "Nome do Projeto" (title) do Notion';
COMMENT ON COLUMN projetos.cliente_id IS 'FK para clientes - Propriedade "Cliente" (relation) do Notion';
COMMENT ON COLUMN projetos.data_inicio IS 'Data de início do projeto - Parte inicial da propriedade "Timeline" (date) do Notion';
COMMENT ON COLUMN projetos.data_fim IS 'Data de término do projeto - Parte final da propriedade "Timeline" (date) do Notion';
COMMENT ON COLUMN projetos.status IS 'Status do projeto - Propriedade "Status" (status) do Notion. Valores: Não iniciado, Em andamento, Concluído';
COMMENT ON COLUMN projetos.lancado IS 'Indica se o projeto foi lançado - Propriedade "Lançado" (checkbox) do Notion';
COMMENT ON COLUMN projetos.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN projetos.updated_at IS 'Data da última atualização';

-- =====================================================
-- TABELA: atividades
-- Notion Database: "Atividades"
-- Database ID: bf62a764-72be-83d5-8762-01b923f10c0c
-- =====================================================

CREATE TABLE atividades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Propriedade: "Nome" (title) do Notion
    nome VARCHAR(255) NOT NULL,
    
    -- FK para projetos - Propriedade: "Projetos" (relation) do Notion
    projeto_id UUID,
    
    -- Propriedade: "Status" (status) do Notion
    -- Opções: "Não iniciada", "Em andamento", "Concluído"
    status VARCHAR(50) DEFAULT 'Não iniciada',
    
    -- Propriedade: "Prioridade" (select) do Notion
    -- Opções: "Baixa", "Média", "Alta"
    prioridade VARCHAR(20),
    
    -- Propriedade: "Data inicio" (date) do Notion
    data_inicio DATE,
    
    -- Propriedade: "Data Fim" (date) do Notion
    data_fim DATE,
    
    -- Colunas de auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_atividade_projeto 
        FOREIGN KEY (projeto_id) 
        REFERENCES projetos(id) 
        ON DELETE CASCADE,
    
    -- Constraint para Status
    CONSTRAINT chk_atividade_status 
        CHECK (status IN ('Não iniciada', 'Em andamento', 'Concluído')),
    
    -- Constraint para Prioridade
    CONSTRAINT chk_atividade_prioridade 
        CHECK (prioridade IN ('Baixa', 'Média', 'Alta'))
);

-- Comentários nas colunas
COMMENT ON TABLE atividades IS 'Tabela de atividades mapeada do database "Atividades" do Notion';
COMMENT ON COLUMN atividades.id IS 'Chave primária UUID';
COMMENT ON COLUMN atividades.nome IS 'Nome da atividade - Propriedade "Nome" (title) do Notion';
COMMENT ON COLUMN atividades.projeto_id IS 'FK para projetos - Propriedade "Projetos" (relation) do Notion';
COMMENT ON COLUMN atividades.status IS 'Status da atividade - Propriedade "Status" (status) do Notion. Valores: Não iniciada, Em andamento, Concluído';
COMMENT ON COLUMN atividades.prioridade IS 'Prioridade da atividade - Propriedade "Prioridade" (select) do Notion. Valores: Baixa, Média, Alta';
COMMENT ON COLUMN atividades.data_inicio IS 'Data de início da atividade - Propriedade "Data inicio" (date) do Notion';
COMMENT ON COLUMN atividades.data_fim IS 'Data de término da atividade - Propriedade "Data Fim" (date) do Notion';
COMMENT ON COLUMN atividades.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN atividades.updated_at IS 'Data da última atualização';

-- =====================================================
-- ÍNDICES PARA OTIMIZAÇÃO DE CONSULTAS
-- =====================================================

-- Índices para clientes
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_clientes_nome ON clientes(nome);

-- Índices para projetos
CREATE INDEX idx_projetos_cliente_id ON projetos(cliente_id);
CREATE INDEX idx_projetos_status ON projetos(status);
CREATE INDEX idx_projetos_data_fim ON projetos(data_fim);

-- Índices para atividades
CREATE INDEX idx_atividades_projeto_id ON atividades(projeto_id);
CREATE INDEX idx_atividades_status ON atividades(status);
CREATE INDEX idx_atividades_prioridade ON atividades(prioridade);
CREATE INDEX idx_atividades_data_fim ON atividades(data_fim);

-- =====================================================
-- FUNÇÃO PARA ATUALIZAR AUTOMATICAMENTE updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION atualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA DE updated_at
-- =====================================================

CREATE TRIGGER trigger_clientes_updated_at
    BEFORE UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_updated_at();

CREATE TRIGGER trigger_projetos_updated_at
    BEFORE UPDATE ON projetos
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_updated_at();

CREATE TRIGGER trigger_atividades_updated_at
    BEFORE UPDATE ON atividades
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_updated_at();

-- =====================================================
-- VIEWS ÚTEIS PARA CONSULTAS
-- =====================================================

-- View: Projetos com informações de cliente
CREATE OR REPLACE VIEW vw_projetos_clientes AS
SELECT 
    p.id,
    p.nome_projeto,
    p.status,
    p.data_inicio,
    p.data_fim,
    p.lancado,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    c.telefone AS cliente_telefone,
    CASE 
        WHEN p.data_fim < CURRENT_DATE AND p.status != 'Concluído' THEN 'Atrasado'
        WHEN p.data_fim <= CURRENT_DATE + INTERVAL '2 days' AND p.status != 'Concluído' THEN 'Urgente'
        WHEN p.data_fim <= CURRENT_DATE + INTERVAL '5 days' AND p.status != 'Concluído' THEN 'Próximo ao prazo'
        ELSE 'No prazo'
    END AS situacao_prazo,
    p.data_fim - CURRENT_DATE AS dias_restantes
FROM projetos p
LEFT JOIN clientes c ON p.cliente_id = c.id;

COMMENT ON VIEW vw_projetos_clientes IS 'View com informações de projetos e seus respectivos clientes, incluindo cálculo de prazo';

-- View: Atividades com informações de projeto e cliente
CREATE OR REPLACE VIEW vw_atividades_completas AS
SELECT 
    a.id,
    a.nome AS atividade_nome,
    a.status AS atividade_status,
    a.prioridade,
    a.data_inicio,
    a.data_fim,
    p.nome_projeto,
    p.status AS projeto_status,
    c.nome AS cliente_nome,
    CASE 
        WHEN a.data_fim < CURRENT_DATE AND a.status != 'Concluído' THEN 'Atrasada'
        WHEN a.data_fim = CURRENT_DATE AND a.status != 'Concluído' THEN 'Vence hoje'
        ELSE 'No prazo'
    END AS situacao
FROM atividades a
LEFT JOIN projetos p ON a.projeto_id = p.id
LEFT JOIN clientes c ON p.cliente_id = c.id;

COMMENT ON VIEW vw_atividades_completas IS 'View com informações completas de atividades, incluindo projeto e cliente';

-- View: Estatísticas de projetos por cliente
CREATE OR REPLACE VIEW vw_estatisticas_clientes AS
SELECT 
    c.id,
    c.nome,
    c.email,
    COUNT(p.id) AS total_projetos,
    COUNT(CASE WHEN p.status = 'Não iniciado' THEN 1 END) AS projetos_nao_iniciados,
    COUNT(CASE WHEN p.status = 'Em andamento' THEN 1 END) AS projetos_em_andamento,
    COUNT(CASE WHEN p.status = 'Concluído' THEN 1 END) AS projetos_concluidos
FROM clientes c
LEFT JOIN projetos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome, c.email;

COMMENT ON VIEW vw_estatisticas_clientes IS 'View com estatísticas de projetos por cliente';

-- =====================================================
-- DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================

-- Inserir clientes de exemplo
INSERT INTO clientes (nome, email, telefone, instagram, drive) VALUES
('Cliente X', 'gabi.br1092@gmail.com', NULL, NULL, NULL),
('Cliente B', 'cristiano.crishpg@gmail.com', '55981458558', 'www.insta..', 'xxx');

-- Inserir projetos de exemplo
INSERT INTO projetos (nome_projeto, cliente_id, data_inicio, data_fim, status, lancado) VALUES
(
    'Novo Projeto', 
    (SELECT id FROM clientes WHERE email = 'gabi.br1092@gmail.com' LIMIT 1),
    '2024-03-04',
    '2024-03-31',
    'Não iniciado',
    TRUE
),
(
    'projeto teste', 
    (SELECT id FROM clientes WHERE email = 'gabi.br1092@gmail.com' LIMIT 1),
    '2024-03-07',
    NULL,
    'Em andamento',
    TRUE
);

-- Inserir atividades de exemplo
INSERT INTO atividades (nome, projeto_id, status, prioridade, data_inicio, data_fim) VALUES
(
    'Desenvolver Página',
    (SELECT id FROM projetos WHERE nome_projeto = 'Novo Projeto' LIMIT 1),
    'Não iniciada',
    NULL,
    NULL,
    NULL
),
(
    'Exemplo 1',
    (SELECT id FROM projetos WHERE nome_projeto = 'projeto teste' LIMIT 1),
    'Em andamento',
    'Alta',
    '2024-06-01',
    '2024-06-03'
);

-- =====================================================
-- FIM DO SCRIPT DDL
-- =====================================================
