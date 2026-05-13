import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../app/constants.dart';
import '../models/nearby_device.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../services/achievement_service.dart';
import '../services/schedule_service.dart';
import '../services/storage_service.dart';

class ReceivedSchedule {
  final Schedule schedule;
  final List<Subject> subjects;
  final String fromDisplayName;

  const ReceivedSchedule({
    required this.schedule,
    required this.subjects,
    required this.fromDisplayName,
  });
}

class ReceivedPersona {
  final String personaId;
  final String personaName;
  final String personaEmoji;
  final String fromDisplayName;

  const ReceivedPersona({
    required this.personaId,
    required this.personaName,
    required this.personaEmoji,
    required this.fromDisplayName,
  });
}

class MeshService {
  MeshService._();
  static final MeshService instance = MeshService._();

  static const String _serviceId = 'breakcount';

  // Minimal persona display map for received-persona snackbar rendering.
  // Covers all 30 personas; emoji + name only (no tint needed here).
  static const _kPersonaDisplay = {
    'hype': ('🔥', 'Hype'), 'chill': ('😎', 'Chill'),
    'dramatic': ('🎭', 'Dramatic'), 'sarcastic': ('🙃', 'Sarcastic'),
    'ghost': ('👻', 'Ghost'), 'sage': ('🧙', 'Sage'),
    'menace': ('😈', 'Menace'), 'zen': ('🧘', 'Zen'),
    'nerd': ('🤓', 'Nerd'), 'tired': ('🥱', 'Tired'),
    'ice': ('🧊', 'Ice'), 'gremlin': ('😈', 'Gremlin'),
    'philosopher': ('🧐', 'Philosopher'), 'goblin': ('👺', 'Goblin'),
    'cloud': ('☁️', 'Cloud'), 'volcano': ('🌋', 'Volcano'),
    'sloth': ('🦥', 'Sloth'), 'storm': ('⛈️', 'Storm'),
    'sprout': ('🌱', 'Sprout'), 'moon': ('🌙', 'Moon'),
    'star': ('⭐', 'Star'), 'phoenix': ('🦅', 'Phoenix'),
    'sunflower': ('🌻', 'Sunflower'), 'jester': ('🃏', 'Jester'),
    'monk': ('☸️', 'Monk'), 'rebel': ('🤘', 'Rebel'),
    'hacker': ('💻', 'Hacker'), 'chef': ('👨‍🍳', 'Chef'),
    'pirate': ('🏴‍☠️', 'Pirate'), 'robot': ('🤖', 'Robot'),
  };

  final _devicesController =
      StreamController<List<NearbyDevice>>.broadcast();
  final _receivedController =
      StreamController<ReceivedSchedule>.broadcast();
  final _personaReceivedController =
      StreamController<ReceivedPersona>.broadcast();

  // Keyed by anonId to deduplicate the same physical device
  final Map<String, NearbyDevice> _devices = {};
  // Reverse lookup: endpointId → anonId
  final Map<String, String> _endpointToAnonId = {};
  // Cache of peer unlocks keyed by anonId (from MEET_HANDSHAKE payload).
  final Map<String, Set<String>> _peerUnlocks = {};

  final Set<String> _connectedEndpoints = {};
  final Set<String> _initiatorEndpoints = {};

  Timer? _timeoutTimer;
  bool _running = false;
  String? _cachedAnonId;

  Stream<List<NearbyDevice>> get devicesStream => _devicesController.stream;
  Stream<ReceivedSchedule> get receivedStream => _receivedController.stream;
  Stream<ReceivedPersona> get personaReceivedStream =>
      _personaReceivedController.stream;
  bool get isRunning => _running;

  /// Returns the set of achievement ids the peer with [anonId] has unlocked,
  /// or null if not yet received. Populated when MEET_HANDSHAKE arrives.
  Set<String>? peerUnlocks(String anonId) => _peerUnlocks[anonId];

  /// Clears cached peer unlocks (e.g. on stop).
  @visibleForTesting
  void resetPeerUnlocksForTests() => _peerUnlocks.clear();

  /// Persistent anonymous device ID — generated once, stored in prefs.
  String get _anonId {
    if (_cachedAnonId != null) return _cachedAnonId!;
    var id = StorageService.getString('anon_device_id');
    if (id == null || id.isEmpty) {
      final rng = Random.secure();
      final bytes = List.generate(4, (_) => rng.nextInt(256));
      id = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join()
          .substring(0, 7)
          .toUpperCase();
      StorageService.saveString('anon_device_id', id);
    }
    _cachedAnonId = id;
    return id;
  }

