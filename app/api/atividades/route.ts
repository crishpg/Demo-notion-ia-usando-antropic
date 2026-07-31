import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/database';

export async function GET() {
  try {
    const result = await pool.query(
      `SELECT a.*, p.nome_projeto, c.nome AS cliente_nome
       FROM atividades a
       LEFT JOIN projetos p ON a.projeto_id = p.id
       LEFT JOIN clientes c ON p.cliente_id = c.id
       ORDER BY a.created_at DESC`
    );
    return NextResponse.json(result.rows);
  } catch {
    return NextResponse.json({ error: 'Erro ao buscar atividades' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const { nome, projeto_id, status, prioridade, data_inicio, data_fim } = await req.json();
    if (!nome?.trim()) {
      return NextResponse.json({ error: 'Nome é obrigatório' }, { status: 400 });
    }
    const result = await pool.query(
      `INSERT INTO atividades (nome, projeto_id, status, prioridade, data_inicio, data_fim)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [
        nome.trim(),
        projeto_id || null,
        status || 'Não iniciada',
        prioridade || null,
        data_inicio || null,
        data_fim || null,
      ]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch {
    return NextResponse.json({ error: 'Erro ao criar atividade' }, { status: 500 });
  }
}

export async function PUT(req: NextRequest) {
  try {
    const { id, nome, projeto_id, status, prioridade, data_inicio, data_fim } = await req.json();
    if (!id) return NextResponse.json({ error: 'ID obrigatório' }, { status: 400 });
    if (!nome?.trim()) return NextResponse.json({ error: 'Nome é obrigatório' }, { status: 400 });
    const result = await pool.query(
      `UPDATE atividades SET nome=$1, projeto_id=$2, status=$3, prioridade=$4, data_inicio=$5, data_fim=$6
       WHERE id=$7 RETURNING *`,
      [
        nome.trim(),
        projeto_id || null,
        status || 'Não iniciada',
        prioridade || null,
        data_inicio || null,
        data_fim || null,
        id,
      ]
    );
    if (result.rowCount === 0) return NextResponse.json({ error: 'Atividade não encontrada' }, { status: 404 });
    return NextResponse.json(result.rows[0]);
  } catch {
    return NextResponse.json({ error: 'Erro ao atualizar atividade' }, { status: 500 });
  }
}

export async function DELETE(req: NextRequest) {
  try {
    const { id } = await req.json();
    if (!id) return NextResponse.json({ error: 'ID obrigatório' }, { status: 400 });
    const result = await pool.query(`DELETE FROM atividades WHERE id=$1`, [id]);
    if (result.rowCount === 0) return NextResponse.json({ error: 'Atividade não encontrada' }, { status: 404 });
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ error: 'Erro ao excluir atividade' }, { status: 500 });
  }
}
