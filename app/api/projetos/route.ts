import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/database';

export async function GET() {
  try {
    const result = await pool.query(
      `SELECT p.*, c.nome AS cliente_nome
       FROM projetos p
       LEFT JOIN clientes c ON p.cliente_id = c.id
       ORDER BY p.created_at DESC`
    );
    return NextResponse.json(result.rows);
  } catch {
    return NextResponse.json({ error: 'Erro ao buscar projetos' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const { nome_projeto, cliente_id, data_inicio, data_fim, status, lancado } = await req.json();
    if (!nome_projeto?.trim()) {
      return NextResponse.json({ error: 'Nome do projeto é obrigatório' }, { status: 400 });
    }
    const result = await pool.query(
      `INSERT INTO projetos (nome_projeto, cliente_id, data_inicio, data_fim, status, lancado)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [
        nome_projeto.trim(),
        cliente_id || null,
        data_inicio || null,
        data_fim || null,
        status || 'Não iniciado',
        lancado ?? false,
      ]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch {
    return NextResponse.json({ error: 'Erro ao criar projeto' }, { status: 500 });
  }
}

export async function PUT(req: NextRequest) {
  try {
    const { id, nome_projeto, cliente_id, data_inicio, data_fim, status, lancado } = await req.json();
    if (!id) return NextResponse.json({ error: 'ID obrigatório' }, { status: 400 });
    if (!nome_projeto?.trim()) return NextResponse.json({ error: 'Nome é obrigatório' }, { status: 400 });
    const result = await pool.query(
      `UPDATE projetos SET nome_projeto=$1, cliente_id=$2, data_inicio=$3, data_fim=$4, status=$5, lancado=$6
       WHERE id=$7 RETURNING *`,
      [
        nome_projeto.trim(),
        cliente_id || null,
        data_inicio || null,
        data_fim || null,
        status || 'Não iniciado',
        lancado ?? false,
        id,
      ]
    );
    if (result.rowCount === 0) return NextResponse.json({ error: 'Projeto não encontrado' }, { status: 404 });
    return NextResponse.json(result.rows[0]);
  } catch {
    return NextResponse.json({ error: 'Erro ao atualizar projeto' }, { status: 500 });
  }
}

export async function DELETE(req: NextRequest) {
  try {
    const { id } = await req.json();
    if (!id) return NextResponse.json({ error: 'ID obrigatório' }, { status: 400 });
    const result = await pool.query(`DELETE FROM projetos WHERE id=$1`, [id]);
    if (result.rowCount === 0) return NextResponse.json({ error: 'Projeto não encontrado' }, { status: 404 });
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ error: 'Erro ao excluir projeto' }, { status: 500 });
  }
}
