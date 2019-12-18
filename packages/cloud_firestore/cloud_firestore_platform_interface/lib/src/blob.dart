part of cloud_firestore_platform_interface;

class Blob {
  const Blob(this.bytes);

  final Uint8List bytes;

  @override
  bool operator ==(dynamic other) =>
      other is Blob &&
      const DeepCollectionEquality().equals(other.bytes, bytes);

  @override
  int get hashCode => hashList(bytes);
}
