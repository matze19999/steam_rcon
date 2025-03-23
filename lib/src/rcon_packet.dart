import 'dart:convert';
import 'dart:typed_data';

class RconPacket {
  final int id;
  final int type;
  final String body;

  RconPacket(this.id, this.type, this.body);

  Uint8List encode() {
    final bodyBytes = utf8.encode(body);
    final packetSize = 4 + 4 + bodyBytes.length + 2;
    final buffer = ByteData(4 + packetSize);
    buffer.setInt32(0, packetSize, Endian.little);
    buffer.setInt32(4, id, Endian.little);
    buffer.setInt32(8, type, Endian.little);
    buffer.buffer.asUint8List().setRange(12, 12 + bodyBytes.length, bodyBytes);
    buffer.setInt16(12 + bodyBytes.length, 0, Endian.little);
    return buffer.buffer.asUint8List();
  }

  static RconPacket decode(Uint8List data) {
    final buffer = ByteData.sublistView(data);
    final size = buffer.getInt32(0, Endian.little);
    final id = buffer.getInt32(4, Endian.little);
    final type = buffer.getInt32(8, Endian.little);
    final body = const Utf8Decoder(allowMalformed: true).convert(
      data.sublist(12, 4 + size - 2),
    );
    return RconPacket(id, type, body);
  }
}

class RconPacketType {
  static const int auth = 3;
  static const int command = 2;
}
