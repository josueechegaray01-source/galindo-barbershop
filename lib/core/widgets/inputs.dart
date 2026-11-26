/// Inputs personalizados - Galindo Barbershop
///
/// Campos de formulario consistentes con validación integrada.

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';


import 'package:galindo_barbershop/app/theme/theme.dart';
import 'package:galindo_barbershop/core/utils/validators.dart';
import 'package:galindo_barbershop/core/icons/galindo_icons.dart';

/// Campo de texto base con estilo Galindo
class GalindoTextField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final List<String? Function(String?)>? validators;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode autovalidateMode;
  final TextCapitalization textCapitalization;
  final InputDecoration? decoration;

  const GalindoTextField({
    super.key,
    required this.name,
    required this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.validators,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textCapitalization = TextCapitalization.none,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final combinedValidator = validators != null
        ? FormBuilderValidatorsExt.compose(validators!)
        : validator;

    return FormBuilderTextField(
      name: name,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: combinedValidator,
      onTap: onTap,
      onChanged: onChanged == null ? null : (value) => onChanged!(value ?? ''),
      onSubmitted:
          onSubmitted == null ? null : (value) => onSubmitted!(value ?? ''),
      autovalidateMode: autovalidateMode,
      textCapitalization: textCapitalization,
      decoration: decoration ??
          InputDecoration(
            labelText: label,
            hintText: hint,
            helperText: helperText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? '' : null,
          ),
      style: GalindoTypography.bodyLarge,
    );
  }
}

/// Campo de email con validación
class EmailField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final String? Function(String?)? additionalValidator;

  const EmailField({
    super.key,
    this.name = 'email',
    this.label = 'Correo electrónico',
    this.hint = 'tu@email.com',
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.additionalValidator,
  });

  @override
  Widget build(BuildContext context) {
    return GalindoTextField(
      name: name,
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      prefixIcon:
          Icon(GalindoIcons.envelope, size: GalindoSpacing.iconSizeMd),
      validator: (value) {
        final emailError = FormBuilderValidatorsExt.email()(value);
        if (emailError != null) return emailError;
        return additionalValidator?.call(value);
      },
    );
  }
}

/// Campo de contraseña con toggle de visibilidad
class PasswordField extends StatefulWidget {
  final String name;
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool isConfirm;
  final String? confirmPasswordFieldName;

  const PasswordField({
    super.key,
    this.name = 'password',
    this.label = 'Contraseña',
    this.hint = 'Mínimo 8 caracteres',
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.isConfirm = false,
    this.confirmPasswordFieldName,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.name,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      enabled: widget.enabled,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        if (widget.isConfirm) {
          return null;
        }
        return FormBuilderValidatorsExt.password()(value);
      },
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(GalindoIcons.lockSimple,
            size: GalindoSpacing.iconSizeMd),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? GalindoIcons.eyeClosed
                : GalindoIcons.eye,
            size: GalindoSpacing.iconSizeMd,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      style: GalindoTypography.bodyLarge,
    );
  }
}

/// Campo de teléfono peruano con formateo automático
class PhoneField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool required;

  const PhoneField({
    super.key,
    this.name = 'phone',
    this.label = 'Teléfono',
    this.hint = '987 654 321',
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    final validators = <String? Function(String?)>[];
    if (required)
      validators.add(FormBuilderValidatorsExt.required(fieldName: 'Teléfono'));
    validators.add(FormBuilderValidatorsExt.phone());

    return GalindoTextField(
      name: name,
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      prefixIcon:
          Icon(GalindoIcons.phone, size: GalindoSpacing.iconSizeMd),
      validators: validators,
      onChanged: (value) {
        // TODO: Implement phone formatting when Formatters is available
        // final formatted = Formatters.formatPhone(value);
      },
    );
  }
}

/// Campo de número con stepper
class NumberField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final num? min;
  final num? max;
  final int? decimals;
  final String? suffix;
  final ValueChanged<num>? onChanged;

  const NumberField({
    super.key,
    required this.name,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.min,
    this.max,
    this.decimals,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validators = <String? Function(String?)>[
      FormBuilderValidatorsExt.numeric(),
    ];
    final minVal = min;
    final maxVal = max;
    if (minVal != null) {
      validators.add(FormBuilderValidatorsExt.range(
        minVal.toDouble(),
        (maxVal ?? double.infinity).toDouble(),
      ));
    }
    if (maxVal != null) {
      validators.add(FormBuilderValidatorsExt.range(
        (minVal ?? -double.infinity).toDouble(),
        maxVal.toDouble(),
      ));
    }

    final dec = decimals;
    final suf = suffix;
    final chg = onChanged;

    return GalindoTextField(
      name: name,
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.numberWithOptions(
          decimal: dec != null && dec > 0),
      textInputAction: TextInputAction.next,
      enabled: enabled,
      prefixIcon: suf != null
          ? null
          : Icon(GalindoIcons.calculator,
              size: GalindoSpacing.iconSizeMd),
      suffixIcon: suf != null
          ? Padding(
              padding: EdgeInsets.all(GalindoSpacing.md),
              child: Text(suf!, style: GalindoTypography.bodyMedium),
            )
          : null,
      validators: validators,
      onChanged:
          chg != null ? (v) => chg!(num.tryParse(v) ?? 0) : null,
    );
  }
}

/// Campo de selección (Dropdown) personalizado
class GalindoDropdown<T> extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final bool enabled;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;
  final Widget? prefixIcon;

  const GalindoDropdown({
    super.key,
    required this.name,
    required this.label,
    this.hint,
    required this.items,
    this.initialValue,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<T>(
      name: name,
      initialValue: initialValue,
      items: items,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
      ),
      style: GalindoTypography.bodyLarge,
      dropdownColor: Theme.of(context).colorScheme.surface,
      iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
      isExpanded: true,
    );
  }
}

/// Campo de fecha con selector
class DateField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;

  const DateField({
    super.key,
    required this.name,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      controller: controller,
      focusNode: focusNode,
      readOnly: true,
      enabled: enabled,
      onTap: () async {
        if (!enabled) return;
        final picked = await showDatePicker(
          context: context,
          initialDate: firstDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2030),
          locale: const Locale('es', 'PE'),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          // TODO: Use Formatters when available
          controller?.text =
              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
          onDateSelected?.call(picked);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(GalindoIcons.calendar,
            size: GalindoSpacing.iconSizeMd),
        suffixIcon: Icon(GalindoIcons.caretDown,
            size: GalindoSpacing.iconSizeMd),
      ),
      style: GalindoTypography.bodyLarge,
      validator: (value) =>
          value == null || value.isEmpty ? 'Selecciona una fecha' : null,
    );
  }
}

/// Campo de hora con selector
class TimeField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final ValueChanged<TimeOfDay>? onTimeSelected;

  const TimeField({
    super.key,
    required this.name,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      controller: controller,
      focusNode: focusNode,
      readOnly: true,
      enabled: enabled,
      onTap: () async {
        if (!enabled) return;
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          controller?.text = picked.format(context);
          onTimeSelected?.call(picked);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(GalindoIcons.clock, size: GalindoSpacing.iconSizeMd),
        suffixIcon: Icon(GalindoIcons.caretDown,
            size: GalindoSpacing.iconSizeMd),
      ),
      style: GalindoTypography.bodyLarge,
      validator: (value) =>
          value == null || value.isEmpty ? 'Selecciona una hora' : null,
    );
  }
}
