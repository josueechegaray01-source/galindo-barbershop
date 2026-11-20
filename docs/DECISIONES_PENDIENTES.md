# Decisiones de Negocio Pendientes - Galindo Barbershop v1.0.0

> **Importante:** Estas decisiones **DEBEN** ser confirmadas por el propietario/gerente de Galindo Barbershop **antes** de considerar la versión 1.0.0 lista para producción. Mientras no se confirmen, la aplicación usará valores DEMO claramente identificados como ficticios.

---

## Catálogo de Servicios (CRÍTICO)

| Campo | Decisión Pendiente | Valor DEMO Actual | Fuente de Confirmación |
|-------|-------------------|-------------------|------------------------|
| Servicios activos | Lista real de servicios ofrecidos | "Corte clásico", "Barba", "Corte + Barba", "Afeitado" | Propietario |
| Nombres oficiales | Nombres exactos para mostrar al cliente | Nombres genéricos | Propietario |
| Descripciones | Texto descriptivo por servicio | "Descripción pendiente" | Propietario |
| Precios (PEN/S/) | Precio final por servicio | S/ 25.00, S/ 15.00, S/ 35.00, S/ 20.00 | Propietario |
| Duración (min) | Duración real por servicio | 30, 20, 45, 25 min | Propietario |
| Servicios por barbero | Qué servicios hace cada profesional | Todos los barberos hacen todo | Propietario |

---

## Barberos / Profesionales (CRÍTICO)

| Campo | Decisión Pendiente | Valor DEMO Actual | Fuente |
|-------|-------------------|-------------------|--------|
| Nombres reales | Nombres/apellidos de barberos activos | "Juan Pérez", "Carlos López", "Miguel Torres" | Propietario |
| Teléfonos contacto | Para uso interno/operativo | Pendiente | Propietario |
| Activos/Inactivos | Quién está trabajando actualmente | Todos activos | Propietario |
| Foto/Avatar autorizado | Imagen real autorizada para app | Avatar neutro genérico | Propietario + Autorización escrita |

---

## Horarios y Disponibilidad (CRÍTICO)

| Campo | Decisión Pendiente | Valor DEMO Actual | Fuente |
|-------|-------------------|-------------------|--------|
| Horario general (semanal) | Días/horas de atención del local | Lun-Sáb 9:00-20:00, Dom cerrado | Propietario |
| Horario por barbero | Jornadas individuales (pueden diferir del general) | Igual al general | Propietario |
| Descansos fijos | Pausas almuerzo, etc. | 13:00-14:00 diario | Propietario |
| Días no laborables | Feriados, vacaciones planificadas | Ninguno configurado | Propietario |
| Intervalo de franjas (slot) | Cada cuántos minutos se ofrecen horarios (15, 20, 30?) | 30 min (configurable) | Propietario + UX |
| Antelación mínima reserva | Cuánto antes se puede reservar | 1 hora (configurable) | Propietario |
| Antelación máxima reserva | Hasta cuántos días futuro | 30 días (configurable) | Propietario |

---

## Estados de Cita y Flujo de Reserva (CRÍTICO)

| Decisión | Opciones | Valor DEMO Actual | Impacto |
|----------|----------|-------------------|---------|
| **Estado inicial al reservar** | `pendiente` (requiere confirmación admin) vs `confirmada` (bloquea directo) | `pendiente` | Define si cita bloquea disponibilidad al crearse |
| **¿Pendiente bloquea disponibilidad?** | Sí / No | Sí | Si No, doble reserva posible hasta confirmar |
| **¿Confirmada bloquea disponibilidad?** | Sí / No | Sí | Siempre Sí en DEMO |
| **Flujo confirmación** | Auto (cliente) / Manual (admin/barbero) / WhatsApp / Teléfono | Manual (admin) | Define UX y notificaciones |
| **Estados permitidos** | Subconjunto de: pendiente, confirmada, atendida, cancelada, reprogramada | Todos | Define máquina de estados |

---

## Políticas de Cancelación y Reprogramación (CRÍTICO)

| Política | Decisión Pendiente | Valor DEMO Actual | Notas |
|----------|-------------------|-------------------|-------|
| **Antelación mínima cancelación** | Ej: 2h, 4h, 24h, "hasta antes de iniciar" | 2 horas | Debe ser aprobada por negocio |
| **Antelación mínima reprogramación** | Igual o distinta a cancelación | 2 horas | |
| **Límite de cancelaciones/cliente** | Ej: máx 2 por mes, sin límite | Sin límite | |
| **Penalización / lista negra** | Sí/No, reglas | No | Fuera de alcance 1.0.0 si no se decide |
| **Quién puede cancelar** | Solo cliente / Cliente + Admin / Solo Admin | Cliente + Admin | |
| **Quién puede reprogramar** | Solo cliente / Cliente + Admin / Solo Admin | Cliente + Admin | |
| **Notificación al barbero** | Automática / Manual / No requerida | Manual (app) | Notificaciones push fuera de 1.0.0 |

---

## Datos de Cliente y Contacto

