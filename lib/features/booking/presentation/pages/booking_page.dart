/// Flujo de reserva: servicio → barbero → fecha y hora → confirmación.
///
/// Cableado al backend real vía BookingRepository (RPCs). Acepta
/// preselección por query params (?servicio=<id>&barbero=<id>) y conserva
/// la elección del barbero durante todos los pasos. Si el usuario no tiene
/// sesión, la selección se guarda (pendingBookingProvider) y se retoma al
/// volver del inicio de sesión.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:galindo_barbershop/app/router.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/core/utils/formatters.dart';
import 'package:galindo_barbershop/features/auth/presentation/providers/auth_provider.dart';
import 'package:galindo_barbershop/features/catalog/data/providers/public_data_providers.dart';
import 'package:galindo_barbershop/features/catalog/presentation/widgets/landing_theme.dart';
import 'package:galindo_barbershop/features/catalog/presentation/widgets/open_external.dart';
import '../../data/booking_repository.dart';

const _kGold = Color(0xFFD4A843);
const _kBg = Color(0xFF161616);
const _kCard = Color(0xFF212121);
const _kLine = Color(0x14FFFFFF);
const _kBody = Color(0xFFBDBDBD);

class BookingPage extends ConsumerStatefulWidget {
  final String? initialServiceId;
  final String? initialBarberId;

  const BookingPage({super.key, this.initialServiceId, this.initialBarberId});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  int _step = 0; // 0 servicio, 1 barbero, 2 fecha/hora, 3 confirmar, 4 éxito
  String? _serviceId;
  String? _barberId;
  DateTime? _selectedDate;
  DateTime? _selectedStart;
  final _notesCtrl = TextEditingController();
  bool _booking = false;
  bool _loadingSlots = false;
  bool _resumePending = false;
  bool _validated = false;
  BookedAppointment? _result;
  String? _slotError;
  List<BookingSlot> _slots = const [];

  static const _stepTitles = [
    'Servicio',
    'Barbero',
    'Fecha y hora',
    'Confirmar',
  ];

