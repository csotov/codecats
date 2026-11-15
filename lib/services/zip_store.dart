import 'dart:convert';
import 'dart:typed_data';

/// Minimal ZIP writer (no compression): enough for small text files such as
/// the OBI task attachment (header, base file, grader and examples).
Uint8List zipStore(Map<String, String> files) {
  final out = BytesBuilder();
  final central = BytesBuilder();
  var count = 0;
  for (final e in files.entries) {
    final name = utf8.encode(e.key);
    final data = utf8.encode(e.value);
    final crc = _crc32(data);
    final offset = out.length;
    out.add(_head(0x04034b50, name, data.length, crc, null));
    out.add(name);
    out.add(data);
    central.add(_head(0x02014b50, name, data.length, crc, offset));
    central.add(name);
    count++;
  }
  final cdOffset = out.length;
  final cd = central.toBytes();
  out.add(cd);
  final end = ByteData(22)
    ..setUint32(0, 0x06054b50, Endian.little)
    ..setUint16(8, count, Endian.little)
    ..setUint16(10, count, Endian.little)
    ..setUint32(12, cd.length, Endian.little)
    ..setUint32(16, cdOffset, Endian.little);
  out.add(end.buffer.asUint8List());
  return out.toBytes();
}

Uint8List _head(int sig, List<int> name, int size, int crc, int? offset) {
  final central = offset != null;
  final b = ByteData(central ? 46 : 30);
  var i = 0;
  void u16(int v) {
    b.setUint16(i, v, Endian.little);
    i += 2;
  }

  void u32(int v) {
    b.setUint32(i, v, Endian.little);
    i += 4;
  }

  u32(sig);
  if (central) u16(20); // version made by
  u16(20); // version needed
  u16(0x0800); // UTF-8 names
  u16(0); // stored
  u16(0); // time
  u16(0x5B21); // date: 2025-09-01
  u32(crc);
  u32(size);
  u32(size);
  u16(name.length);
  u16(0); // extra
  if (central) {
    u16(0); // comment
    u16(0); // disk
    u16(0); // internal attrs
    u32(0); // external attrs
    u32(offset);
  }
  return b.buffer.asUint8List();
}

final _table = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> data) {
  var c = 0xFFFFFFFF;
  for (final b in data) {
    c = _table[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}
