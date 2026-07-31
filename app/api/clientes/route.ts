import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/database';

export async function GET() {
  try {
    const result = await pool.query(
      `SELECT * FROM clientes ORDER BY nome ASC`
    );
    return NextResponse.json(result.rows);
  } catch {
    return NextResponse.json({ error: 'Erro ao buscar clientes' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const { nome, email, telefone, instagram, drive } = await req.json();
    if (!nome?.trim()) {
      return NextResponse.json({ error: 'Nome é obrigatório' }, { status: 400 });
    }
    const result = await pool.query(
      `INSERT INTO clientes (nome, email, telefone, instagram, drive)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [nome.trim(), email || null, telefone || null, instagram || null, drive || null]
    );
    return NextResponse.json(result.rows[0], { status: 201 });
  } catch {
    return NextResponse.json({ error: 'Erro ao criar cliente' }, { status: 500 });
  }
}

export async function PUT(req: NextRequest) {
  try {
    const { id, nome, email, telefone, instagram, drive } = await req.json();
    if (!id) return NextResponse.json({ error: 'ID obrigatório' }, { status: 400 });
    if (!nome?.trim()) return NextResponse.json({ error: 'Nome é obrigatório' }, { status: 400 });
    const result = await pool.query(
      `UPDATE clientes SET nome=$1, email=$2, telefone=$3, instagram=$4, drive=$5
       WHERE id=$6 RETURNING *`,
      [nome.trim(), email || null, telefone || null, instagram || null, drive || null, id]
    );
    if (result.rowCount === 0) return NextResponse.json({ error: 'Cliente não encontrado' }, { status: 404 });
    return NextResponse.json(result.rows[0]);
  } catch {
    return NextResponse.json({ error: 'Erro ao atualizar cliente' }, { status: 500 });
  }
}

export async function DELETE(req: NextRequest) {
  try {
    const { id } = await req.json();
    if (!id) return NextResponse.json({ error: 'ID obrigatório' }, { status: 400 });
    const result = await pool.query(`DELETE FROM clientes WHERE id=$1`, [id]);
    if (result.rowCount === 0) return NextResponse.json({ error: 'Cliente não encontrado' }, { status: 404 });
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ error: 'Erro ao excluir cliente' }, { status: 500 });
  }
}
