/// Sección de contacto: horarios reales leídos de la base de datos,
/// ubicación por ciudad (sin dirección inventada) y canales reales.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galindo_barbershop/app/theme/typography.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';
import 'package:galindo_barbershop/features/catalog/data/providers/public_data_providers.dart';
import 'landing_theme.dart';
import 'open_external.dart';

class LandingContact extends ConsumerWidget {
  final VoidCallback onReservar;

  const LandingContact({super.key, required this.onReservar});

  static const _dayNames = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final hours = ref.watch(businessHoursProvider).valueOrNull;
    final desktop = w >= LandingBreakpoints.tablet;

    return Container(
      color: LandingStyles.bgAlt,
      padding: EdgeInsets.symmetric(vertical: 96, horizontal: hPadOf(w)),
      child: MaxWidth(
        child: Column(
          children: [
            const SectionHeader(
              kicker: 'Contacto',
              title: 'Te esperamos en Ica',
              lead: 'Agenda tu cita en línea o escríbenos por Facebook. '
                  'Los horarios que ves son los del sistema.',
            ),
            const SizedBox(height: 48),
            if (desktop)
              // IntrinsicHeight da altura acotada: permite igualar ambas tarjetas.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _hoursCard(hours)),
                    const SizedBox(width: 24),
                    Expanded(flex: 6, child: _channelsCard(w)),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _hoursCard(hours),
                  const SizedBox(height: 20),
                  _channelsCard(w),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _hoursCard(PublicBusinessHours? hours) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: LandingStyles.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LandingStyles.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(GalindoIcons.clock, size: 18, color: LandingStyles.gold),
              SizedBox(width: 10),
              Text('Horario de atención',
                  style: GalindoTypography.titleSmall),
            ],
          ),
          const SizedBox(height: 18),
          if (hours == null)
            Text('Los horarios libres se muestran al reservar tu cita.',
                style: GalindoTypography.bodySmall
                    .copyWith(color: LandingStyles.body, fontSize: 12.5))
          else
            for (var i = 1; i <= 7; i++) _hourRow(_dayNames[i - 1], hours.openRange(i % 7)),
          const Divider(color: LandingStyles.border, height: 32),
          const Row(
            children: [
              Icon(GalindoIcons.location,
                  size: 16, color: LandingStyles.gold),
              SizedBox(width: 10),
              Text('Ica, Perú',
                  style: GalindoTypography.labelMedium),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => openExternal(kGalindoFacebook),
            borderRadius: BorderRadius.circular(8),
            child: const Row(
              children: [
                Icon(GalindoIcons.facebook,
                    size: 16, color: LandingStyles.gold),
                SizedBox(width: 10),
                Text('Facebook',
                    style: GalindoTypography.labelMedium),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Claudio Galindo Barbershop',
                      style: GalindoTypography.labelMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                Icon(GalindoIcons.caretRight,
                    size: 14, color: LandingStyles.gold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hourRow(String day, (String, String)? range) {
    final open = range != null;
    final label = open ? '${_fmt(range.$1)} – ${_fmt(range.$2)}' : 'Cerrado';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(day,
                style: GalindoTypography.labelMedium.copyWith(
                  color: LandingStyles.warmWhite,
                  fontSize: 12.5,
                )),
          ),
          Expanded(
            child: Text(label,
                style: GalindoTypography.labelMedium.copyWith(
                  color: open ? LandingStyles.body : LandingStyles.muted,
                  fontSize: 12.5,
                )),
          ),
        ],
      ),
    );
  }

  String _fmt(String hhmmss) {
    final parts = hhmmss.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? parts[1] : '00';
    return '$h:${m.padLeft(2, '0')}';
  }

  Widget _channelsCard(double w) {
    return Container(
      padding: EdgeInsets.all(w >= LandingBreakpoints.tablet ? 32 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LandingStyles.gold.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF241D10), LandingStyles.bgAlt],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reserva tu cita hoy',
              style: GalindoTypography.headlineSmall.copyWith(
                color: LandingStyles.warmWhite,
                fontSize: 26,
                height: 1.2,
              )),
          const SizedBox(height: 12),
          Text(
            'Elige servicio, barbero y horario en menos de un minuto, '
            'sobre la agenda real del local.',
            style: LandingStyles.lead(w),
          ),
          const SizedBox(height: 26),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onReservar,
              icon: const Icon(GalindoIcons.calendar, size: 18),
              label: Text('Reservar cita',
                  style: GalindoTypography.labelLarge.copyWith(
                    color: LandingStyles.bg,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  )),
              style: FilledButton.styleFrom(
                backgroundColor: LandingStyles.gold,
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 26),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
