# Nearby / Mesh System

## Overview

BreakCount uses Android Nearby Connections (Bluetooth) for peer-to-peer features: schedule sharing, Vibe Beacon, and achievement compare.

## MeshService (`lib/services/mesh_service.dart`)

Core P2P service wrapping `nearby_connections` package.

### Discovery Flow

```
startDiscovery() → onPeerFound callback
    ↓
User taps peer card
    ↓
requestConnection() → onConnectionEstablished
    ↓
sendPayload(data) ↔ receivePayload(data)
    ↓
disconnect()
```

### Handshake Payload

JSON payload exchanged on connection:

```json
{
  "type": "handshake",
  "name": "Anonymous Student",
  "persona_id": "hype",
  "persona_emoji": "🔥",
  "subject_count": 12,
  "entry_count": 35,
  "unlocked_achievement_ids": ["streak_7", "first_exam", ...]
}
```

The `unlocked_achievement_ids` field enables peer achievement compare (added in v2.1.0).

## Features

### Schedule Copy
- Peer card shows subject/entry count
- "Copy" button pulls their schedule entries to your device
- Merge/replace dialog if you already have entries

### Vibe Beacon
- Long-press Vibe card → radar overlay
- Groups discovered peers by persona
- Real-time discovery while overlay is open

### Achievement Compare (`PeerAchievementsCompareSheet`)

Located in `lib/widgets/peer_achievements_compare_sheet.dart`.

Computes three sets from the handshake payload:
- **Both have** — intersection of unlocked IDs
- **Only mine** — IDs I have that they don't
- **Only theirs** — IDs they have that I don't

Displayed as a bottom sheet from the nearby users screen.

### Shake to Share
- `ShakeService` detects 20 m/s² threshold
- Opens share overlay when both devices shake simultaneously
- Uses same Nearby Connections infrastructure

## Privacy

- No real names exchanged (anonymous display names)
- Achievement IDs are opaque strings (no personal data)
- Opt-in via Settings → Social toggle (`vibeBeaconEnabled`)
- Bluetooth/Location permissions required
