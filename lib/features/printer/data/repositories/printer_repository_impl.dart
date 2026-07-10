import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/printer_device.dart';
import '../../domain/repositories/printer_repository.dart';
import '../datasources/printer_bluetooth_datasource.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  const PrinterRepositoryImpl({required this.datasource});

  final PrinterBluetoothDatasource datasource;

  @override
  Future<Either<Failure, bool>> isBluetoothEnabled() async {
    try {
      final enabled = await datasource.isBluetoothEnabled();
      return Right(enabled);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrinterDevice>>> getPairedDevices() async {
    try {
      final devices = await datasource.getPairedDevices();
      return Right(devices);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> connect(String address) async {
    try {
      await datasource.connect(address);
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> disconnect() async {
    try {
      await datasource.disconnect();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isConnected() async {
    try {
      final connected = await datasource.isConnected();
      return Right(connected);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> printTest() async {
    try {
      await datasource.printTest();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
