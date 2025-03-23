import '../steam_rcon.dart';

class RconService {
  RconClient? _client;
  String? _ip;
  int? _port;
  String? _password;

  // Verbindung aufbauen oder neu herstellen
  Future<bool> connect(String ip, int port, String password) async {
    if (_client != null && _client!.isConnected) {
      return true; // Bereits verbunden
    }

    _ip = ip;
    _port = port;
    _password = password;

    try {
      _client = RconClient(ip, port: port);
      await _client!.connect();
      final authenticated = await _client!.authenticate(password);
      if (!authenticated) {
        disconnect();
      }
      return authenticated;
    } catch (e) {
      print('❌ Verbindung fehlgeschlagen: $e');
      disconnect();
      return false;
    }
  }

  // Sicherstellen, dass die Verbindung steht, bevor ein Befehl gesendet wird
  Future<String> sendCommand(String command) async {
    if (_client == null || !_client!.isConnected) {
      print('⚠️ Verbindung nicht aktiv. Versuche Reconnect...');
      bool reconnected = await _reconnect();
      if (!reconnected) {
        return '❌ Verbindung konnte nicht wiederhergestellt werden.';
      }
    }

    try {
      final response = await _client!.sendCommand(command);
      return response;
    } catch (e) {
      print('❌ Fehler beim Senden des Befehls: $e');
      return 'Fehler beim Senden des Befehls';
    }
  }

  // Verbindung erneut aufbauen, falls sie unterbrochen wurde
  Future<bool> _reconnect() async {
    if (_ip == null || _port == null || _password == null) {
      print('❌ Keine gespeicherten Verbindungsdaten für Reconnect.');
      return false;
    }

    print('🔄 Versuche Reconnect zu $_ip:$_port ...');
    return await connect(_ip!, _port!, _password!);
  }

  // Verbindung sicher schließen
  void disconnect() {
    print('🔌 Verbindung wird getrennt.');
    _client?.disconnect();
    _client = null;
  }
}
