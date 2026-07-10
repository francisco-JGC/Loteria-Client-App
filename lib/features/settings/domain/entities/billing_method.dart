enum BillingMethod {
  bluetoothPrinter;

  String get displayName => switch (this) {
        BillingMethod.bluetoothPrinter => 'Impresora por Bluetooth',
      };

  static BillingMethod fromKey(String? key) {
    return BillingMethod.values.firstWhere(
      (m) => m.name == key,
      orElse: () => BillingMethod.bluetoothPrinter,
    );
  }
}
