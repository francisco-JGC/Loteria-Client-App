import 'package:flutter_test/flutter_test.dart';
import 'package:loteria_client_app/core/errors/failures.dart';
import 'package:loteria_client_app/features/printer/data/datasources/printer_bluetooth_datasource.dart';
import 'package:loteria_client_app/features/printer/data/models/printer_device_model.dart';
import 'package:loteria_client_app/features/printer/data/repositories/printer_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock implements PrinterBluetoothDatasource {}

void main() {
  late _MockDatasource datasource;
  late PrinterRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = PrinterRepositoryImpl(datasource: datasource);
  });

  test('getPairedDevices returns Right with devices', () async {
    const devices = [
      PrinterDeviceModel(name: 'Xprinter', address: '00:11:22:33:44:55'),
    ];
    when(() => datasource.getPairedDevices()).thenAnswer((_) async => devices);

    final result = await repository.getPairedDevices();

    expect(result.isRight(), isTrue);
    result.match(
      (_) => fail('expected Right'),
      (list) => expect(list, devices),
    );
  });

  test('getPairedDevices returns UnexpectedFailure when datasource throws',
      () async {
    when(() => datasource.getPairedDevices()).thenThrow(Exception('boom'));

    final result = await repository.getPairedDevices();

    expect(result.isLeft(), isTrue);
    result.match(
      (f) => expect(f, isA<UnexpectedFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('connect returns Right(unit) on success', () async {
    when(() => datasource.connect(any())).thenAnswer((_) async {});

    final result = await repository.connect('00:11:22');

    expect(result.isRight(), isTrue);
    verify(() => datasource.connect('00:11:22')).called(1);
  });

  test('connect returns UnexpectedFailure when datasource throws', () async {
    when(() => datasource.connect(any())).thenThrow(Exception('fail'));

    final result = await repository.connect('00:11:22');

    expect(result.isLeft(), isTrue);
  });

  test('printTest returns Right(unit) on success', () async {
    when(() => datasource.printTest()).thenAnswer((_) async {});

    final result = await repository.printTest();

    expect(result.isRight(), isTrue);
    verify(() => datasource.printTest()).called(1);
  });
}
