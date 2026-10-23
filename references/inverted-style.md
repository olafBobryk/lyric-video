# Inverted typography style

Use only when this style is selected. The bundled renderer implements this preset only.

Render the letter mask as `original * (1-mask) + (255-original) * mask`; preserve footage outside the mask.

## Approved visual language

- Heavy, aggressive, non-serif condensed capitals. Impact is the default when available; keep the font configurable. Do not redistribute installed font files.
- Approximately 10% internal safe padding on all edges, not an added outer border. Preserve source framing and aspect ratio.
- When the picture sits inside an inner frame (letterbox or pillarbox bars, a framed edit), lay the cards out in that frame, not the whole canvas. Measure it (for example `cropdetect`, ignoring burned-in titles in the bars) and pass it as `--frame`.
- Short phrase cards, usually two rows. Alternate a tall top row with a tall bottom row; the dominant row occupies roughly twice the height of the other. Occasional balanced arrangements are appropriate when phrase length needs them.
- Fit complete phrases before revealing them. Keep word positions fixed as new words appear. Reveal whole words at their sung onset, accumulate within the phrase, then replace the card at the next phrase. Never reveal an entire verse at once or re-center on every new word.
- Scale typography to fill the safe area, allowing deliberate condensed/stretched letterforms consistent with the approved treatment. Avoid decorative outlines, panels, shadows, or transitions unless requested.

## Reusable export script

[scripts/render-video.py](../scripts/render-video.py) orchestrates probing, card validation, compiling the mask renderer, 2× mask supersampling, and both exports:

```sh
python3 scripts/render-video.py source.mov cards.json output-directory
```

Use `--duration 15` for a short draft. Use `--frame x:y:w:h` (source pixels, top-left origin) when the footage occupies an inner frame; padding and row sizes are then relative to that frame. It needs macOS Swift and FFmpeg on PATH and preserves the source audio stream. It rejects rotation metadata that needs normalization. For HDR, non-BT.709 color, unusual frame rates, or incompatible copied audio, inspect and adapt the conversion explicitly rather than blindly using the SDR defaults. The master is lossless relative to the RGB composite, not the original encoded YUV representation.

When the user must review lyrics, create a full review cut if authorized, use `[UNCLEAR]` for unresolved words, and provide a timestamped editable transcript. Clearly label it a review cut; highest-quality encoding does not imply artist-verified lyrics. Once corrections arrive, update the timed cards and re-render directly from the source.

## Reusable mask renderer

On macOS, compile [scripts/render-masks.swift](../scripts/render-masks.swift) using `swiftc`. It uses CoreText/CoreGraphics directly, avoiding AppKit application initialization and Swift interpreter failures. Run:

```sh
render-masks cards.json output-directory width height fps duration [x,y,w,h]
```

Produces `output-directory/masks/0000.png`, etc. Coordinates scale to the requested dimensions, or to the optional `x,y,w,h` container in mask pixels. Use the source dimensions or supersample the mask and downsample with a high-quality filter. No font file is bundled.

The JSON is an array of cards with `start`, `end` (seconds, half-open interval), `bigTop` (boolean), and `rows` (two arrays of `{ "text": "WORD", "start": 1.3 }`). Words are uppercase and punctuation is attached to its word. Cards must not overlap; words must be chronological and lie within their card. Silence can have no card. The renderer clips the pre-laid-out full line at word boundaries, without moving earlier words.

Composite with FFmpeg `split`, `negate`, and `maskedmerge` in RGB (`gbrp`), mapping the original audio. Keep source range conversion explicit when it differs from the export. For RGB lossless output, use `ffv1 -level 3 -pix_fmt bgr0` in MKV. For broad MP4 compatibility, convert to `yuv420p`, use `libx264 -crf 12 -preset slow`, and enable `+faststart`. Preserve the full source duration; inspect whether an explicit frame-derived `-t` would truncate audio.