| Campo | Decisión Pendiente | Valor DEMO | Notas |
|-------|-------------------|------------|-------|
| **Campos obligatorios registro** | Nombre, email, teléfono, ¿DNI? | Nombre, email, teléfono | Mínimo necesario |
| **Verificación email** | Obligatoria / Opcional / Magic Link / OTP | OTP email (Supabase default) | Confirmar método |
| **Verificación teléfono** | SMS / WhatsApp / No requerida | No requerida | Twilio/WhAPI fuera de 1.0.0 |
| **Canal contacto principal** | Email / WhatsApp / Teléfono / App | Email + App | Para comunicaciones |
| **Consentimiento datos** | Checkbox RGPD/Ley Perú / Términos | Checkbox genérico | Revisión legal pendiente |

---

## Roles y Permisos Operativos

| Permiso | Cliente | Barbero/Personal | Administrador | Decisión Pendiente |
|---------|---------|------------------|---------------|-------------------|
| Ver catálogo | ✅ | ✅ | ✅ | - |
| Reservar cita | ✅ | ❌ | ✅ | - |
| Ver sus citas | ✅ | ❌ | ✅ | - |
| Cancelar propia cita | ✅* | ❌ | ✅ | *Sujeto a política |
| Reprogramar propia cita | ✅* | ❌ | ✅ | *Sujeto a política |
| Ver agenda asignada | ❌ | ✅ | ✅ | Qué datos de cliente ve barbero |
| Cambiar estado cita | ❌ | ✅* | ✅ | *Qué transiciones (ej: solo a "atendida") |
| Gestionar servicios | ❌ | ❌ | ✅ | - |
| Gestionar barberos | ❌ | ❌ | ✅ | - |
| Gestionar horarios | ❌ | ❌ | ✅ | - |
| Gestionar bloqueos | ❌ | ❌ | ✅ | - |
| Ver agenda global | ❌ | ❌ | ✅ | - |
| Ver historial auditoría | ❌ | ❌ | ✅ | - |
| Gestionar usuarios/roles | ❌ | ❌ | ✅* | *Flujo protegido, no CRUD público |

---

## Configuración Técnica y Despliegue

| Ítem | Decisión Pendiente | Valor Actual / Propuesta |
|------|-------------------|--------------------------|
| **Package name Android** | `com.galindobarbershop.app` / `pe.galindo.barbershop` / Otro | `com.galindobarbershop.app` (propuesto) |
| **Nombre app (launcher)** | "Galindo Barbershop" / "Galindo Barber" / Otro | "Galindo Barbershop" |
| **Dominio Web (Vercel)** | `galindobarbershop.com` / `galindo.vercel.app` / Subdominio cliente | Pendiente (requiere dominio cliente) |
| **Proyecto/Equipo Vercel** | Cuenta personal / Equipo organización / Nueva cuenta | Pendiente |
| **Método Auth principal** | Email+Password / Magic Link / OAuth (Google) / Teléfono | Email+Password (Supabase default) |
| **Zona horaria BD/App** | `America/Lima` (confirmado) | ✅ Confirmado |
| **Moneda presentación** | `PEN` / `S/` (confirmado) | ✅ Confirmado |
| **Idioma** | `es_PE` (confirmado) | ✅ Confirmado |

---

## Assets y Contenido Visual

| Asset | Requerido | Estado | Acción |
|-------|-----------|--------|--------|
| Logo original (vector/alta res) | ✅ | ✅ Tenemos `galindo_logo_original.png` (JPG) | Verificar si hay versión vectorial (SVG/AI) |
| Fotos local (sillones, espejos, estaciones) | Opcional | ❌ No autorizadas | Solicitar autorización escrita |
| Fotos trabajos de corte (portfolio) | Opcional | ❌ No autorizadas | Solicitar autorización escrita + consentimiento modelos |
| Fotos capas/productos con logo | Opcional | ❌ No autorizadas | Solicitar |
| Imágenes campañas estacionales | No (fuera 1.0.0) | - | No usar como identidad global |
| Favicon / PWA icons | ✅ | ❌ Pendiente | Generar desde logo original |
| Adaptive icon Android | ✅ | ❌ Pendiente | Generar desde logo original |

---

## Registro de Decisiones Tomadas

| Fecha | Decisión | Valor | Autorizado por | Notas |
|-------|----------|-------|----------------|-------|
| 2026-11-20 | Stack tecnológico | Flutter + Supabase + PostgreSQL + Vercel | Equipo técnico | Según expediente |
| 2026-11-20 | Proyecto Supabase | `fithxgprfwkfptgjhqcy` | Equipo técnico | URL: https://fithxgprfwkfptgjhqcy.supabase.co |
| 2026-11-20 | Zona horaria | `America/Lima` | Expediente | Confirmado |
| 2026-11-20 | Moneda | `PEN` (S/) | Expediente | Confirmado |
| 2026-11-20 | Idioma | `es_PE` | Expediente | Confirmado |
| 2026-11-20 | Plataformas objetivo | Android + Web (Flutter) | Expediente | iOS fuera de 1.0.0 |
| 2026-11-20 | Auth | Supabase Auth (Email+Password) | Expediente | Magic Link como alternativa |

---

## Plantilla para Registro Futuro

```markdown
| YYYY-MM-DD | [Descripción decisión] | [Valor elegido] | [Autorizado por: Nombre/Cargo] | [Notas/Referencia] |
```

---

> **Próximo paso:** Reunión con propietario/gerente de Galindo Barbershop para resolver las decisiones marcadas como **CRÍTICO** antes de iniciar Fase 2 (Backend) y Fase 3 (Flutter Base).