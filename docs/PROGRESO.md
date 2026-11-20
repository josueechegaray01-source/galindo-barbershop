# Progreso del Proyecto - Galindo Barbershop v1.0.0

> **Última actualización:** 2026-11-20
> **Versión objetivo:** 1.0.0
> **Estado actual:** FASE 0 - Auditoría y Planificación

---

## Resumen de Fases

| Fase | Descripción | Estado | Inicio | Fin | Evidencia |
|------|-------------|--------|--------|-----|-----------|
| **0** | Auditoría, levantamiento y plan de ejecución | 🔄 **EN PROGRESO** | 2026-11-20 | - | `docs/AUDITORIA_FASE0.md` |
| **1** | Diseño UX/UI, brand guide, wireframes, flujos | ⏳ Pendiente | - | - | `docs/BRAND_GUIDE.md`, `docs/UX_SPECIFICATION.md` |
| **2** | Backend Supabase: DB, migraciones, RLS, RPC | ⏳ Pendiente | - | - | `supabase/migrations/`, `docs/DATABASE_SCHEMA.md` |
| **3** | Base Flutter: arquitectura, tema, nav, Auth | ⏳ Pendiente | - | - | `lib/`, `docs/FLUTTER_ARCHITECTURE.md` |
| **4** | Módulos cliente: catálogo, barberos, disponibilidad | ⏳ Pendiente | - | - | `lib/features/catalog/`, `lib/features/barbers/`, `lib/features/availability/` |
| **5** | Flujo crítico: reservas, mis citas, cancelación | ⏳ Pendiente | - | - | `lib/features/bookings/`, `lib/features/my_bookings/` |
| **6** | Panel barbero/personal + panel admin | ⏳ Pendiente | - | - | `lib/features/staff_agenda/`, `lib/features/admin/` |
| **7** | Integración integral, refinamiento visual, a11y | ⏳ Pendiente | - | - | `docs/UI_QA_REPORT.md` |
| **8** | QA integral, seguridad, rendimiento, aceptación | ⏳ Pendiente | - | - | `docs/QA_TEST_RESULTS.md`, `docs/SECURITY_AUDIT.md` |
| **9** | Publicación Web (Vercel) + build Android | ⏳ Pendiente | - | - | `docs/DEPLOYMENT_WEB.md`, `docs/DEPLOYMENT_ANDROID.md` |
| **10** | Documentación final, manuales, cierre | ⏳ Pendiente | - | - | `docs/MANUAL_*.md`, `docs/ACTA_ENTREGA.md` |
| **EXTRA** | Revisión independiente final | ⏳ Pendiente | - | - | `docs/FINAL_INDEPENDENT_REVIEW.md` |

---

## Checklist de Entregables por Fase

### Fase 0 ✅ (En progreso)
- [x] Entorno Flutter/Dart/Android verificado
- [x] Conexión Supabase verificada (Proyecto: `fithxgprfwkfptgjhqcy`)
- [x] Estructura de carpetas creada
- [x] `.env` y `.env.example` creados
- [x] Logo copiado a `assets/branding/galindo_logo_original.png`
- [ ] Documento de auditoría técnica completado
- [ ] Matriz de trazabilidad inicial
- [ ] Decisiones pendientes documentadas
- [ ] Plan de ejecución por fases confirmado

### Fase 1 (Pendiente)
- [ ] Investigación visual de marca (Facebook público)
- [ ] `docs/BRAND_GUIDE.md`
- [ ] `docs/UX_SPECIFICATION.md`
- [ ] `docs/SCREEN_MAP.md`
- [ ] `docs/USER_FLOWS.md`
- [ ] Wireframes/prototipos
- [ ] Matriz pantalla-requisitos

### Fase 2 (Pendiente)
- [ ] Inspección esquema Supabase actual
- [ ] Migraciones SQL en `supabase/migrations/`
- [ ] RLS policies por tabla y rol
- [ ] Funciones RPC (get_available_slots, book_appointment, etc.)
- [ ] Seeds DEMO (identificados como ficticios)
- [ ] `docs/DATABASE_SCHEMA.md`
- [ ] `docs/RLS_MATRIX.md`
- [ ] `docs/SUPABASE_SETUP.md`