  /// Nickname format: "BC:Name:subjects:entries:anonId:persona"
  String get _nickname {
    final name = (StorageService.getString('display_name') ?? 'Student')
        .replaceAll(':', '');
    final subjects = ScheduleService.getSubjects().length;
    final entries = ScheduleService.getSchedule().entries.length;
    final persona =
        (StorageService.getString(StorageKeys.widgetPersona) ?? 'hype')
            .replaceAll(':', '');
    return 'BC:$name:$subjects:$entries:$_anonId:$persona';
  }

  Future<bool> start() async {
    if (_running) return true;
    try {
      _running = true;
      _devices.clear();
      _endpointToAnonId.clear();
      _connectedEndpoints.clear();
      _initiatorEndpoints.clear();

      await Nearby().startAdvertising(
        _nickname,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _handleConnectionInitiated,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnected,
        serviceId: _serviceId,
      );

      await Nearby().startDiscovery(
        _nickname,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (id, name, serviceId) {
          // Only accept BreakCount devices
          final device = NearbyDevice.fromNickname(id, name);
          if (device == null) return;

          // Deduplicate: same anonId = same physical device
          if (_devices.containsKey(device.anonId)) return;

          _devices[device.anonId] = device;
          _endpointToAnonId[id] = device.anonId;
          _emitDevices();
        },
        onEndpointLost: (id) {
          if (id == null) return;
          final anonId = _endpointToAnonId.remove(id);
          if (anonId != null) {
            _devices.remove(anonId);
            _emitDevices();
          }
        },
        serviceId: _serviceId,
      );

      _timeoutTimer = Timer(const Duration(seconds: 20), _onTimeout);
      return true;
    } catch (_) {
      _running = false;
      return false;
    }
  }

  /// Sends a [PERSONA_PAYLOAD] directly to [endpointId] — no request/response
  /// roundtrip. The peer receives it via [personaReceivedStream].
  Future<void> sharePersona(String endpointId,
      {required String personaId}) async {
    try {
      final myName =
          StorageService.getString('display_name') ?? 'Student';
      // Look up persona display info from the nickname map or fall back to id.
      final bytes = utf8.encode(jsonEncode({
        'type': 'PERSONA_PAYLOAD',
        'personaId': personaId,
        'fromDisplayName': myName,
      }));
      await Nearby().sendBytesPayload(endpointId, bytes);
    } catch (_) {}
  }

  Future<void> requestTransfer(String endpointId) async {
    try {
      _initiatorEndpoints.add(endpointId);
      _updateDevice(endpointId, NearbyDeviceStatus.connecting);
      await Nearby().requestConnection(
        _nickname,
        endpointId,
        onConnectionInitiated: _handleConnectionInitiated,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnected,
      );
    } catch (_) {
      _updateDevice(endpointId, NearbyDeviceStatus.failed);
    }
  }

  Future<void> stop() async {
    if (!_running) return; // already stopped — ignore double-calls
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _running = false;
    try {
      await Nearby().stopAdvertising();
      await Nearby().stopDiscovery();
      await Nearby().stopAllEndpoints();
    } catch (_) {}
    _devices.clear();
    _endpointToAnonId.clear();
    _connectedEndpoints.clear();
    _initiatorEndpoints.clear();
  }

  // ── Internal handlers ────────────────────────────────────────────────────

  void _handleConnectionInitiated(
      String endpointId, ConnectionInfo info) async {
    try {
      await Nearby().acceptConnection(
        endpointId,
        onPayLoadRecieved: _handlePayload,
        onPayloadTransferUpdate: (id, update) {},
      );
      _updateDevice(endpointId, NearbyDeviceStatus.connecting);
    } catch (_) {}
  }

  void _handleConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      if (_connectedEndpoints.contains(endpointId)) return;
      _connectedEndpoints.add(endpointId);
      _updateDevice(endpointId, NearbyDeviceStatus.connected);

      // Both sides send a MEET_HANDSHAKE so both devices credit the meet,
      // regardless of who initiated the connection.
      unawaited(_sendMeetHandshake(endpointId));

