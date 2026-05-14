# AI Timetable Scan and Offline OCR

## Flow

```
User takes photo
    |
    v
AiScheduleService.parseImage(file, apiKey)
    |
    v
OcrTimetableParser.parse(file)  <-- offline pre-pass
    |
    |-- confidence >= 0.6 AND entries >= 20 --> return (isOfflineOcr: true)
    |
    |-- not confident enough --> fall through to cloud
    |
    v
Cloud provider:
    |-- Groq Llama 4 (if key starts with gsk_)
    |-- Cloudflare Worker proxy (5 free/day, no key needed)
    |
    v
AiReviewScreen (edit/delete entries per day)
    |
    v
ScheduleService.save()
```

## Offline OCR (OcrTimetableParser)

Located in `lib/services/ocr_timetable_parser.dart`.

### How it works

1. Run `TextRecognizer(script: latin)` on the image
2. Flatten recognized blocks into lines with bounding box coordinates
3. Group lines into rows by Y-coordinate (tolerance = 0.7x average line height)
4. Detect day columns from the header row (Mon/Tue/Wed/Thu/Fri in multiple languages)
5. Walk data rows, match text against the country's canonical subject list
6. Assign each match to the nearest day column
7. Deduplicate by (subject, day, startTime)

### Confidence Scoring

```
confidence = entryScore × 0.6 + daysScore × 0.25 + subjectHitRate × 0.15
```

- `entryScore`: entries found / 20 (clamped 0–1)
- `daysScore`: distinct days covered / 5
- `subjectHitRate`: matched entries / total recognized lines

If confidence is at least 0.6 and there are at least 20 entries, the cloud call is skipped entirely.

## Cloud Providers

### Groq Llama 4

- Endpoint: `api.groq.com/openai/v1/chat/completions`
- Model: `meta-llama/llama-4-scout-17b-16e-instruct`
- Image compressed to 800px max side, sent as base64
- JSON response format enforced

### Worker Proxy

- Endpoint: `breakcount-ai.breakcount.workers.dev`
- Rate limit: 5 scans per day per device ID
- No API key required — works out of the box

## Review Screen

`AiReviewScreen` shows entries day-by-day (Mon to Fri stepper). From here you can:

- Edit subject name (autocomplete from country suggestions)
- Pick start and end time
- Cycle through colors
- Swipe to delete an entry
- Add new entries manually
- See a green "Parsed offline — no API call used" banner when `isOfflineOcr` is true