  @override
  void initState() {
    super.initState();
    _serviceId = widget.initialServiceId;
    _barberId = widget.initialBarberId;

    // Retomar una reserva que quedó pendiente de iniciar sesión.
    final pending = ref.read(pendingBookingProvider);
    if (pending != null) {
      _serviceId = pending.serviceId;
      _barberId = pending.barberId;
      _selectedDate = pending.startsAt;
      _selectedStart = pending.startsAt;
      _notesCtrl.text = pending.notes ?? '';
      _step = 3;
      _resumePending = true;
    } else if (_serviceId != null && _barberId != null) {
      _step = 2;
    } else if (_serviceId != null) {
      _step = 1;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─────────────────── acciones ───────────────────

  /// Un barbero realiza el servicio según barber_services. Si la tabla no
  /// es legible (vacía), se asume que todo el equipo hace todo el catálogo.
  bool _doesService(
      List<PublicBarberService>? assignments, String barberId, String serviceId) {
    if (assignments == null || assignments.isEmpty) return true;
    final hasAny = assignments.any((a) => a.barberId == barberId);
    if (!hasAny) return true;
    return assignments
        .any((a) => a.barberId == barberId && a.serviceId == serviceId);
  }

  void _pickService(PublicService s, List<PublicBarberService>? assignments) {
    setState(() {
      _serviceId = s.id;
      // Conserva al barbero elegido si realiza este servicio.
      final keeps = _barberId != null &&
          _doesService(assignments, _barberId!, s.id);
      if (!keeps) _barberId = null;
      _selectedDate = null;
      _selectedStart = null;
      _slots = const [];
      _slotError = null;
      _step = 1;
    });
  }

  void _pickBarber(PublicBarber b) {
    setState(() {
      _barberId = b.id;
      _selectedDate = null;
      _selectedStart = null;
      _slots = const [];
      _slotError = null;
      _step = 2;
    });
  }

  Future<void> _loadSlots() async {
    if (_serviceId == null || _barberId == null || _selectedDate == null) {
      return;
    }
    final serviceId = _serviceId!;
    final barberId = _barberId!;
    final date = _selectedDate!;
    setState(() {
      _loadingSlots = true;
      _slotError = null;
      _slots = const [];
    });
    try {
      final slots = await ref.read(bookingRepositoryProvider).getAvailableSlots(
            serviceId: serviceId,
            barberId: barberId,
            date: date,
          );
      if (!mounted || _serviceId != serviceId || _barberId != barberId) return;
      setState(() {
        _slots = slots;
        _loadingSlots = false;
      });
    } on BookingException catch (e) {
      if (!mounted) return;
      setState(() {
        _slotError = e.message;
        _loadingSlots = false;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_serviceId == null || _barberId == null || _selectedStart == null) {
      return;
    }
    // La reserva exige sesión: se pide antes de llamar al backend.
    if (!ref.read(isAuthenticatedProvider)) {
      _requireLogin();
      return;
    }
    setState(() => _booking = true);
    try {
      final appointment =
          await ref.read(bookingRepositoryProvider).bookAppointment(
                serviceId: _serviceId!,
                barberId: _barberId!,
                startsAt: _selectedStart!,
                notes: _notesCtrl.text,
              );
      ref.read(pendingBookingProvider.notifier).state = null;
      if (!mounted) return;
      setState(() {
        _result = appointment;
        _booking = false;
        _step = 4;
      });
    } on BookingException catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      if (e.code == 'SLOT_TAKEN' || e.code == 'SLOT_BLOCKED') {
        // El horario cambió: volver a elegir hora con la agenda refrescada.
        setState(() {
          _selectedStart = null;
          _step = 2;
        });
        await _loadSlots();
      }
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _booking = false);
      _showSnack('No se pudo completar la reserva. Inténtalo de nuevo.');
    }
  }

  /// Guarda la selección y lleva a iniciar sesión; al volver se retoma.
  void _requireLogin() {
    ref.read(pendingBookingProvider.notifier).state = PendingBooking(
          serviceId: _serviceId!,
          barberId: _barberId!,
          startsAt: _selectedStart!,
          notes: _notesCtrl.text,
        );
    final redirect = Uri.encodeComponent(AppRoutes.bookingFlow);
    context.go('${AppRoutes.login}?redirect=$redirect');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF3A2E1C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  void _validatePreselection(
      List<PublicService> services, List<PublicBarber> barbers) {
    if (_validated) return;
    _validated = true;
    final badService =
        _serviceId != null && !services.any((s) => s.id == _serviceId);
    final badBarber =
        _barberId != null && !barbers.any((b) => b.id == _barberId);
    if (!badService && !badBarber) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (badService) {
          _serviceId = null;
          _barberId = null;
          _step = 0;
        }
        if (badBarber) _barberId = null;
      });
    });
  }

  // ─────────────────── build ───────────────────

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final services = ref.watch(publicServicesProvider);
    final barbers = ref.watch(publicBarbersProvider);
    final assignments = ref.watch(barberServicesProvider);

    final serviceList = services.valueOrNull;
    final barberList = barbers.valueOrNull;
    if (serviceList != null && barberList != null) {
      _validatePreselection(serviceList, barberList);
    }

    // Reserva retomada tras iniciar sesión: confirmar automáticamente.
    if (_resumePending) {
      _resumePending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (ref.read(isAuthenticatedProvider)) {
          _confirmBooking();
        } else {
          setState(() => _step = 3);
        }
      });
    }

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _step == 4 ? null : _buildAppBar(w),
      body: _step == 4
          ? _successView(w)
          : SafeArea(
              child: Column(
                children: [
                  _stepper(w),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: w >= 900 ? 24 : 16, vertical: 22),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: AnimatedSwitcher(
                            duration: LandingStyles.motionOK(context)
                                ? const Duration(milliseconds: 220)
                                : Duration.zero,
                            child: _body(services, barbers, assignments),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(double w) {
    return AppBar(
      backgroundColor: _kBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 56,
      leading: IconButton(
        onPressed: () {
          if (_step > 0) {
            setState(() => _step--);
          } else {
            context.go(AppRoutes.landing);
          }
        },
        tooltip: 'Atrás',
        icon: const Icon(GalindoIcons.arrowLeft, color: Colors.white70, size: 20),
      ),
      title: Text('Reservar cita',
          style: GalindoTypography.titleMedium
              .copyWith(color: Colors.white, fontSize: 16)),
      centerTitle: true,
    );
  }

  Widget _stepper(double w) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        border: Border(bottom: BorderSide(color: _kLine)),
      ),
      child: w < 600 ? _stepperCompact() : _stepperFull(),
    );
  }

  /// Versión de escritorio: punto + etiqueta para cada paso.
  Widget _stepperFull() {
    return Row(
      children: [
        for (var i = 0; i < _stepTitles.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: i <= _step ? _kGold : _kLine,
              ),
            ),
          _stepDot(i),
        ],
      ],
    );
  }

  /// Versión móvil: solo el paso actual + barra de progreso (sin desbordes).
  Widget _stepperCompact() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paso ${_step + 1} de ${_stepTitles.length}',
                  style: GalindoTypography.caption
                      .copyWith(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 3),
              Text(_stepTitles[_step],
                  style: GalindoTypography.titleSmall.copyWith(
                      color: Colors.white, fontSize: 14.5)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _stepTitles.length,
                  minHeight: 3,
                  backgroundColor: Colors.white12,
                  color: _kGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepDot(int i) {
    final done = i < _step;
    final active = i == _step;
    final color = done || active ? _kGold : Colors.white38;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active
                ? _kGold.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: color, width: 1.4),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 14, color: _kGold)
                : Text('${i + 1}',
                    style: GalindoTypography.labelSmall
                        .copyWith(color: color, fontSize: 11)),
          ),
        ),
        const SizedBox(width: 6),
        Text(_stepTitles[i],
            style: GalindoTypography.labelMedium.copyWith(
              color: active ? Colors.white : Colors.white38,
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            )),
      ],
    );
  }

  Widget _body(
      AsyncValue<List<PublicService>> services,
      AsyncValue<List<PublicBarber>> barbers,
      AsyncValue<List<PublicBarberService>> assignments) {
    switch (_step) {
      case 0:
        return _stepServices(services, assignments.valueOrNull);
      case 1:
        return _stepBarbers(barbers, assignments.valueOrNull);
      case 2:
        return _stepDateTime();
      default:
        return _stepConfirm(services, barbers);
    }
  }

  // ─────────────── paso 1: servicio ───────────────

  Widget _stepServices(AsyncValue<List<PublicService>> services,
      List<PublicBarberService>? assignments) {
    return services.when(
      loading: () => _loading(),
      error: (_, __) => _errorPanel('No se pudo cargar el catálogo de servicios.',
          () => ref.invalidate(publicServicesProvider)),
      data: (list) => Column(
        key: const ValueKey('s0'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('¿Qué te haremos hoy?'),
          const SizedBox(height: 6),
          Text('Precio y duración reales del catálogo.',
              style: GalindoTypography.bodySmall
                  .copyWith(color: _kBody, fontSize: 12.5)),
          const SizedBox(height: 20),
          for (final s in list) ...[
            _ServiceTile(
              service: s,
              selected: _serviceId == s.id,
              onTap: () => _pickService(s, assignments),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // ─────────────── paso 2: barbero ───────────────

  Widget _stepBarbers(AsyncValue<List<PublicBarber>> barbers,
      List<PublicBarberService>? assignments) {
    return barbers.when(
      loading: () => _loading(),
      error: (_, __) => _errorPanel('No se pudo cargar el equipo de barberos.',
          () => ref.invalidate(publicBarbersProvider)),
      data: (list) {
        final serviceId = _serviceId;
        final eligible = serviceId == null
            ? list
            : list.where((b) => _doesService(assignments, b.id, serviceId)).toList();
        final shown = eligible.isEmpty ? list : eligible;
        return Column(
          key: const ValueKey('s1'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('¿Con quién quieres verte mejor?'),
            const SizedBox(height: 20),
            for (final b in shown) ...[
              _BarberTile(
                barber: b,
                selected: _barberId == b.id,
                onTap: () => _pickBarber(b),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  // ─────────────── paso 3: fecha y hora ───────────────

  Widget _stepDateTime() {
    final today = DateTime.now();
    final days = List.generate(14, (i) => DateTime(today.year, today.month, today.day + i));
    final slots = _slots;

    return Column(
      key: const ValueKey('s2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('¿Cuándo te viene bien?'),
        const SizedBox(height: 18),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = days[i];
              final selected = _sameDay(_selectedDate, d);
              return _DayChip(
                date: d,
                selected: selected,
                isToday: i == 0,
                onTap: () {
                  setState(() {
                    _selectedDate = d;
                    _selectedStart = null;
                  });
                  _loadSlots();
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        if (_selectedDate == null)
          _hint('Elige un día para ver los horarios disponibles.')
        else if (_loadingSlots)
          _loading()
        else if (_slotError != null)
          _unavailableSlots(_slotError!)
        else if (slots.isEmpty)
          _hint('Sin horarios disponibles este día. Prueba otra fecha.')
        else ...[
          Text('Toque la hora que prefieras',
              style: GalindoTypography.labelMedium
                  .copyWith(color: _kBody, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final slot in slots)
                _SlotChip(
                  label: Formatters.formatTimeShort(slot.start),
                  selected: slot.start == _selectedStart,
                  onTap: () => setState(() {
                    _selectedStart = slot.start;
                    _step = 3;
                  }),
                ),
            ],
          ),
        ],
      ],
    );
  }

  bool _sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  // ─────────────── paso 4: confirmar ───────────────

  Widget _stepConfirm(AsyncValue<List<PublicService>> services,
      AsyncValue<List<PublicBarber>> barbers) {
    final serviceId = _serviceId;
    final barberId = _barberId;
    final service = services.valueOrNull
        ?.where((s) => s.id == serviceId)
        .firstOrNull;
    final barber = barbers.valueOrNull
        ?.where((b) => b.id == barberId)
        .firstOrNull;
    final start = _selectedStart;
    final isLoggedIn = ref.watch(isAuthenticatedProvider);

    return Column(
      key: const ValueKey('s3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Confirma tu reserva'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kLine),
          ),
          child: Column(
            children: [
              _summaryRow('Servicio', service?.name ?? '—'),
              _summaryRow('Barbero', barber?.displayName ?? '—'),
              _summaryRow('Fecha',
                  start == null ? '—' : Formatters.formatDateLong(start)),
              _summaryRow(
                  'Hora', start == null ? '—' : Formatters.formatTimeShort(start)),
              if (service != null)
                _summaryRow('Precio', 'S/ ${service.price.toStringAsFixed(2)}',
                    valueColor: _kGold),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Nota para el barbero (opcional)',
            style: GalindoTypography.labelMedium
                .copyWith(color: _kBody, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          style: GalindoTypography.bodyMedium.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ej. máquina 3 en los lados, barba perfilada…',
            hintStyle:
                GalindoTypography.bodySmall.copyWith(color: Colors.white24),
            filled: true,
            fillColor: _kCard,
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: _kGold),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: (_booking || start == null) ? null : _confirmBooking,
            style: FilledButton.styleFrom(
              backgroundColor: _kGold,
              disabledBackgroundColor: _kGold.withValues(alpha: 0.4),
              disabledForegroundColor: _kBg.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _booking
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kBg))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLoggedIn) ...[
                        const Icon(GalindoIcons.user, size: 17, color: _kBg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                          isLoggedIn
                              ? 'Confirmar reserva'
                              : 'Iniciar sesión y confirmar',
                          style: GalindoTypography.labelLarge.copyWith(
                            color: _kBg,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isLoggedIn
              ? 'Tu cita queda registrada como pendiente hasta que el local la confirme.'
              : 'Para confirmar necesitamos tu cuenta: así la cita queda a tu nombre.',
          style: GalindoTypography.caption
              .copyWith(color: Colors.white38, fontSize: 11.5, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder({Color color = _kLine}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: GalindoTypography.labelMedium
                    .copyWith(color: Colors.white38, fontSize: 12.5)),
          ),
          Expanded(
            child: Text(value,
                style: GalindoTypography.labelMedium.copyWith(
                    color: valueColor ?? Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─────────────── éxito ───────────────

  Widget _successView(double w) {
    final services = ref.watch(publicServicesProvider).valueOrNull;
    final barbers = ref.watch(publicBarbersProvider).valueOrNull;
    final service =
        services?.where((s) => s.id == _serviceId).firstOrNull;
    final barber = barbers?.where((b) => b.id == _barberId).firstOrNull;
    final start = _result?.start ?? _selectedStart;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kGold.withValues(alpha: 0.12),
                    border: Border.all(color: _kGold, width: 1.6),
                  ),
                  child: const Icon(Icons.check, color: _kGold, size: 40),
                ),
                const SizedBox(height: 24),
                Text('¡Reserva registrada!',
                    textAlign: TextAlign.center,
                    style: GalindoTypography.headlineSmall
                        .copyWith(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 10),
                Text(
                  'Tu cita quedó registrada. Te esperamos en Galindo '
                  'Barbershop, Ica.',
                  textAlign: TextAlign.center,
                  style: GalindoTypography.bodyMedium.copyWith(
                      color: _kBody, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kLine),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Servicio', service?.name ?? '—'),
                      _summaryRow('Barbero', barber?.displayName ?? '—'),
                      _summaryRow(
                          'Fecha y hora',
                          start == null
                              ? '—'
                              : '${Formatters.formatDateLong(start)} · '
                                  '${Formatters.formatTimeShort(start)}'),
                      _summaryRow('Estado', 'Pendiente de confirmación'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.landing),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kGold,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Volver al inicio',
                        style: GalindoTypography.labelLarge.copyWith(
                          color: _kBg,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────── piezas comunes ───────────────

  Widget _stepTitle(String text) => Text(text,
      style: GalindoTypography.headlineSmall
          .copyWith(color: Colors.white, fontSize: 20, height: 1.25));

  Widget _loading() => const Padding(
        padding: EdgeInsets.all(28),
        child: Center(
            child: CircularProgressIndicator(color: _kGold, strokeWidth: 2)),
      );

  Widget _hint(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Text(text,
            style: GalindoTypography.bodyMedium
                .copyWith(color: _kBody, fontSize: 13, height: 1.5)),
      );

  /// Franjas no disponibles: mensaje claro y salida por Facebook.
  Widget _unavailableSlots(String message) {
    return _hint(message).withAction(
      label: 'Escribir por Facebook',
      icon: GalindoIcons.facebook,
      onTap: () => openExternal(kGalindoFacebook),
    );
  }

  Widget _errorPanel(String message, VoidCallback onRetry) {
    return _hint(message).withAction(
      label: 'Reintentar',
      icon: GalindoIcons.arrowClockwise,
      onTap: onRetry,
    );
  }
}

extension on Widget {
  /// Envuelve un panel y añade una acción debajo.
  Widget withAction(
      {required String label, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        this,
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 16),
            label: Text(label,
                style: GalindoTypography.labelLarge.copyWith(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kGold,
              side: const BorderSide(color: _kGold),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────── tiles ───────────────────

class _ServiceTile extends StatelessWidget {
  final PublicService service;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = service;
    return Material(
      color: selected ? _kGold.withValues(alpha: 0.08) : _kCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _kGold.withValues(alpha: 0.55) : _kLine,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: GalindoTypography.titleSmall
                            .copyWith(color: Colors.white, fontSize: 14.5)),
                    const SizedBox(height: 4),
                    Text(s.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GalindoTypography.bodySmall
                            .copyWith(color: _kBody, fontSize: 12, height: 1.45)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(GalindoIcons.clock, size: 12, color: _kGold),
                        const SizedBox(width: 5),
                        Text('${s.durationMin} min',
                            style: GalindoTypography.labelSmall
                                .copyWith(color: _kBody, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('S/ ${s.price.toStringAsFixed(2)}',
                      style: GalindoTypography.priceSmall
                          .copyWith(fontSize: 16, color: _kGold)),
                  const SizedBox(height: 6),
                  Icon(
                    selected ? Icons.check_circle : GalindoIcons.caretRight,
                    size: 18,
                    color: selected ? _kGold : Colors.white24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarberTile extends StatelessWidget {
  final PublicBarber barber;
  final bool selected;
  final VoidCallback onTap;

  const _BarberTile({
    required this.barber,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = barber;
    final initials =
        b.displayName.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
    return Material(
      color: selected ? _kGold.withValues(alpha: 0.08) : _kCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _kGold.withValues(alpha: 0.55) : _kLine,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A251A),
                  border: Border.all(color: _kGold.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Text(initials,
                      style: GalindoTypography.titleSmall
                          .copyWith(color: _kGold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.displayName,
                        style: GalindoTypography.titleSmall
                            .copyWith(color: Colors.white, fontSize: 14.5)),
                    const SizedBox(height: 3),
                    Text(
                      b.yearsExperience > 0
                          ? '${b.yearsExperience} ${b.yearsExperience == 1 ? 'año' : 'años'} de experiencia'
                              '${b.specialization.isEmpty ? '' : ' · ${b.specialization.take(2).join(', ')}'}'
                          : b.specialization.join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GalindoTypography.labelSmall
                          .copyWith(color: _kBody, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : GalindoIcons.caretRight,
                size: 18,
                color: selected ? _kGold : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayChip({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final wd = Formatters.formatWeekday(date);
    final label = isToday ? 'Hoy' : (wd.isNotEmpty ? wd[0].toUpperCase() + wd.substring(1) : '');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _kGold.withValues(alpha: 0.14) : _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kGold.withValues(alpha: 0.6) : _kLine,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GalindoTypography.labelSmall.copyWith(
                    color: selected ? _kGold : _kBody, fontSize: 11)),
            const SizedBox(height: 4),
            Text('${date.day}',
                style: GalindoTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _kGold : _kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? _kGold : Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(label,
            style: GalindoTypography.labelMedium.copyWith(
              color: selected ? const Color(0xFF171717) : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            )),
      ),
    );
  }
}