      if (_initiatorEndpoints.contains(endpointId)) {
        _sendRequestSchedule(endpointId);
      }
    } else {
      _updateDevice(endpointId, NearbyDeviceStatus.failed);
    }
  }

  void _handleDisconnected(String endpointId) {
    _connectedEndpoints.remove(endpointId);
    _initiatorEndpoints.remove(endpointId);
    final anonId = _endpointToAnonId.remove(endpointId);
    if (anonId != null) {
      _devices.remove(anonId);
      _emitDevices();
    }
  }

  void _handlePayload(String endpointId, Payload payload) {
    try {
      if (payload.type != PayloadType.BYTES) return;
      final bytes = payload.bytes;
      if (bytes == null) return;
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final type = json['type'] as String?;

      if (type == 'REQUEST_SCHEDULE') {
        _sendSchedulePayload(endpointId);
      } else if (type == 'SCHEDULE_PAYLOAD') {
        final scheduleJson = json['schedule'] as Map<String, dynamic>;
        final subjectsJson = json['subjects'] as List;
        final schedule = Schedule.fromJson(scheduleJson);
        final subjects = subjectsJson
            .map((s) => Subject.fromJson(s as Map<String, dynamic>))
            .toList();
        final anonId = _endpointToAnonId[endpointId];
        final device = anonId != null ? _devices[anonId] : null;
        _receivedController.add(ReceivedSchedule(
          schedule: schedule,
          subjects: subjects,
          fromDisplayName: device?.displayName ?? 'Student',
        ));
      } else if (type == 'PERSONA_PAYLOAD') {
        final pid = json['personaId'] as String? ?? 'hype';
        final fromName = json['fromDisplayName'] as String? ?? 'Student';
        // Look up display info from the bundled persona list.
        final anonId = _endpointToAnonId[endpointId];
        final device = anonId != null ? _devices[anonId] : null;
        final displayName = device?.displayName ?? fromName;
        // Resolve emoji + name from the persona id.
        final knownPersona = _kPersonaDisplay[pid];
        _personaReceivedController.add(ReceivedPersona(
          personaId: pid,
          personaName: knownPersona?.$2 ?? pid,
          personaEmoji: knownPersona?.$1 ?? '🔥',
          fromDisplayName: displayName,
        ));
      } else if (type == 'MEET_HANDSHAKE') {
        // Credit both devices with a meet. Dedupe is handled in
        // AchievementService.onMeet by anonId.
        final peerAnonId = json['anonId'] as String? ?? '';
        final peerPersona = json['persona'] as String? ?? 'hype';
        final peerUnlocksRaw = json['unlocks'] as List?;
        final peerUnlocks =
            peerUnlocksRaw?.map((e) => e.toString()).toSet() ?? <String>{};
        // Stash peer unlocks per-anonId for the Compare Achievements sheet.
        if (peerAnonId.isNotEmpty) {
          _peerUnlocks[peerAnonId] = peerUnlocks;
        }
        if (peerAnonId.isNotEmpty) {
          final myPersona =
              StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
          unawaited(AchievementService.onMeet(
            anonId: peerAnonId,
            peerPersona: peerPersona,
            myPersona: myPersona,
          ));
        }
      }
    } catch (_) {}
  }

  Future<void> _sendMeetHandshake(String endpointId) async {
    try {
      final myPersona =
          StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
      final myUnlocks =
          AchievementService.allUnlocks.map((u) => u.id).toList();
      final bytes = utf8.encode(jsonEncode({
        'type': 'MEET_HANDSHAKE',
        'anonId': _anonId,
        'persona': myPersona,
        'unlocks': myUnlocks,
      }));
      await Nearby().sendBytesPayload(endpointId, bytes);
    } catch (_) {}
  }

  Future<void> _sendRequestSchedule(String endpointId) async {
    try {
      final bytes = utf8.encode(jsonEncode({'type': 'REQUEST_SCHEDULE'}));
      await Nearby().sendBytesPayload(endpointId, bytes);
    } catch (_) {}
  }

  Future<void> _sendSchedulePayload(String endpointId) async {
    try {
      final schedule = ScheduleService.getSchedule();
      final subjects = ScheduleService.getSubjects();
      final payload = {
        'type': 'SCHEDULE_PAYLOAD',
        'schedule': schedule.toJson(),
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };
      final bytes = utf8.encode(jsonEncode(payload));
      await Nearby().sendBytesPayload(endpointId, bytes);
      // Donor-side credit: increments Echo/Mentor/Teacher ladder.
      unawaited(AchievementService.onScheduleShared());
    } catch (_) {}
  }

  void _onTimeout() {
    if (_devices.isEmpty) {
      _devicesController.addError('timeout');
    }
  }

  void _updateDevice(String endpointId, NearbyDeviceStatus status) {
    final anonId = _endpointToAnonId[endpointId];
    if (anonId != null) {
      final existing = _devices[anonId];
      if (existing != null) {
        _devices[anonId] = existing.copyWith(status: status);
        _emitDevices();
      }
    }
  }

  void _emitDevices() {
    if (!_devicesController.isClosed) {
      _devicesController.add(List.unmodifiable(_devices.values));
    }
  }
}
