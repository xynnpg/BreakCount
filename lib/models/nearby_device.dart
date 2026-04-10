enum NearbyDeviceStatus { discovered, connecting, connected, failed }

class NearbyDevice {
  final String endpointId;
  final String displayName;
  final int subjectCount;
  final int entryCount;
  final NearbyDeviceStatus status;
  // Internal dedup key — not shown in UI
  final String anonId;
  // Personality persona: hype | chill | dramatic | sarcastic
  final String persona;

  const NearbyDevice({
    required this.endpointId,
    required this.displayName,
    required this.subjectCount,
    required this.entryCount,
    required this.status,
    required this.anonId,
    this.persona = 'hype',
  });

  /// Parses nickname format: "BC:Name:subjects:entries:anonId[:persona]"
  /// Returns null if nickname doesn't start with "BC:" (not a BreakCount app).
  static NearbyDevice? fromNickname(String endpointId, String nickname) {
    if (!nickname.startsWith('BC:')) return null;
    try {
      final parts = nickname.split(':');
      if (parts.length >= 5) {
        final name = parts[1];
        final subjects = int.tryParse(parts[2]) ?? 0;
        final entries = int.tryParse(parts[3]) ?? 0;
        final anon = parts[4];
        final persona = parts.length >= 6 && parts[5].isNotEmpty ? parts[5] : 'hype';
        return NearbyDevice(
          endpointId: endpointId,
          displayName: name.isEmpty ? 'Student' : name,
          subjectCount: subjects,
          entryCount: entries,
          status: NearbyDeviceStatus.discovered,
          anonId: anon,
          persona: persona,
        );
      }
    } catch (_) {}
    return null;
  }

  NearbyDevice copyWith({
    String? endpointId,
    String? displayName,
    int? subjectCount,
    int? entryCount,
    NearbyDeviceStatus? status,
    String? anonId,
    String? persona,
  }) =>
      NearbyDevice(
        endpointId: endpointId ?? this.endpointId,
        displayName: displayName ?? this.displayName,
        subjectCount: subjectCount ?? this.subjectCount,
        entryCount: entryCount ?? this.entryCount,
        status: status ?? this.status,
        anonId: anonId ?? this.anonId,
        persona: persona ?? this.persona,
      );
}
