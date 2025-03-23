import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'rcon_packet.dart';

class RconClient {
  Socket? _socket;
  final String host;
  final int port;
  int _packetId = 0;
  final _responseCompleters = <int, Completer<RconPacket>>{};
  final _buffer = BytesBuilder();

  RconClient(this.host, {this.port = 25575});

  bool get isConnected => _socket != null;

  Future<void> connect() async {
    print('🔄 Versuche Verbindung zu $host:$port'); // Debug-Ausgabe
    disconnect(); // Falls eine alte Verbindung existiert, vorher trennen
    try {
      _socket = await Socket.connect(host, port, timeout: Duration(seconds: 5));
      print('✅ Verbindung erfolgreich aufgebaut'); // Debug-Ausgabe

      _socket!.listen(
        _handleData,
        onError: _handleError,
        onDone: () {
          print('❌ Verbindung wurde unerwartet beendet'); // Debug-Ausgabe
          disconnect();
        },
      );
    } catch (e) {
      print('❌ Fehler beim Verbinden: $e'); // Debug-Ausgabe
    }
  }


  void _handleData(Uint8List data) {
    _buffer.add(data);

    while (true) {
      final bufferedData = _buffer.toBytes();
      if (bufferedData.length < 4) {
        return;
      }

      final packetSize = ByteData.sublistView(bufferedData).getInt32(
          0, Endian.little);
      final totalPacketSize = packetSize + 4;

      if (bufferedData.length < totalPacketSize) {
        return;
      }

      final packetData = bufferedData.sublist(0, totalPacketSize);
      final packet = RconPacket.decode(packetData);
      _buffer.clear();
      _buffer.add(bufferedData.sublist(totalPacketSize));

      if (_responseCompleters.isNotEmpty) {
        final firstCompleterKey = _responseCompleters.keys.first;
        final completer = _responseCompleters.remove(firstCompleterKey);
        completer?.complete(packet);
      }
    }
  }


  void _handleError(error) {
    for (var completer in _responseCompleters.values) {
      completer.completeError(error);
    }
    _responseCompleters.clear();
    disconnect();
  }

  Future<bool> authenticate(String password) async {
    final response = await _sendPacket(RconPacketType.auth, password);
    return response.id != -1;
  }

  Future<String> sendCommand(String command) async {
    print('📡 Sende Befehl: $command');
    if (_socket == null) {
      print('❌ Keine aktive Verbindung, sende nicht!');
      return 'Keine aktive Verbindung';
    }
    try {
      final response = await _sendPacket(RconPacketType.command, command);
      print('✅ Antwort erhalten: ${response.body}');
      return response.body;
    } catch (e) {
      print('❌ Fehler beim Senden des Befehls: $e');
      return 'Fehler beim Senden des Befehls';
    }
  }


  Future<RconPacket> _sendPacket(int type, String body) {
    if (_socket == null) {
      throw SocketException('Keine Verbindung vorhanden');
    }

    final packet = RconPacket(_packetId++, type, body);
    final completer = Completer<RconPacket>();
    _responseCompleters[packet.id] = completer;

    try {
      _socket!.add(packet.encode());
    } catch (e) {
      _responseCompleters.remove(packet.id);
      completer.completeError(e);
    }

    return completer.future.timeout(Duration(seconds: 5), onTimeout: () {
      _responseCompleters.remove(packet.id);
      throw TimeoutException('RCON Timeout');
    });
  }

  void disconnect() {
    print('🔌 Verbindung wird getrennt');
    if (_socket != null) {
      _socket!.destroy(); // Harte Trennung
      _socket = null;
      print('✅ Verbindung erfolgreich getrennt');
    }
  }

}