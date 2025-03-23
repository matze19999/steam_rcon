### 📄 `README.md`

```markdown
# Steam RCON 🎮

A Dart implementation of the Source RCON protocol for communicating with game servers such as those based on Source Engine or Palworld.

Supports:
✅ Authentication
✅ Sending RCON commands
✅ Automatic reconnection on network loss
✅ Live network monitoring with connectivity_plus
✅ Command retry on disconnect

---

## 🚀 Getting Started

### 📦 Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  steam-rcon: ^1.0.4
```

Or use a local path during development:

```yaml
dependencies:
  rcon:
    path: ../steam-rcon
```

Then run:

```bash
dart pub get
```

---

## 🔌 Basic Usage

```dart
import 'package:steam-rcon/rcon.dart';

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
```

---

## 📡 Features

- Handles full Source RCON protocol (ID, type, null-terminated strings)
- Automatic reconnect if connection drops
- Auto-resend of last command after reconnection
- Network change detection with `connectivity_plus`
- Typed packet decoding and encoding
- Easy-to-use API for Flutter or Dart CLI

---

## 📁 Project Structure

- `rcon_client.dart`: Manages connection, authentication, reconnection and command sending.
- `rcon_packet.dart`: Handles packet encoding/decoding according to the Valve Source RCON protocol.

---

## 🛠 Example: Using in Flutter

You can use this in a Flutter app to build an RCON admin panel. For example:

```dart
final rcon = RconClient("192.168.0.100", port: 25575);
await rcon.connect();
await rcon.authenticate("your_password");
final players = await rcon.sendCommand("ShowPlayers");
print(players);
```

---

## 📄 License

BSD 3-clause © Matthias Pröll

---

## ❤️ Contributing

Pull requests are welcome! If you want to help improve the package, feel free to fork it and send a PR.

---

## 🔗 Links

- [Source RCON Protocol Docs](https://developer.valvesoftware.com/wiki/Source_RCON_Protocol)
- [Dart SDK](https://dart.dev)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)
