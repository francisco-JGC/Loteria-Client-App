import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/printer_device.dart';
import '../../domain/repositories/printer_repository.dart';
import 'printer_state.dart';

enum _PermissionOutcome { granted, denied, permanentlyDenied }

class PrinterController extends Notifier<PrinterState> {
  late final _repository = getIt<PrinterRepository>();

  @override
  PrinterState build() => const PrinterState.initial();

  Future<void> refresh() async {
    state = state.copyWith(
      status: PrinterStatus.loading,
      clearError: true,
      needsSettings: false,
    );

    final outcome = await _ensurePermissions();
    switch (outcome) {
      case _PermissionOutcome.permanentlyDenied:
        state = state.copyWith(
          status: PrinterStatus.error,
          errorMessage:
              'Los permisos de Bluetooth están bloqueados. Ábrelos desde Ajustes de la app.',
          needsSettings: true,
        );
        return;
      case _PermissionOutcome.denied:
        state = state.copyWith(
          status: PrinterStatus.error,
          errorMessage: 'Se requieren permisos de Bluetooth para continuar.',
        );
        return;
      case _PermissionOutcome.granted:
        break;
    }

    final btResult = await _repository.isBluetoothEnabled();
    final btEnabled = btResult.getOrElse((_) => false);

    if (!btEnabled) {
      state = state.copyWith(
        status: PrinterStatus.ready,
        bluetoothEnabled: false,
        devices: const [],
      );
      return;
    }

    final devicesResult = await _repository.getPairedDevices();
    devicesResult.match(
      (failure) => state = state.copyWith(
        status: PrinterStatus.error,
        bluetoothEnabled: true,
        errorMessage: failure.message,
      ),
      (devices) => state = state.copyWith(
        status: PrinterStatus.ready,
        bluetoothEnabled: true,
        devices: devices,
      ),
    );
  }

  Future<void> connect(PrinterDevice device) async {
    state = state.copyWith(isConnecting: true, clearError: true);
    final result = await _repository.connect(device.address);
    result.match(
      (failure) => state = state.copyWith(
        isConnecting: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isConnecting: false,
        connectedDevice: device,
      ),
    );
  }

  Future<void> disconnect() async {
    final result = await _repository.disconnect();
    result.match(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => state = state.copyWith(clearConnectedDevice: true),
    );
  }

  Future<void> printTest() async {
    state = state.copyWith(isPrinting: true, clearError: true);
    final result = await _repository.printTest();
    result.match(
      (failure) => state = state.copyWith(
        isPrinting: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(isPrinting: false),
    );
  }

  Future<void> openSystemSettings() => openAppSettings();

  Future<_PermissionOutcome> _ensurePermissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final statuses = await permissions.request();

    if (statuses.values.any((s) => s.isPermanentlyDenied)) {
      return _PermissionOutcome.permanentlyDenied;
    }

    final btScanOk =
        statuses[Permission.bluetoothScan]?.isGranted ?? false;
    final btConnectOk =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    final locationOk =
        statuses[Permission.locationWhenInUse]?.isGranted ?? false;

    final android12Plus = btScanOk && btConnectOk;
    final legacyAndroid = locationOk;

    if (android12Plus || legacyAndroid) {
      return _PermissionOutcome.granted;
    }
    return _PermissionOutcome.denied;
  }
}

final printerControllerProvider =
    NotifierProvider<PrinterController, PrinterState>(PrinterController.new);
