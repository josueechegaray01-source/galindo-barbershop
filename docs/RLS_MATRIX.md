# Matriz RLS (Row Level Security) - Galindo Barbershop v1.0.0

> **Versión:** 1.0
> **Fecha:** 2026-11-20
> **Estado:** Basado en migración 007_rls_policies.sql

---

## Resumen de Roles

| Rol | Código | Descripción |
|-----|--------|-------------|
| `client` | Cliente registrado | Reserva citas, ve sus citas, gestiona perfil |
| `barber` | Barbero/Profesional | Ve agenda asignada, actualiza estados citas propias, asistencia |
| `admin` | Administrador | Acceso completo a gestión (servicios, barberos, horarios, citas, pagos) |
| `receptionist` | Recepción | Similar a admin pero sin gestión de usuarios/roles |
| `owner` | Propietario | Acceso total + configuraciones críticas |

---

## Matriz: Tabla × Operación × Rol

### Tablas de Usuario y Perfil

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| **profiles** | | | | | |
| client | ✅ Own | ❌ | ✅ Own (no role) | ❌ | Trigger crea perfil en registro |
| barber | ✅ Own | ❌ | ✅ Own (no role) | ❌ | |
| admin | ✅ All | ❌ | ✅ All | ❌ | |
| receptionist | ✅ All | ❌ | ✅ All | ❌ | |
| owner | ✅ All | ❌ | ✅ All | ❌ | |
| **customers** | | | | | |
| client | ✅ Own | ❌ | ✅ Own | ❌ | Trigger crea en registro cliente |
| barber | ❌ | ❌ | ❌ | ❌ | |
| admin | ✅ All | ❌ | ✅ All | ❌ | |
| receptionist | ✅ All | ❌ | ✅ All | ❌ | |
| owner | ✅ All | ❌ | ✅ All | ❌ | |

### Catálogo Público (Servicios, Barberos)

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| **services** | | | | | |
| client | ✅ Active & Public | ❌ | ❌ | ❌ | Solo `is_active=true AND is_public=true` |
| barber | ✅ Active & Public | ❌ | ❌ | ❌ | |
| admin | ✅ All | ✅ | ✅ | ✅ | Soft delete via `is_active=false` |
| receptionist | ✅ All | ✅ | ✅ | ❌ | No delete |
| owner | ✅ All | ✅ | ✅ | ✅ | |
| **barbers** | | | | | |
| client | ✅ Active only | ❌ | ❌ | ❌ | Solo `is_active=true` |
| barber | ✅ Own + Active | ❌ | ✅ Own | ❌ | Ve su perfil completo |
| admin | ✅ All | ✅ | ✅ | ✅ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |
| **barber_services** | | | | | |
| client | ✅ Active assignments | ❌ | ❌ | ❌ | Solo asignaciones activas de barberos/servicios activos |
| barber | ✅ Own assignments | ❌ | ✅ Own | ❌ | |
| admin | ✅ All | ✅ | ✅ | ✅ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |

### Horarios y Disponibilidad

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| **business_hours** | | | | | |
| client | ✅ All | ❌ | ❌ | ❌ | Público para UI |
| barber | ✅ All | ❌ | ❌ | ❌ | |
| admin | ✅ All | ✅ | ✅ | ✅ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |
| **barber_hours** | | | | | |
| client | ✅ Active barbers | ❌ | ❌ | ❌ | Para cálculo disponibilidad |
| barber | ✅ Own + Active | ❌ | ✅ Own | ❌ | Gestiona su horario |
| admin | ✅ All | ✅ | ✅ | ✅ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |
| **schedule_blocks** | | | | | |
| client | ✅ Future blocks | ❌ | ❌ | ❌ | Solo bloques futuros que afectan disponibilidad |
| barber | ✅ Own + Future | ❌ | ✅ Own | ❌ | Gestiona sus bloqueos |
| admin | ✅ All | ✅ | ✅ | ✅ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |

