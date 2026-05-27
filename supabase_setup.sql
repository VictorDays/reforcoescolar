-- ============================================================
-- REFORÇO ESCOLAR - Script de criação das tabelas no Supabase
-- Execute no Supabase SQL Editor
-- ============================================================

-- TABELA: usuarios
create table if not exists public.usuarios (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  senha text not null,
  nome text not null,
  foto_url text,
  tipo text not null default 'aluno' check (tipo in ('admin','professor','aluno')),
  created_at timestamptz default now()
);

-- TABELA: professores
create table if not exists public.professores (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid references public.usuarios(id) on delete cascade,
  materias text[] default '{}',
  descricao text,
  valor_hora numeric(8,2),
  avaliacao_media numeric(3,2) default 0,
  total_avaliacoes int default 0,
  tipo_aula text default 'ambos' check (tipo_aula in ('presencial','online','ambos')),
  created_at timestamptz default now()
);

-- TABELA: alunos
create table if not exists public.alunos (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid references public.usuarios(id) on delete cascade,
  serie text,
  escola text,
  interesses text[] default '{}',
  created_at timestamptz default now()
);

-- TABELA: disciplinas
create table if not exists public.disciplinas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  descricao text,
  ativa boolean default true,
  created_at timestamptz default now()
);

-- TABELA: novidades (para o carrossel do Dashboard - criadas pelo Admin)
create table if not exists public.novidades (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  descricao text not null,
  imagem_url text,
  cor_hex bigint default 6053568,  -- 0xFF5C6BC0 em decimal
  ativa boolean default true,
  created_at timestamptz default now()
);

-- TABELA: favoritos (aluno favorita professor)
create table if not exists public.favoritos (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid references public.alunos(id) on delete cascade,
  professor_id uuid references public.professores(id) on delete cascade,
  created_at timestamptz default now(),
  unique (aluno_id, professor_id)
);

-- TABELA: solicitacoes (aluno solicita aula com professor)
create table if not exists public.solicitacoes (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid references public.alunos(id) on delete cascade,
  professor_id uuid references public.professores(id) on delete cascade,
  status text default 'pendente' check (status in ('pendente','aprovada','recusada')),
  mensagem text,
  disciplina text,
  horario_solicitado timestamptz,
  created_at timestamptz default now()
);

-- ============================================================
-- PERMISSÕES (OBRIGATÓRIO - sem isso UPDATE/DELETE não funciona)
-- ============================================================

-- Desabilitar RLS em todas as tabelas (usamos chave anon sem Supabase Auth)
alter table public.usuarios disable row level security;
alter table public.professores disable row level security;
alter table public.alunos disable row level security;
alter table public.disciplinas disable row level security;
alter table public.novidades disable row level security;
alter table public.favoritos disable row level security;
alter table public.solicitacoes disable row level security;

-- Garantir permissões completas para o role anon
grant all privileges on public.usuarios to anon;
grant all privileges on public.professores to anon;
grant all privileges on public.alunos to anon;
grant all privileges on public.disciplinas to anon;
grant all privileges on public.novidades to anon;
grant all privileges on public.favoritos to anon;
grant all privileges on public.solicitacoes to anon;

-- ============================================================
-- DADOS INICIAIS
-- ============================================================

-- Usuário admin padrão
insert into public.usuarios (email, senha, nome, tipo) values
  ('admin@reforcoescolar.com', 'admin123', 'Administrador', 'admin')
on conflict (email) do nothing;

-- Disciplinas padrão
insert into public.disciplinas (nome, descricao, ativa) values
  ('Matemática', 'Álgebra, Geometria, Cálculo', true),
  ('Português', 'Gramática, Redação, Literatura', true),
  ('Física', 'Mecânica, Eletromagnetismo, Óptica', true),
  ('Química', 'Química Orgânica, Inorgânica, Físico-química', true),
  ('História', 'História do Brasil e do Mundo', true),
  ('Biologia', 'Biologia Celular, Genética, Ecologia', true),
  ('Inglês', 'Inglês básico ao avançado', true)
on conflict do nothing;

-- Novidade de exemplo
insert into public.novidades (titulo, descricao, cor_hex, ativa) values
  ('Bem-vindo ao Reforço Escolar!', 'Encontre os melhores professores para suas dificuldades.', 6053568, true)
on conflict do nothing;
