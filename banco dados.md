Aja como um Engenheiro de Dados Sênior especializado em PostgreSQL. 

Sua tarefa é gerar um script SQL completo de criação de banco de dados (DDL) para um "Sistema Para Freelancers", baseado EXATAMENTE na estrutura da minha página do Notion.

1. Use a ferramenta MCP do Notion para ler a página: https://app.notion.com/p/Sistema-Para-Freelancers-a4d2a76472be826bbbe28129ea70fdb5
2. Identifique os bancos de dados (databases) "Clientes", "Projetos", "Atividades".
3. Para cada banco de dados, mapeie as propriedades (nomes e tipos: ex: Date, Select, Relation, Text) para colunas PostgreSQL apropriadas.

Regras de Geração do SQL:
- Use UUID como chave primária (PK) para todas as tabelas (ex: id UUID PRIMARY KEY DEFAULT gen_random_uuid()).
- Crie as Foreign Keys (FKs) baseadas nas relações do Notion (ex: projeto_id na tabela de atividades).
- Use CONSTRAINTS CHECK para campos de seleção do Notion (ex: status IN ('Planejamento', 'Em Progresso', 'Concluído')).
- Use DECIMAL(10,2) para valores monetários na tabela Financeiro.
- Adicione comentários (COMMENT ON COLUMN) em cada coluna mencionando qual propriedade do Notion ela representa.
- Inclua colunas de auditoria padrão: created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP e updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP.

Gere apenas o script SQL formatado e, ao final, faça um breve resumo das relações criadas.