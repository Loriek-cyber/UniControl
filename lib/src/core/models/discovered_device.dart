class DiscoveredDevice {
  final String id;
  final String name;
  final String os;
  final String ipAddress;
  final DateTime lastSeen;

  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.os,
    required this.ipAddress,
    required this.lastSeen,
  });

  DiscoveredDevice copyWith({
    String? id,
    String? name,
    String? os,
    String? ipAddress,
    DateTime? lastSeen,
  }) {
    return DiscoveredDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      os: os ?? this.os,
      ipAddress: ipAddress ?? this.ipAddress,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
