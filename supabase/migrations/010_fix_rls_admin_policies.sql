-- ============================================================
-- Passaí — Correção Crítica de Segurança RLS
-- Migração: 010_fix_rls_admin_policies.sql
-- ============================================================
-- PROBLEMA: As políticas `admin_write_*` dão permissão ALL para
-- a role `authenticated` com condição `true`, o que significa que
-- qualquer pessoa que se cadastre no Supabase pode modificar/deletar
-- todos os dados do banco.
--
-- SOLUÇÃO: Criar tabela `profiles` com controle de role (admin/user)
-- e substituir todas as políticas de escrita por verificação de admin.
-- ============================================================

BEGIN;

-- -------------------------------------------------------------
-- 1. Tabela de perfis com controle de role
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id   UUID  NOT NULL PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  role TEXT  NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user'))
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Cada usuário lê apenas o próprio perfil
DROP POLICY IF EXISTS "leitura_proprio_perfil" ON public.profiles;
CREATE POLICY "leitura_proprio_perfil"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Apenas admins podem gerenciar perfis
DROP POLICY IF EXISTS "admin_gerencia_perfis" ON public.profiles;
CREATE POLICY "admin_gerencia_perfis"
  ON public.profiles FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- -------------------------------------------------------------
-- 2. Função auxiliar: verifica se o usuário logado é admin
--    Definida como SECURITY DEFINER para acesso seguro à tabela profiles.
-- -------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

-- -------------------------------------------------------------
-- 3. Substituir políticas de escrita inseguras nas tabelas
--    Antes: USING (true) para qualquer authenticated
--    Depois: USING (public.is_admin()) apenas para admins
-- -------------------------------------------------------------

-- Tabela: cidades
DROP POLICY IF EXISTS "admin_write_cidades"     ON public.cidades;
DROP POLICY IF EXISTS "admin_insert_cidades"    ON public.cidades;
DROP POLICY IF EXISTS "admin_update_cidades"    ON public.cidades;
DROP POLICY IF EXISTS "admin_delete_cidades"    ON public.cidades;

CREATE POLICY "admin_write_cidades"
  ON public.cidades FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Tabela: rotas
DROP POLICY IF EXISTS "admin_write_rotas"       ON public.rotas;
DROP POLICY IF EXISTS "admin_insert_rotas"      ON public.rotas;
DROP POLICY IF EXISTS "admin_update_rotas"      ON public.rotas;
DROP POLICY IF EXISTS "admin_delete_rotas"      ON public.rotas;

CREATE POLICY "admin_write_rotas"
  ON public.rotas FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Tabela: horarios
DROP POLICY IF EXISTS "admin_write_horarios"    ON public.horarios;
DROP POLICY IF EXISTS "admin_insert_horarios"   ON public.horarios;
DROP POLICY IF EXISTS "admin_update_horarios"   ON public.horarios;
DROP POLICY IF EXISTS "admin_delete_horarios"   ON public.horarios;

CREATE POLICY "admin_write_horarios"
  ON public.horarios FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Tabela: alteracoes_horario
DROP POLICY IF EXISTS "admin_write_alteracoes"  ON public.alteracoes_horario;
DROP POLICY IF EXISTS "admin_insert_alteracoes" ON public.alteracoes_horario;
DROP POLICY IF EXISTS "admin_update_alteracoes" ON public.alteracoes_horario;
DROP POLICY IF EXISTS "admin_delete_alteracoes" ON public.alteracoes_horario;

CREATE POLICY "admin_write_alteracoes"
  ON public.alteracoes_horario FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Tabela: paradas_rota (criada na migration 009)
DROP POLICY IF EXISTS "admin_write_paradas"     ON public.paradas_rota;

CREATE POLICY "admin_write_paradas"
  ON public.paradas_rota FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- -------------------------------------------------------------
-- 4. Promover o usuário admin existente
--    Substitua o e-mail abaixo pelo seu e-mail cadastrado no Supabase.
--    Se ainda não tiver usuário, crie um em Authentication > Users
--    e execute o UPDATE abaixo manualmente com o UUID correto.
-- -------------------------------------------------------------
INSERT INTO public.profiles (id, role)
SELECT id, 'admin'
FROM auth.users
WHERE email = 'liedsoncosta.developer@gmail.com'   -- ← substitua pelo seu e-mail de admin
ON CONFLICT (id) DO UPDATE SET role = 'admin';

COMMIT;
