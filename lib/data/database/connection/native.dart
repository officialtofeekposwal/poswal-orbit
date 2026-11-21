import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

DatabaseConnection connectDatabase() {
  return DatabaseConnection(
    driftDatabase(
      name: 'poswal_orbit',
      native: const DriftNativeOptions(
        shareAcrossIsolates: true,
      ),
    ),
  );
}
