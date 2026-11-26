import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/app_version.dart';

void main() {
  group('AppVersion semantic parsing & comparison', () {
    test('beta.3 is newer than beta.2', () {
      final v2 = AppVersion.tryParse('v0.9.1-beta.2')!;
      final v3 = AppVersion.tryParse('v0.9.1-beta.3')!;
      expect(v3.isNewerThan(v2), isTrue);
      expect(v2.isNewerThan(v3), isFalse);
    });

    test('numeric pre-release segment beta.10 is newer than beta.2', () {
      final v2 = AppVersion.tryParse('v0.9.1-beta.2')!;
      final v10 = AppVersion.tryParse('v0.9.1-beta.10')!;
      expect(v10.isNewerThan(v2), isTrue);
    });

    test('stable release is newer than pre-release of same version', () {
      final beta = AppVersion.tryParse('v0.9.1-beta.2')!;
      final stable = AppVersion.tryParse('v0.9.1')!;
      expect(stable.isNewerThan(beta), isTrue);
      expect(beta.isNewerThan(stable), isFalse);
    });

    test('build number breaks tie when core and pre-release match', () {
      final b2 = AppVersion.tryParse('0.9.1-beta.2+2')!;
      final b3 = AppVersion.tryParse('0.9.1-beta.2+3')!;
      expect(b3.isNewerThan(b2), isTrue);
      expect(b2.isNewerThan(b3), isFalse);
    });

    test('higher minor or patch version wins over pre-release difference', () {
      final current = AppVersion.tryParse('0.9.1+2')!;
      final nextBeta = AppVersion.tryParse('v0.9.2-beta.1')!;
      expect(nextBeta.isNewerThan(current), isTrue);
    });
  });
}
