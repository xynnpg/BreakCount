# Nearby and Mesh System

## Overview

BreakCount uses Android Nearby Connections (Bluetooth) for peer-to-peer features: schedule sharing, the Vibe Beacon radar, and achievement compare. Everything is local — no server involved.

## MeshService (lib/services/mesh_service.dart)

Core P2P service wrapping the `nearby_connections` package.

### Discovery Flow

```
startDiscovery() → onPeerFound callback
    |
    | User taps peer card
    v
requestConnection() → onConnectionEstablished
    |
    v
sendPayload(data) <--> receivePayload(data)
    |
    v
disconnect()
```

### Handshake Payload

JSON payload exchanged on connection:

```json
{
  "type": "handshake",
  "name": "Anonymous Student",
  "persona_id": "hype",
  "persona_emoji": "fire",
  "subject_count": 12,
  "entry_count": 35,
  "unlocked_achievement_ids": ["streak_7", "first_exam", "..."]
}
```

The `unlocked_achievement_ids` field is what enables peer achievement compare, added in v2.1.0.

## Features

### Schedule Copy

The peer card shows their subject and entry count. Tapping "Copy" pulls their schedule entries to your device. If you already have entries, a merge/replace dialog appears.

### Vibe Beacon

Long-press the Vibe card on the home screen to open a radar overlay. It groups discovered peers by persona and updates in real time while the overlay is open.

### Achievement Compare (PeerAchievementsCompareSheet)

Located in `lib/widgets/peer_achievements_compare_sheet.dart`.

Computes three sets from the handshake payload:
- **Both have** — intersection of unlocked IDs
- **Only mine** — IDs I have that they don't
- **Only theirs** — IDs they have that I don't

Displayed as a bottom sheet from the nearby users screen.

### Shake to Share

`ShakeService` detects a 20 m/s² threshold on the accelerometer. When both devices shake at roughly the same time, a share overlay opens. Uses the same Nearby Connections infrastructure as everything else.

## Privacy

- No real names are exchanged — display names are anonymous
- Achievement IDs are opaque strings with no personal data attached
- The Vibe Beacon is opt-in via Settings > Social (`vibeBeaconEnabled`)
- Bluetooth and Location permissions are required and requested at the point of use
