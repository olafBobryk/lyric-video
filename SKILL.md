---
name: inverted-lyrics
description: Create kinetic lyric videos with oversized condensed typography that masks inverted footage, progressive word reveals, and alternating dominant top and bottom lines. Use for this specific lyric treatment, its test frames, drafts, and full exports.
---

# Inverted lyrics

Use the user's footage as the visual and audio source. Render text as a mask selecting an RGB-inverted copy of the same frame: `output = original * (1-mask) + (255-original) * mask`. Do not substitute opaque white lettering. Outside the mask, preserve the footage.

## Approved visual language

- Heavy, aggressive, non-serif condensed capitals. Impact is the default when available; keep the font configurable. Do not redistribute installed font files.
- Approximately 10% internal safe padding on all edges, not an added outer border. Preserve source framing and aspect ratio.
- Short phrase cards, usually two rows. Alternate a tall top row with a tall bottom row; the dominant row occupies roughly twice the height of the other. Occasional balanced arrangements are appropriate when phrase length needs them.
- Fit complete phrases before revealing them. Keep word positions fixed as new words appear. Reveal whole words at their sung onset, accumulate within the phrase, then replace the card at the next phrase. Never reveal an entire verse at once or re-center on every new word.
- Scale typography to fill the safe area, allowing deliberate condensed/stretched letterforms consistent with the approved treatment. Avoid decorative outlines, panels, shadows, or transitions unless requested.

## Work sequence

1. Inspect video dimensions, duration, frame rate, rotation, color range/space, and audio. Keep the original untouched; work in a separate output folder.
2. Transcribe and obtain acoustic word timestamps. Plain segment timestamps or evenly spaced words are not sufficient. Local MLX Whisper with word timestamps is an available route on Apple silicon. Whisper.cpp DTW requires disabling flash attention on configurations that otherwise produce `t_dtw = -1`; reject missing timestamps.
3. Check ambiguous vocals. Ask for a title/lyric reference when material words remain uncertain, while continuing independent rendering preparation. Do not present uncertain recognition as verified lyrics. Supplied lyrics still need alignment to this recording, including pauses, ad-libs and cut-off endings.
4. Group timed words into readable short cards at musical/semantic boundaries. Alternate dominant rows intentionally. Preserve approved draft choices unless correcting transcription or timing errors.
5. For a new treatment, create a representative still and short motion draft when requested. A request for the full edit after approval authorizes continuing; do not introduce another approval gate.
6. Render from the source, never from the compressed draft. Native dimensions/frame rate preserve real detail; upscaling alone adds none. Preserve color interpretation and original audio. For maximum-quality requests provide a lossless RGB FFV1 master with copied audio and a compatible high-quality H.264 MP4 with copied audio when supported. Explain codec/container tradeoffs only as needed.
7. Verify duration/frame count, audio presence, dimensions, beginning/end coverage, safe padding, fully shown and partially shown cards, top/bottom variation, and actual inversion. Return direct artifact links and an inline video preview where supported. Disclose material transcription/timing uncertainty.

## Reusable export script

[scripts/render-video.py](scripts/render-video.py) orchestrates probing, card validation, compiling the mask renderer, 2× mask supersampling, and both exports:

```sh
python3 scripts/render-video.py source.mov cards.json output-directory
```

Use `--duration 15` for a short draft. It needs macOS Swift and FFmpeg on PATH and preserves the source audio stream. It rejects rotation metadata that needs normalization. For HDR, non-BT.709 color, unusual frame rates, or incompatible copied audio, inspect and adapt the conversion explicitly rather than blindly using the SDR defaults. The master is lossless relative to the RGB composite, not the original encoded YUV representation.

When the user must review lyrics, create a full review cut if authorized, use `[UNCLEAR]` for unresolved words, and provide a timestamped editable transcript. Clearly label it a review cut; highest-quality encoding does not imply artist-verified lyrics. Once corrections arrive, update the timed cards and re-render directly from the source.

## Reusable mask renderer

On macOS, compile [scripts/render-masks.swift](scripts/render-masks.swift) using `swiftc`. It uses CoreText/CoreGraphics directly, avoiding AppKit application initialization and Swift interpreter failures. Run:

```sh
render-masks cards.json output-directory width height fps duration
```

Produces `output-directory/masks/0000.png`, etc. Coordinates scale to the requested dimensions. Use the source dimensions or supersample the mask and downsample with a high-quality filter. No font file is bundled.

The JSON is an array of cards with `start`, `end` (seconds, half-open interval), `bigTop` (boolean), and `rows` (two arrays of `{ "text": "WORD", "start": 1.3 }`). Words are uppercase and punctuation is attached to its word. Cards must not overlap; words must be chronological and lie within their card. Silence can have no card. The renderer clips the pre-laid-out full line at word boundaries, without moving earlier words.

Composite with FFmpeg `split`, `negate`, and `maskedmerge` in RGB (`gbrp`), mapping the original audio. Keep source range conversion explicit when it differs from the export. For RGB lossless output, use `ffv1 -level 3 -pix_fmt bgr0` in MKV. For broad MP4 compatibility, convert to `yuv420p`, use `libx264 -crf 12 -preset slow`, and enable `+faststart`. Preserve the full source duration; inspect whether an explicit frame-derived `-t` would truncate audio.