### Fase 3 (Pendiente)
- [ ] `pubspec.yaml` con dependencias estables
- [ ] Arquitectura feature-first implementada
- [ ] Riverpod + GoRouter + supabase_flutter configurados
- [ ] ThemeData según Brand Guide
- [ ] Rutas con guards por rol
- [ ] Auth completo (registro, login, logout, recovery)
- [ ] `flutter analyze` sin errores
- [ ] `flutter test` pasando
- [ ] `flutter build web --release` funcional
- [ ] `docs/FLUTTER_ARCHITECTURE.md`

### Fase 4 (Pendiente)
- [ ] Catálogo servicios (solo activos)
- [ ] Directorio barberos (solo activos + asignaciones)
- [ ] Disponibilidad (business_hours, barber_hours, blocks, citas)
- [ ] Responsive: móvil, tablet, escritorio
- [ ] Tests automatizados

### Fase 5 (Pendiente)
- [ ] Flujo reserva atómico (backend RPC)
- [ ] Concurrencia: exclusión GiST / transacción serializable
- [ ] Snapshots precio/duración
- [ ] Mis citas (filtros, detalle)
- [ ] Cancelación/reprogramación parametrizable
- [ ] Máquina de estados documentada
- [ ] Auditoría appointment_events

### Fase 6 (Pendiente)
- [ ] Agenda barbero (diaria/semanal, filtros, estados)
- [ ] Dashboard admin (conteos, agenda global)
- [ ] CRUD servicios, barberos, asignaciones
- [ ] Horarios generales/individuales, bloqueos
- [ ] Gestión usuarios operativos (flujo protegido)
- [ ] Tests por rol (RLS + backend)

### Fase 7 (Pendiente)
- [ ] Recorrido completo 3 roles
- [ ] Consistencia visual vs Brand Guide
- [ ] Logo correcto en splash, auth, headers
- [ ] Viewports: 360, 390-430, 768, 1366, 1440px
- [ ] Android: safe areas, teclado, orientación
- [ ] Accesibilidad: contraste, 48dp, semántica, focus, escala texto
- [ ] Limpieza placeholders DEMO
- [ ] `docs/UI_QA_REPORT.md`

### Fase 8 (Pendiente)
- [ ] CP-01 a CP-16 ejecutados y evidenciados
- [ ] Auditoría seguridad: RLS, GRANT, IDOR, secrets
- [ ] Rendimiento: consultas, índices, P95
- [ ] Privacidad: datos ficticios, consentimiento
- [ ] `docs/QA_TEST_PLAN.md`
- [ ] `docs/QA_TEST_RESULTS.md`
- [ ] `docs/SECURITY_AUDIT.md`
- [ ] `docs/KNOWN_ISSUES.md`

### Fase 9 (Pendiente)
- [ ] `flutter build web --release` con variables seguras
- [ ] `vercel.json` SPA routes
- [ ] Preview Vercel verificado
- [ ] Android: package name, icon, splash, versionCode
- [ ] AAB/APK release firmado (keystore en secrets)
- [ ] Tests en dispositivo físico
- [ ] `docs/DEPLOYMENT_WEB.md`
- [ ] `docs/DEPLOYMENT_ANDROID.md`
- [ ] `docs/RELEASE_NOTES_1.0.0.md`

### Fase 10 (Pendiente)
- [ ] 12 manuales en `docs/`
- [ ] `ACTA_ENTREGA.md` con checklist
- [ ] Decisiones pendientes finales documentadas
- [ ] Hashes de artefactos
- [ ] Auditoría de cierre completa

---

## Métricas de Calidad (Objetivos v1.0.0)

| Métrica | Objetivo | Actual |
|---------|----------|--------|
| `flutter analyze` | 0 errores, 0 warnings críticos | - |
| Cobertura tests unitarios | ≥ 80% | - |
| CP obligatorios (01,05,06,07,09,10) | 100% aprobados | - |
| Vulnerabilidades críticas | 0 | - |
| Secrets en repo/cliente | 0 | - |
| Build Web exitoso | ✅ | - |
| Build Android (debug) | ✅ | - |
| Build Android (release/AAB) | ✅ | - |

---

## Próximos Pasos Inmediatos

1. **Completar FASE 0**: Finalizar auditoría técnica y matriz de trazabilidad
2. **Obtener Publishable Key** de Supabase Dashboard (Settings → API)
3. **Revocar token Vercel comprometido** y generar nuevo en CI/CD secrets
4. **Iniciar FASE 1**: Investigación visual + Brand Guide + UX Spec