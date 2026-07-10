import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/utils/currency.dart';
import '../../domain/entities/ticket_payload.dart';
import '../models/printer_device_model.dart';

abstract interface class PrinterBluetoothDatasource {
  Future<bool> isBluetoothEnabled();
  Future<List<PrinterDeviceModel>> getPairedDevices();
  Future<void> connect(String address);
  Future<void> disconnect();
  Future<bool> isConnected();
  Future<void> printTest();
  Future<void> printTicket(TicketPayload payload);
}

class PrinterBluetoothDatasourceImpl implements PrinterBluetoothDatasource {
  const PrinterBluetoothDatasourceImpl();

  @override
  Future<bool> isBluetoothEnabled() {
    return PrintBluetoothThermal.bluetoothEnabled;
  }

  @override
  Future<List<PrinterDeviceModel>> getPairedDevices() async {
    final devices = await PrintBluetoothThermal.pairedBluetooths;
    return devices
        .map((d) => PrinterDeviceModel(name: d.name, address: d.macAdress))
        .toList();
  }

  @override
  Future<void> connect(String address) async {
    final ok =
        await PrintBluetoothThermal.connect(macPrinterAddress: address);
    if (!ok) {
      throw Exception('No fue posible conectar a la impresora');
    }
  }

  @override
  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
  }

  @override
  Future<bool> isConnected() {
    return PrintBluetoothThermal.connectionStatus;
  }

  @override
  Future<void> printTest() async {
    final bytes = await _buildTestBytes();
    await _write(bytes);
  }

  @override
  Future<void> printTicket(TicketPayload payload) async {
    final bytes = await _buildTicketBytes(payload);
    await _write(bytes);
  }

  Future<void> _write(List<int> bytes) async {
    final ok = await PrintBluetoothThermal.writeBytes(bytes);
    if (!ok) {
      throw Exception('No fue posible enviar los datos a la impresora');
    }
  }

  Future<List<int>> _buildTestBytes() async {
    final profile = await CapabilityProfile.load();
    final g = Generator(PaperSize.mm58, profile);
    return [
      ...g.text(
        'LOTERIA',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      ),
      ...g.hr(),
      ...g.text(
        'Prueba de impresion',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...g.hr(),
      ...g.text('Si puedes leer esto,'),
      ...g.text('la impresora esta lista.'),
      ...g.feed(2),
      ...g.cut(),
    ];
  }

  Future<List<int>> _buildTicketBytes(TicketPayload p) async {
    final profile = await CapabilityProfile.load();
    final g = Generator(PaperSize.mm58, profile);
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final money = kAmountFormat;

    const infoStyle = PosStyles(bold: true);
    const infoRight = PosStyles(bold: true, align: PosAlign.right);
    const numberStyle = PosStyles(bold: true, height: PosTextSize.size2);
    const numberRight = PosStyles(
      bold: true,
      height: PosTextSize.size2,
      align: PosAlign.right,
    );
    PosColumn gutter() => PosColumn(text: '', width: 1);

    return [
      ...g.text(
        '  LOTERIA  ',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      ),
      ...g.text(
        '  ${p.gameName}  ',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      ...g.hr(),
      ...g.text('  Fecha: ${dateFmt.format(p.date)}', styles: infoStyle),
      ...g.text('  Folio: ${p.folio}', styles: infoStyle),
      if (p.seller != null)
        ...g.text('  Vendedor: ${p.seller}', styles: infoStyle),
      ...g.hr(),
      ...g.row([
        gutter(),
        PosColumn(text: 'No.', width: 3, styles: infoStyle),
        PosColumn(text: 'Monto', width: 3, styles: infoRight),
        PosColumn(text: 'Premio', width: 4, styles: infoRight),
        gutter(),
      ]),
      for (final line in p.lines)
        ...g.row([
          gutter(),
          PosColumn(text: line.number, width: 3, styles: numberStyle),
          PosColumn(
            text: money.format(line.amount),
            width: 3,
            styles: numberRight,
          ),
          PosColumn(
            text: money.format(line.prize),
            width: 4,
            styles: numberRight,
          ),
          gutter(),
        ]),
      ...g.hr(),
      ...g.row([
        gutter(),
        PosColumn(text: 'TOTAL', width: 5, styles: infoStyle),
        PosColumn(
          text: money.format(p.total),
          width: 5,
          styles: infoRight,
        ),
        gutter(),
      ]),
      ...g.hr(),
      ...g.feed(1),
      ...g.text(
        'Boleto valido para 1 sorteo',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      ...g.feed(1),
      ...g.text(
        'Por favor revisar su compra',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...g.text(
        'No se aceptan devoluciones',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...g.feed(1),
      ...g.qrcode(p.toQrData(), size: QRSize.size6),
      ...g.feed(1),
      ...g.text(
        'Folio: ${p.folio}',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      if (p.footer != null) ...[
        ...g.feed(1),
        ...g.text(
          '  ${p.footer}  ',
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      ],
      ...g.feed(2),
      ...g.cut(),
    ];
  }
}
