# Lyric Video

Create lyric videos with a chosen visual style, word-level timing, and a transcript review loop for unclear vocals. The bundled renderer implements the optional inverted typography preset: oversized letters, alternating dominant rows, and approximately 10% safe padding.

## Install

```sh
npx skills add olafBobryk/lyric-video --skill lyric-video
```

Ask your agent:

> Use lyric-video on my video with the inverted typography style. Start with a test frame and a 15-second draft, reveal words progressively, and alternate oversized top and bottom lines.

## Requirements

The bundled renderer runs locally on macOS with Python 3, Swift (`swiftc`), FFmpeg and FFprobe on PATH, and Impact installed. The agent instructions can be adapted to other systems; the included Swift renderer requires Apple CoreText and CoreGraphics. No Python packages or API key are required for rendering. Transcription is a separate step; a local speech model is optional.

The provided exporter targets unrotated, constant-frame-rate SDR BT.709 footage with even dimensions and MP4-compatible audio. Inspect and adapt conversion for HDR, rotation, variable frame rates, or unsupported audio before rendering.

## Render

Prepare timed phrase cards following the schema in [the inverted style reference](references/inverted-style.md), then run:

```sh
python3 scripts/render-video.py source.mov cards.json output
```

Use `--duration 15` for a draft. If the footage sits inside black bars or another inner frame, pass that area as `--frame x:y:w:h` in source pixels so the cards fit the picture instead of the whole canvas. The output includes a lossless RGB FFV1 master (`lyrics-master.mkv`) and high-quality H.264 MP4 (`lyrics-full.mp4`). Original audio is copied. The master preserves the RGB composite losslessly; it cannot recover detail missing from the input.

The renderer writes masks and exports into the selected output folder and replaces files with those names. Use a fresh output folder for each revision.

## Synthetic example

No personal footage or song lyrics are included. Generate a three-second test pattern with a tone and render the original demonstration words:

```sh
ffmpeg -f lavfi -i 'testsrc2=size=680x454:rate=30:duration=3' -f lavfi -i 'sine=frequency=440:duration=3' -c:v libx264 -pix_fmt yuv420p -c:a aac /tmp/inverted-lyrics-demo.mp4
python3 scripts/render-video.py /tmp/inverted-lyrics-demo.mp4 examples/cards.json /tmp/inverted-lyrics-output
```

Tested with Python 3.14, Swift 6.3.3, and FFmpeg 9.0.1. No font binaries are distributed. Impact remains subject to its owner's license. FFmpeg, Swift, Python, and optional transcription models retain their own licenses.

## Terms

Use and customization for personal or commercial work are allowed; redistribution or resale of the tool is not. See [LICENSE](LICENSE). This is source-available, not an open-source license.

## Transcript review

Uncertain spans are numbered chronologically with timestamps and context. Reply with corrections by number or in order. The agent checks the mapping, updates word timing and the transcript, re-renders, and verifies no unresolved placeholders remain. Any other suspected wording or timing issues are reported before calling an export ready to send.