### Citas (Núcleo - Crítico)

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| **appointments** | | | | | |
| client | ✅ Own | ✅ Own* | ✅ Own (cancel/reschedule)* | ❌ | *Vía RPC `book_appointment`, `cancel_appointment` |
| barber | ✅ Assigned | ❌ | ✅ Assigned (status)* | ❌ | *Vía RPC `update_appointment_status` (in_progress, completed, no_show) |
| admin | ✅ All | ✅ | ✅ All | ❌ | Nunca DELETE real (status=cancelled) |
| receptionist | ✅ All | ✅ | ✅ All | ❌ | |
| owner | ✅ All | ✅ | ✅ All | ❌ | |
| **appointment_events** | | | | | |
| client | ✅ Own appointments | ❌ | ❌ | ❌ | Inmutable |
| barber | ✅ Assigned appointments | ❌ | ❌ | ❌ | |
| admin | ✅ All | ❌ | ❌ | ❌ | Inmutable |
| receptionist | ✅ All | ❌ | ❌ | ❌ | |
| owner | ✅ All | ❌ | ❌ | ❌ | |
| **walk_ins** | | | | | |
| client | ❌ | ❌ | ❌ | ❌ | Cliente no ve walk-ins |
| barber | ✅ Assigned | ✅ Own | ✅ Own | ❌ | |
| admin | ✅ All | ✅ | ✅ | ❌ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |

### Pagos y Fidelización

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| **payments** | | | | | |
| client | ✅ Own | ❌ | ❌ | ❌ | |
| barber | ✅ Assigned appointments | ✅ Own | ❌ | ❌ | Barbero registra pago de sus atenciones |
| admin | ✅ All | ✅ | ✅ All | ❌ | |
| receptionist | ✅ All | ✅ | ✅ All | ❌ | |
| owner | ✅ All | ✅ | ✅ | ❌ | |
| **loyalty_programs** | | | | | |
| client | ✅ Active | ❌ | ❌ | ❌ | |
| barber | ✅ Active | ❌ | ❌ | ❌ | |
| admin | ✅ All | ✅ | ✅ | ❌ | |
| receptionist | ✅ All | ❌ | ❌ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |
| **loyalty_transactions** | | | | | |
| client | ✅ Own | ❌ | ❌ | ❌ | Inmutable |
| barber | ❌ | ❌ | ❌ | ❌ | |
| admin | ✅ All | ❌ | ❌ | ❌ | Inmutable |
| receptionist | ✅ All | ❌ | ❌ | ❌ | |
| owner | ✅ All | ❌ | ❌ | ❌ | |

### Reseñas y Notificaciones

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| **reviews** | | | | | |
| client | ✅ Public + Own | ✅ Own* | ✅ Own | ❌ | *Solo si cita completed |
| barber | ✅ Assigned | ❌ | ✅ Response only | ❌ | Solo responder |
| admin | ✅ All | ❌ | ✅ All | ❌ | Moderación |
| receptionist | ✅ All | ❌ | ✅ Response | ❌ | |
| owner | ✅ All | ❌ | ✅ All | ❌ | |
| **notifications** | | | | | |
| client | ✅ Own | ❌ | ✅ Read status | ❌ | |
| barber | ✅ Own | ❌ | ✅ Read status | ❌ | |
| admin | ✅ All | ❌ | ❌ | ❌ | Solo lectura |
| receptionist | ✅ All | ❌ | ❌ | ❌ | |
| owner | ✅ All | ❌ | ❌ | ❌ | |
| **notification_preferences** | | | | | |
| client | ✅ Own | ❌ | ✅ Own | ❌ | |
| barber | ✅ Own | ❌ | ✅ Own | ❌ | |
| admin | ✅ All | ❌ | ❌ | ❌ | |
| receptionist | ✅ All | ❌ | ❌ | ❌ | |
| owner | ✅ All | ❌ | ❌ | ❌ | |

### Operaciones y Auditoría

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| **barber_attendance** | | | | | |
| client | ❌ | ❌ | ❌ | ❌ | |
| barber | ✅ Own | ✅ Own | ✅ Own | ❌ | |
| admin | ✅ All | ✅ | ✅ | ❌ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |
| **barber_absences** | | | | | |
| client | ❌ | ❌ | ❌ | ❌ | |
| barber | ✅ Own | ✅ Own | ✅ Own | ❌ | |
| admin | ✅ All | ✅ | ✅ | ✅ | |
| receptionist | ✅ All | ✅ | ✅ | ❌ | |
| owner | ✅ All | ✅ | ✅ | ✅ | |
| **audit_logs** | | | | | |
| client | ❌ | ❌ | ❌ | ❌ | |
| barber | ❌ | ❌ | ❌ | ❌ | |
| admin | ✅ All | ❌ | ❌ | ❌ | Inmutable |
| receptionist | ✅ All | ❌ | ❌ | ❌ | |
| owner | ✅ All | ❌ | ❌ | ❌ | |
| **settings** | | | | | |
| client | ✅ is_public only | ❌ | ❌ | ❌ | Solo config públicas |
| barber | ✅ is_public only | ❌ | ❌ | ❌ | |
| admin | ✅ All | ❌ | ✅ All | ❌ | |
| receptionist | ✅ All | ❌ | ❌ | ❌ | |
| owner | ✅ All | ✅ | ✅ All | ✅ | |

