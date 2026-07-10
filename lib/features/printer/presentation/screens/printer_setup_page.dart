import 'package:flutter/material.dart';

class PrinterSetupPage extends StatelessWidget {
  const PrinterSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impresora Bluetooth')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bluetooth_searching,
                  size: 80, color: Colors.black26),
              SizedBox(height: 16),
              Text(
                'Escaneo y conexión de impresora',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Próximamente',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
