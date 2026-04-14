-- ============================================================
-- Control Horario - Supabase Database Setup
-- Ejecuta este script en el SQL Editor de Supabase
-- ============================================================

-- ── 1. Tabla de usuarios (perfil extendido) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS public.usuarios (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT UNIQUE NOT NULL,
  nombre      TEXT NOT NULL DEFAULT '',
  apellido    TEXT NOT NULL DEFAULT '',
  rol         TEXT NOT NULL DEFAULT 'empleado' CHECK (rol IN ('empleado', 'admin')),
  departamento TEXT NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 2. Tabla de horarios ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.horarios (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id  UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  dia_semana  INTEGER NOT NULL CHECK (dia_semana BETWEEN 0 AND 6),
  hora_entrada TIME NOT NULL,
  hora_salida  TIME NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 3. Tabla de marcajes ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.marcajes (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id   UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  fecha        DATE NOT NULL,
  hora_entrada TIMESTAMPTZ,
  hora_salida  TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (usuario_id, fecha)
);

-- ── 4. Tabla de cambios de turno ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.cambios_turno (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_original_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  usuario_nuevo_id    UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  fecha_turno         DATE NOT NULL,
  estado              TEXT NOT NULL DEFAULT 'pendiente'
                        CHECK (estado IN ('pendiente', 'aceptado', 'rechazado')),
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 5. Función para crear perfil automáticamente al registrarse ───────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.usuarios (id, email, nombre, apellido, rol, departamento)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre', ''),
    COALESCE(NEW.raw_user_meta_data->>'apellido', ''),
    COALESCE(NEW.raw_user_meta_data->>'rol', 'empleado'),
    COALESCE(NEW.raw_user_meta_data->>'departamento', '')
  );
  RETURN NEW;
END;
$$;

-- Trigger que dispara la función al crear un usuario en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ── 6. Función para updated_at automático ─────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER usuarios_updated_at
  BEFORE UPDATE ON public.usuarios
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

CREATE OR REPLACE TRIGGER cambios_turno_updated_at
  BEFORE UPDATE ON public.cambios_turno
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ── 7. Row Level Security ─────────────────────────────────────────────────────

ALTER TABLE public.usuarios     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.horarios     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marcajes     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cambios_turno ENABLE ROW LEVEL SECURITY;

-- usuarios: cada usuario ve su propio perfil; admins ven todos
CREATE POLICY "usuarios_select_own"
  ON public.usuarios FOR SELECT
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM public.usuarios u
      WHERE u.id = auth.uid() AND u.rol = 'admin'
    )
  );

CREATE POLICY "usuarios_update_own"
  ON public.usuarios FOR UPDATE
  USING (auth.uid() = id);

-- horarios: solo el propio usuario
CREATE POLICY "horarios_select_own"
  ON public.horarios FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "horarios_insert_own"
  ON public.horarios FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "horarios_update_own"
  ON public.horarios FOR UPDATE
  USING (auth.uid() = usuario_id);

CREATE POLICY "horarios_delete_own"
  ON public.horarios FOR DELETE
  USING (auth.uid() = usuario_id);

-- marcajes: solo el propio usuario
CREATE POLICY "marcajes_select_own"
  ON public.marcajes FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "marcajes_insert_own"
  ON public.marcajes FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "marcajes_update_own"
  ON public.marcajes FOR UPDATE
  USING (auth.uid() = usuario_id);

-- cambios_turno: usuario origen o destino puede ver; solo origen puede insertar
CREATE POLICY "cambios_turno_select"
  ON public.cambios_turno FOR SELECT
  USING (
    auth.uid() = usuario_original_id
    OR auth.uid() = usuario_nuevo_id
  );

CREATE POLICY "cambios_turno_insert"
  ON public.cambios_turno FOR INSERT
  WITH CHECK (auth.uid() = usuario_original_id);

CREATE POLICY "cambios_turno_update"
  ON public.cambios_turno FOR UPDATE
  USING (
    auth.uid() = usuario_nuevo_id
    OR auth.uid() = usuario_original_id
  );
