import 'package:flutter_test/flutter_test.dart';
import 'package:sguard/core/utils/validators.dart';

void main() {
  group('Validators', () {
    // -------------------------------------------------------------------------
    // Required field
    // -------------------------------------------------------------------------
    group('required', () {
      test('empty string returns error', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('   '), isNotNull);
      });

      test('non-empty string returns null', () {
        expect(Validators.required('hello'), isNull);
        expect(Validators.required('  x  '), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // Email
    // -------------------------------------------------------------------------
    group('email', () {
      test('valid email returns null', () {
        expect(Validators.email('user@example.com'), isNull);
        expect(Validators.email('first.last+tag@sub.domain.org'), isNull);
      });

      test('invalid email returns error', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('missing@'), isNotNull);
        expect(Validators.email('@nodomain.com'), isNotNull);
        expect(Validators.email('spaces in@email.com'), isNotNull);
      });
    });

    // -------------------------------------------------------------------------
    // Phone
    // -------------------------------------------------------------------------
    group('phone', () {
      test('valid 10-digit number starting 6-9 returns null', () {
        expect(Validators.phone('9876543210'), isNull);
        expect(Validators.phone('6000000000'), isNull);
        expect(Validators.phone('8123456789'), isNull);
        expect(Validators.phone('7999999999'), isNull);
      });

      test('invalid phone returns error', () {
        expect(Validators.phone(''), isNotNull); // empty
        expect(Validators.phone('5876543210'), isNotNull); // starts with 5
        expect(Validators.phone('123456789'), isNotNull); // 9 digits
        expect(Validators.phone('98765432100'), isNotNull); // 11 digits
        expect(Validators.phone('abcdefghij'), isNotNull); // non-numeric
        expect(Validators.phone('0987654321'), isNotNull); // starts with 0
      });
    });

    // -------------------------------------------------------------------------
    // Password
    // -------------------------------------------------------------------------
    group('password', () {
      test('too short returns error', () {
        expect(Validators.password('Ab1!'), isNotNull); // 4 chars
        expect(Validators.password('Abcd1!'), isNotNull); // 6 chars (< 8)
      });

      test('weak password (no special char / no digit) returns error', () {
        expect(Validators.password('Abcdefgh'), isNotNull); // no digit/special
        expect(
          Validators.password('abcdefg1'),
          isNotNull,
        ); // no uppercase/special
        expect(
          Validators.password('ABCDEFG1'),
          isNotNull,
        ); // no lowercase/special
        expect(Validators.password('Abcdefg1'), isNotNull); // no special char
      });

      test('valid strong password returns null', () {
        expect(Validators.password('Abcdef1!'), isNull);
        expect(Validators.password('MyP@ssw0rd'), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // Confirm password
    // -------------------------------------------------------------------------
    group('confirmPassword', () {
      test('matching passwords returns null', () {
        expect(Validators.confirmPassword('Secret1!', 'Secret1!'), isNull);
      });

      test('mismatched passwords returns error', () {
        expect(
          Validators.confirmPassword('Secret1!', 'Different1!'),
          isNotNull,
        );
        expect(Validators.confirmPassword('Secret1!', ''), isNotNull);
        expect(Validators.confirmPassword('', 'Secret1!'), isNotNull);
      });
    });

    // -------------------------------------------------------------------------
    // Reason
    // -------------------------------------------------------------------------
    group('reason', () {
      test('too short returns error', () {
        expect(Validators.reason('Hi'), isNotNull);
        expect(Validators.reason(''), isNotNull);
      });

      test('too long returns error', () {
        // >500 characters
        expect(Validators.reason('a' * 501), isNotNull);
      });

      test('valid reason returns null', () {
        expect(Validators.reason('Going home for a family function.'), isNull);
        expect(Validators.reason('a' * 10), isNull);
        expect(Validators.reason('a' * 500), isNull);
      });
    });
  });
}
