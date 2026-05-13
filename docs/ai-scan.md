# AI Timetable Scan & Offline OCR

## Flow

```
User takes photo
    ↓
AiScheduleService.parseImage(file, apiKey)
    ↓
┌─ OcrTimetableParser.parse(file) ─── offline pre-pass
│   ├─ ML Kit TextRecognizer
│   ├─ Grid detection (rows by Y-coordinate)
│   ├─ Day column detection (header tokens)
│   ├─ Subject matching (canonical suggestions)
│   └─ Confidence scoring
│
├─ If confidence ≥ 0.6 AND entries ≥ 20 → return (isOfflineOcr: true)
│
└─ Else fall through to cloud provider:
    ├─ Groq Llama 4 (if key starts with gsk_)
    └─ Cloudflare Worker proxy (5 free/day, no key needed)
        ↓
AiReviewScreen (edit/delete entries per day)
    ↓
ScheduleService.save()
```

## Offline OCR (`OcrTimetableParser`)

Located in `lib/services/ocr_timetable_parser.dart`.

### Algorithm

1. Run `TextRecognizer(script: latin)` on the image
2. Flatten recognized blocks into lines with bounding box coordinates
3. Group lines into rows by Y-coordinate (tolerance = 0.7× avg line height)
4. Detect day columns from header row (Mon/Tue/Wed/Thu/Fri in multiple languages)
5. Walk data rows, match text against country's canonical subject list
6. Assign each match to nearest day column
7. Deduplicate by (subject, day, startTime)

### Confidence Scoring

```
confidence = entryScore × 0.6 + daysScore × 0.25 + subjectHitRate × 0.15
```

- `entryScore`: entries found / 20 (clamped 0–1)
- `daysScore`: distinct days covered / 5
- `subjectHitRate`: matched entries / total recognized lines

Threshold: ≥ 0.6 confidence AND ≥ 20 entries to skip cloud call.

## Cloud Providers

### Groq Llama 4
- Endpoint: `api.groq.com/openai/v1/chat/completions`
- Model: `meta-llama/llama-4-scout-17b-16e-instruct`
- Image compressed to 800px max side, sent as base64
- JSON response format enforced

### Worker Proxy
- Endpoint: `breakcount-ai.breakcount.workers.dev`
- Rate limit: 5 scans/day per device ID
- No API key required

## Review Screen

`AiReviewScreen` shows entries day-by-day (Mon→Fri stepper). Features:
- Edit subject name (autocomplete from country suggestions)
- Pick start/end time
- Cycle color
- Swipe to delete
- Add new entries
- Green "Parsed offline" banner when `isOfflineOcr` is true
