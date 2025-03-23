import 'package:steam_rcon/steam_rcon.dart';

void main() async {
  final client = RconClient('127.0.0.1', port: 25575);

  await client.connect();

  final authenticated = await client.authenticate('your_rcon_password');
  if (!authenticated) {
    print('❌ Authentication failed');
    return;
  }

  final response = await client.sendCommand('status');
  print('📡 Server response: $response');

  client.disconnect();
}