---

## Validaciones de Políticas (Tests Sugeridos)

### CP-SEC-01: Cliente no ve citas de otro cliente
```sql
-- Como client A, intentar SELECT en appointments donde customer_id = client B
-- ESPERADO: 0 rows returned
```

### CP-SEC-02: Cliente no se auto-asigna rol admin
```sql
-- Como client, UPDATE profiles SET role='admin' WHERE id=auth.uid()
-- ESPERADO: Policy violation (WITH CHECK falla)
```

### CP-SEC-03: Barbero no ve citas de otro barbero
```sql
-- Como barber A, SELECT appointments WHERE barber_id = barber B
-- ESPERADO: 0 rows returned
```

### CP-SEC-04: Barbero no puede cambiar estado a 'confirmed'
```sql
-- Como barber, CALL update_appointment_status(id, 'confirmed')
-- ESPERADO: ERROR "Los barberos solo pueden cambiar a in_progress, completed, no_show"
```

### CP-SEC-05: Exclusión GiST previene doble reserva
```sql
-- Transacción 1: INSERT appointment barber=X, 10:00-10:30, status=confirmed
-- Transacción 2 (concurrente): INSERT appointment barber=X, 10:15-10:45, status=pending
-- ESPERADO: Una falla con error de exclusión
```

### CP-SEC-06: Snapshots inmutables en appointments
```sql
-- UPDATE services SET price=999 WHERE id=servicio_con_cita
-- SELECT price_snapshot FROM appointments WHERE service_id=...
-- ESPERADO: price_snapshot mantiene valor original
```

---

## GRANTs Explícitos (Complemento a RLS)

```sql
-- Roles Supabase por defecto: anon, authenticated, service_role
-- RLS maneja el acceso a nivel de fila
-- GRANTs solo para acceso a nivel de tabla (SELECT, INSERT, etc.)

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.services TO anon; -- Catálogo público
GRANT SELECT ON public.barbers TO anon;  -- Barberos activos
GRANT SELECT ON public.barber_services TO anon; -- Asignaciones activas
GRANT SELECT ON public.business_hours TO anon;

-- Authenticated (usuarios logueados)
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.customers TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.appointments TO authenticated;
GRANT SELECT ON public.appointment_events TO authenticated;
GRANT SELECT ON public.notifications TO authenticated;
GRANT SELECT, UPDATE ON public.notification_preferences TO authenticated;
-- ... etc por tabla según políticas RLS
```

---

## Checklist de Seguridad RLS

- [x] RLS habilitada en **TODAS** las tablas `public.*` (21 tablas)
- [x] Políticas `SELECT` separadas por rol
- [x] Políticas `INSERT` con `WITH CHECK` validando ownership
- [x] Políticas `UPDATE` con `USING` + `WITH CHECK` (previene IDOR/BOLA)
- [x] Políticas `DELETE` restrictivas (citas nunca se borran)
- [x] Funciones helper: `get_my_role()`, `is_staff()`, `is_barber()`, `get_my_barber_id()`, `is_my_customer()`
- [x] RPCs críticas `SECURITY DEFINER` con `search_path = public` fijo
- [x] `appointment_events` e `audit_logs` inmutables (no UPDATE/DELETE)
- [x] Snapshots en `appointments` (price, duration, names) no mutables
- [x] Exclusión GiST en `appointments` para anti-doble-reserva
- [x] `idempotency_key` UNIQUE en `appointments`
- [x] Settings `is_public` controla exposición vía API

---

## Próximos Pasos

1. **Ejecutar migraciones 001-009** en orden en Supabase SQL Editor o CLI
2. **Verificar RLS** con cuentas de prueba (client, barber, admin)
3. **Probar RPCs** `get_available_slots`, `book_appointment`, `cancel_appointment`
4. **Validar concurrencia** con pruebas de carga simultánea
5. **Auditar GRANTs** y exposición por Data API