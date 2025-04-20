import 'dart:io';
import 'dart:math';

Future<int> getAvailablePort() async {
  final random = Random();
  int port =
      random.nextInt(65535 - 1024) + 1024; // Rentang port yang valid 1024-65535

  // Cek apakah port tersedia
  bool portAvailable = await _isPortAvailable(port);

  // Jika port tidak tersedia, coba port lainnya
  while (!portAvailable) {
    port = random.nextInt(65535 - 1024) + 1024;
    portAvailable = await _isPortAvailable(port);
  }

  return port;
}

Future<bool> _isPortAvailable(int port) async {
  try {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    await server.close();
    return true; // Port tersedia
  } catch (e) {
    return false; // Port tidak tersedia
  }
}

String generateRandomString(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();

  return List.generate(length, (index) {
    return characters[random.nextInt(characters.length)];
  }).join();
}

Future<String?> getLocalIpAddress() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );
  try {
    return interfaces
        .expand((interface) => interface.addresses)
        .firstWhere((addr) => !addr.isLoopback)
        .address;
  } catch (_) {
    return "Unknown IP";
  }
}
