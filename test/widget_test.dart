// Pruebas básicas de Galindo Barbershop
//
// Se enfocan en utilidades del dominio que no requieren Supabase ni red.

import 'package:flutter_test/flutter_test.dart';

import 'package:galindo_barbershop/core/errors/failures.dart';
import 'package:galindo_barbershop/core/errors/result.dart';
import 'package:galindo_barbershop/core/utils/validators.dart';

void main() {
  group('Result', () {
    test('success expone valor y banderas', () {
      final result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('failure expone el error y permite fold', () {
      const failure = ValidationFailure(
        message: 'Error de prueba',
        fieldErrors: {},
      );
      final result = Result<int>.failure(failure);

      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);

      final message = result.fold(
        (f) => f.message,
        (value) => 'valor: $value',
      );

      expect(message, 'Error de prueba');
    });

    test('map transforma solo el éxito', () {
      final success = Result<int>.success(2);
      final failure = Result<int>.failure(const AuthFailure(message: 'no'));

      expect(success.map((v) => v * 3).valueOrNull, 6);
      expect(failure.map((v) => v * 3).isFailure, isTrue);
    });
  });

  group('AppValidators', () {
    test('email valida formatos correctos e incorrectos', () {
      expect(AppValidators.email('cliente@galindo.pe'), isNull);
      expect(AppValidators.email('sin-arroba'), isNotNull);
      expect(AppValidators.email(''), isNull); // required() se valida por separado
    });

    test('teléfono peruano de 9 dígitos', () {
      expect(AppValidators.phone('987654321'), isNull);
      expect(AppValidators.phone('12345'), isNotNull);
    });

    test('contraseña exige longitud mínima', () {
      expect(AppValidators.password('abc'), isNotNull);
      expect(AppValidators.password('ClaveSegura123!'), isNull);
    });
  });
}
