// Driver per salvare screenshot catturati dall'integration test.
//
// Uso:
//   flutter drive \
//     --driver=test_driver/integration_driver.dart \
//     --target=integration_test/screenshot_test.dart \
//     -d <device_id>
//
// Gli screenshot vengono salvati in screenshots/raw/

import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          final dir = Directory('screenshots/raw');
          if (!dir.existsSync()) {
            dir.createSync(recursive: true);
          }
          final file = File('${dir.path}/$name.png');
          file.writeAsBytesSync(bytes);
          // ignore: avoid_print
          print('📸 Screenshot salvato: ${file.path}');
          return true;
        },
  );
}
